#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Recherche des symétries entre les spectres de la table Spectrums
#     Looking for symmetries between the records from the Spectrums table
#     Copyright (C) 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;

unit module upd-spectrum-common;

use BSON::Document;

my Int $nb_atoms;
my Int $width;

sub upd-spectrum (Str $config, %dispatch) is export {
  my Str $cf = $config.uc;
  unless $cf ~~ / ^ 'A' (<[0..9]> ** 1..2) '_B' (<[0..9]>) $ / {
    die "Wrong configuration $config";
  }
  $nb_atoms = + $0;
  $width    = + $1;

  my $callback = %dispatch<canonical-molecules>;
  my Int @numbers = $callback($cf);

  for @numbers -> Int $canonical-number {
    my $callback = %dispatch<enantiomer-group>;
    my @enantiomer-group = $callback($cf, $canonical-number);
    # No type for @enantiomer-group: array of hashes for SQL, array of BSON::Document for MongoDB
    #say @enantiomer-group;

    say '-------', $canonical-number;
    for @enantiomer-group -> $mol {
      my $callback = %dispatch<read-spectrum>;
      my BSON::Document $spectrum-doc = $callback($cf, $mol<spectrum>);
      if $spectrum-doc<transform> ne '??' {
        say "no change on spectrum $cf $mol<spectrum> $spectrum-doc<transform>";
      }
      else {
        say "change on spectrum $cf $mol<spectrum> $spectrum-doc<transform> $mol<transform>";
        $spectrum-doc<transform>        = $mol<transform>;
        $spectrum-doc<canonical-number> = $canonical-number;
        my $callback = %dispatch<update-spectrum>;
        $callback($spectrum-doc);
      }
    }
  }
}


=begin POD

=encoding utf8

=head1 NAME

upd-spectrum.rakumod -- Finding symmetries between spectrums

=head1 DESCRIPTION

This module is  used by the programmes which  updates the C<transform>
field of  the C<Spectrums> records  / documents,  so we can  see which
spectrum is  related to which other  spectrum through a rotation  or a
symmetry.

=head1 SYNOPSIS

  raku upd-spectrum-sql.raku a4_b8

or

  raku upd-spectrum-mongo.raku a4_b8

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
