#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Exploration exhaustive des molécules dans Black Box
#     Exploring all the molecules for a Black Box configuration
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

my MongoDB::Client     $client        .= new(:uri('mongodb://'));
my MongoDB::Database   $database       = $client.database('Black-Box');
my MongoDB::Collection $configurations = $database.collection('Configurations');
my MongoDB::Collection $molecules      = $database.collection('Molecules');

sub MAIN (Str $config) {
  my Str $cf = $config.uc;
  unless $cf ~~ /^ 'A' (\d+) '_B' (\d) $ / {
    die "Wrong configuration $config";
  }
  my Int $nb_atoms = + $0;
  my Int $width    = + $1;

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

  say "$nb_atoms atoms in a $width × $width square";

  my Str $molecule;
  my Int $number;

  my BSON::Document $req;
  my BSON::Document $result;

  $molecule = 'O' x $nb_atoms ~ '-' x ($width² - $nb_atoms);
  $number   = 1;

  loop {
    new-molecule($cf, $number, $molecule);

    last unless $molecule ~~ /'O-'/;

    ++$number;
    my Int $pos = rindex($molecule, 'O-');
    my $mol1 = substr($molecule, 0, $pos);
    my $mol3 = substr($molecule, $pos + 2);
    $molecule = $mol1 ~ '-O' ~ $mol3.flip;
  }

}

sub new-molecule (Str $cf, Int $number, Str $molecule) {
  printf "%6d %s\n", $number, $molecule;
  my BSON::Document $molecule-doc .= new: (
              config             => $cf
            , number             => $number
            , canonical-number   => $number
            , molecule           => $molecule
            , dh1                => time-stamp
  );
  my %group;
  %group{$molecule} = $molecule-doc;

  my BSON::Document $req;
  my BSON::Document $result;

  $req .= new: (
    insert    => 'Molecules',
    documents => [ %group.values ],
  );
  $result = $database.run-command($req);
  unless $result<ok> {
    die "Problem when storing molecule # $number '$molecule'";
  }

}

sub time-stamp {
  return sprintf "%04d-%02d-%02dT%02d:%02d:%02d", .year, .month, .day, .hour, .minute, .whole-second
           given DateTime.now.utc;
}

=begin POD

=encoding utf8

=head1 NAME

explore.raku -- Exploring all the molecules for a Black Box configuration

=head1 DESCRIPTION

This  program   lists  all   possible  molecules   for  a   Black  Box
configuration,  compute   their  spectrum   and  store  it   into  the
C<Molecules> collection of the database.

=head1 LANCEMENT

  raku explore.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
