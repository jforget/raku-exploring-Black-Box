#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation d'une configuration de Black Box
#     Initialising a Black Box configuration
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
  my $cf = $config.uc;
  unless $cf ~~ /^ 'A' (\d+) '_B' (\d) $ / {
    die "Wrong configuration $config";
  }
  my Int $nb_atoms = + $0;
  my Int $width    = + $1;
  my Int $surface  = $width²;

  my Int $x = min($nb_atoms, $surface - $nb_atoms);
  my Int $den = 1;
  my Int $num = 1;
  for (0 .. $x - 1) -> Int $i {
    $num ×= $surface - $i;
    $den ×= $i + 1;
  }
  my Int $nb_mol = ($num / $den).Int;

  my BSON::Document $configuration .= new: (
              config => $cf,
              nb_mol => $nb_mol,
              dh1    => time-stamp,
  );

  my BSON::Document $req;
  my BSON::Document $result;

  $req .= new: (
    delete    => 'Molecules',
    deletes   => [ (
          q     => ( config => ($cf), ),
          limit => 0,
    ), ],
  );
  $result = $database.run-command($req);
  say "Clean-up molecules     ok : ", $result<ok>, " nb : ", $result<n>;

  $req .= new: (
    delete    => 'Configurations',
    deletes   => [ (
          q     => ( config => ($cf), ),
          limit => 0,
    ), ],
  );
  $result = $database.run-command($req);
  say "Clean-up configuration ok : ", $result<ok>, " nb : ", $result<n>;

  $req .= new: (
    insert    => 'Configurations',
    documents => [ $configuration ],
  );
  $result = $database.run-command($req);
  say "Creation configuration ok : ", $result<ok>, " nb : ", $result<n>;

}

sub time-stamp {
  return sprintf "%04d-%02d-%02dT%02d:%02d:%02d", .year, .month, .day, .hour, .minute, .whole-second
         given DateTime.now.utc;
}

=begin POD

=encoding utf8

=head1 NAME

init-conf.raku -- initialising a Black Box configuration

=head1 DESCRIPTION

This  program  creates  a   single  record  in  the  C<Configurations>
collection  and, if  necessary, empties  the C<Molecules>  collection,
removing  any C<Molecule>  document  identified  by the  configuration
code.

=head1 SYNOPSIS

  raku init-conf.raku a4_b8

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
