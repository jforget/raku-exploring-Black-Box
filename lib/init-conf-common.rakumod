#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation d'une configuration de Black Box
#     Initialising a Black Box configuration
#     Copyright (C) 2021, 2022 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;

unit module init-conf-common;

use BSON::Document;

sub init (Str $config, $purge-Configurations, $purge-Molecules, $store-Configuration) is export {
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
              config   => $cf,
              nb_mol   => $nb_mol,
              nb_atoms => $nb_atoms,
              width    => $width,
              dh1      => time-stamp,
  );

  $purge-Configurations($cf);
  $purge-Molecules($cf);
  $store-Configuration($configuration);


}

sub time-stamp {
  return sprintf "%04d-%02d-%02dT%02d:%02d:%02d", .year, .month, .day, .hour, .minute, .whole-second given DateTime.now.utc;
}

=begin POD

=encoding utf8

=head1 NAME

init-conf-common.raku -- module to initialise a Black Box configuration

=head1 DESCRIPTION

This procedural  module contains a database-agnostic  function used to
initialise the content  of a Black Box configuration.  For the moment,
it can  be invoked by  the F<init-conf-mongo.raku> program and  by the
F<init-conf-sql.raku> program.

=head1 USAGE

See the main Raku programs.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
