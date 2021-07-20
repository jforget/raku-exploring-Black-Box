#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation d'une configuration de Black Box (base MongoDB)
#     Initialising a Black Box configuration (in a MongoDB database)
#     Copyright (C) 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;
use explore-common;

my MongoDB::Client     $client        .= new(:uri('mongodb://'));
my MongoDB::Database   $database       = $client.database('Black-Box');
my MongoDB::Collection $configurations = $database.collection('Configurations');
my MongoDB::Collection $molecules      = $database.collection('Molecules');

my %dispatch = load-configuration => &load-configuration
             , store-molecules    => &store-molecules
             , upd-molecule       => &upd-molecule
             ;

sub MAIN (Str $config) {
  my $cf = $config.uc;
  explore($cf, %dispatch);
}

sub load-configuration (Str $cf) {
  my BSON::Document $configuration;
  my MongoDB::Cursor $cursor = $configurations.find(
    criteria   => ( 'config' => $cf, ),
  );
  while $cursor.fetch -> BSON::Document $d {
    $configuration = $d;
    last;
  }
  $cursor.kill;
  unless $configuration {
    die "Configuration inconnue $cf";
  }
  return $configuration;
}

sub store-molecules (@molecules) {
  my BSON::Document $req;
  my BSON::Document $result;
  my Int $number = @molecules[0]<canonical-number>;

  $req .= new: (
    insert    => 'Molecules',
    documents => [ @molecules ],
  );
  $result = $database.run-command($req);
  unless $result<ok> {
    die "Problem when storing molecule # $number";
  }
}

sub upd-molecule (BSON::Document $molecule) {
   my BSON::Document $req .= new: (
      update => 'Molecules',
      updates => [ (
        q =>  ( config   => $molecule<config>
              , molecule => $molecule<molecule>
              ),
        u => $molecule,
      ),
    ],
  );
  my BSON::Document $doc = $database.run-command($req);
  if $doc<ok> == 0 {
    say "update ok : ", $doc<ok>, " nb : ", $doc<n>;
  }
}

=begin POD

=encoding utf8

=head1 NAME

explore.raku -- Exploring all the molecules for a Black Box configuration, MongoDB version

=head1 DESCRIPTION

This  program   lists  all   possible  molecules   for  a   Black  Box
configuration. For each  molecule, it computes its  spectrum and store
it into the C<Molecules> collection of the database.

=head1 SYNOPSIS

  raku explore-mongo.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box. If necessary, letters C<a> and
C<b> can be converted to upper-case.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
