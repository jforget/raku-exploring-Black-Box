#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Affichage des molécules dans Black Box
#     Display some molecules for a Black Box configuration
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

my Int $nb_atoms;
my Int $width;

sub MAIN (Str $config, Int $first, Int $last) {
  my Str $cf = $config.uc;
  unless $cf ~~ /^ 'A' (\d+) '_B' (\d) $ / {
    die "Wrong configuration $config";
  }
  $nb_atoms = + $0;
  $width    = + $1;

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

  say "first = $first, last = $last";
  # With the Mongo shell, we would extract the molecules with:
  #
  #    db.Molecules.find({ config: $cf, number: { '$gte': $first, '$lte': $last }}).sort({ number: 1 })
  #
  # but I do not know how to write a Raku-Mongo find with a complex criterion (range) and a sort.
  $cursor = $molecules.find(
        criteria   => ( config => $cf
                      , #### number => ( '$gte' => $first, '$lte' => $last ),
                      ),
      );
  my BSON::Document @doc;
  while $cursor.fetch -> BSON::Document $doc {
    if $first ≤ $doc<number> ≤ $last {
      push @doc, $doc;
    }
  }
  $cursor.kill;
  for @doc ==> sort { $_<number> } -> BSON::Document $doc {
    my $spectrum = $doc<spectrum> // ' ' x ($width × 4);
    say "\n", $doc<number>, ' ', $spectrum, "\n";
    say insert-spaces(' ' ~ substr($spectrum, 3 × $width, $width).flip);
    for (1 .. $width) -> $l {
      say insert-spaces(  substr($spectrum, $l - 1, 1)
                        ~ substr($doc<molecule>, ($l - 1) × $width, $width)
                        ~ substr($spectrum, 3 × $width - $l, 1));
    }
    say insert-spaces(' ' ~ substr($spectrum, $width, $width));
  }
}

sub insert-spaces (Str $str) {
  return $str.comb.join(' ');
}


=begin POD

=encoding utf8

=head1 NAME

display.raku -- Display some molecules and their spectrum for a Black Box configuration

=head1 DESCRIPTION

This program extracts the molecules  for a Black Box configuration and
a range of numbers and displays them.

=head1 SYNOPSIS

  raku display.raku a4_b8  10 19

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box. If necessary, letters C<a> and
C<b> can be converted to upper-case.

=item first, last

The  range of  numbers for  the  keys of  the molecules  that will  be
extracted.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
