#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Affichage des molécules dans Black Box (base MongoDB)
#     Display some molecules for a Black Box configuration (MongoDB version)
#     Copyright (C) 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;

unit module display-common;

use BSON::Document;

sub display(Str $cf, BSON::Document $doc) is export {
  unless $cf ~~ /^ 'A' (\d+) '_B' (\d) $ / {
    die "Wrong configuration $cf";
  }
  my Int $width    = + $1;
  my $spectrum = $doc<spectrum> // ' ' x ($width × 4);
  say "\n", $doc<number>, ' ', $spectrum, "\n";
  say insert-spaces(' ' ~ substr($spectrum, 3 × $width, $width).flip);
  for (1 .. $width) -> $l {
    say insert-spaces(  substr($spectrum, $l - 1, 1)
		      ~ substr($doc<molecule>, ($l - 1) × $width, $width)
		      ~ substr($spectrum, 3 × $width - $l, 1));
  }
  say insert-spaces(' ' ~ substr($spectrum, $width, $width));
  printf "          number length  turns\n";
  printf "Absorbed   %2d    %3d %2d %3d %2d\n", $doc< absorbed-number>, $doc< absorbed-tot-length>, $doc< absorbed-max-length>, $doc< absorbed-tot-turns>, $doc< absorbed-max-turns>;
  printf "Reflected  %2d    %3d %2d %3d %2d\n", $doc<reflected-number>, $doc<reflected-tot-length>, $doc<reflected-max-length>, $doc<reflected-tot-turns>, $doc<reflected-max-turns>;
  printf "Out        %2d    %3d %2d %3d %2d\n", $doc<      out-number>, $doc<      out-tot-length>, $doc<      out-max-length>, $doc<      out-tot-turns>, $doc<      out-max-turns>;
}

sub insert-spaces (Str $str) {
  return $str.comb.join(' ');
}


=begin POD

=encoding utf8

=head1 NAME

display-mongo.raku -- Display some molecules and their spectrum for a Black Box configuration

=head1 DESCRIPTION

This program extracts the molecules  for a Black Box configuration and
a range of numbers and displays them.

=head1 SYNOPSIS

  raku display-mongo.raku --config=a4_b8 --from=10 --to=19
  raku display-mongo.raku --config=a4_b4 --spectrum='@&&@@&@a@@a@&@@@'
  reku display-mongo.raku --config=a4_b4 1 3 5

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box. If necessary, letters C<a> and
C<b> can be converted to upper-case.

=item from, to

The  range of  numbers for  the  keys of  the molecules  that will  be
extracted.

=item spectrum

The value  of the  C<spectrum> attribute, to  display the  molecule or
possibly all the molecules sharing this spectrum.

=item list of numbers

This parameter  is a position  parameter, not a keyword  parameter. It
accepts  multiple  values. The  values  are  the  number keys  of  the
molecules to display.

Since the spectrum contains C<@> and C<&> chars, it must be quoted.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
