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
use lib 'lib';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use display-common;

my MongoDB::Client     $client        .= new(:uri('mongodb://'));
my MongoDB::Database   $database       = $client.database('Black-Box');
my MongoDB::Collection $configurations = $database.collection('Configurations');
my MongoDB::Collection $molecules      = $database.collection('Molecules');

my Int $nb_atoms;
my Int $width;

multi sub MAIN (Str :$config, Int :$from, Int :$to) {
  my Str $cf = $config.uc;
  check-conf($cf);

  say "from $from to $to";
  # With the Mongo shell, we would extract the molecules with:
  #
  #    db.Molecules.find({ config: $cf, number: { '$gte': $from, '$lte': $to }}).sort({ number: 1 })
  #
  # but I do not know how to write a Raku-Mongo find with a complex criterion (range) and a sort.
  my MongoDB::Cursor $cursor = $molecules.find(
        criteria   => ( config => $cf
                      , #### number => ( '$gte' => $from, '$lte' => $to ),
                      ),
      );
  my BSON::Document @doc;
  while $cursor.fetch -> BSON::Document $doc {
    if $from ≤ $doc<number> ≤ $to {
      push @doc, $doc;
    }
  }
  $cursor.kill;
  for @doc ==> sort { $_<number> } -> BSON::Document $doc {
     display($cf, $doc)
  }
}

multi sub MAIN (Str :$config, *@num) {
  my Str $cf = $config.uc;
  check-conf($cf);

  my BSON::Document @doc;

  for (@num) -> Int $num {
    my MongoDB::Cursor $cursor = $molecules.find(
	  criteria   => ( config => $cf
			, number => + $num
			),
	);
    while $cursor.fetch -> BSON::Document $doc {
      push @doc, $doc;
    }
    $cursor.kill;
  }
  for @doc ==> sort { $_<number> } -> BSON::Document $doc {
     display($cf, $doc)
  }
}

multi sub MAIN (Str :$config, Str :$spectrum) {
  my Str $cf = $config.uc;
  check-conf($cf);

  my MongoDB::Cursor $cursor = $molecules.find(
        criteria   => ( config => $cf
                      , spectrum => $spectrum
                      ),
      );
  my BSON::Document @doc;
  while $cursor.fetch -> BSON::Document $doc {
    push @doc, $doc;
  }
  $cursor.kill;
  for @doc ==> sort { $_<number> } -> BSON::Document $doc {
     display($cf, $doc)
  }
}

sub check-conf(Str $cf) {
  unless $cf ~~ /^ 'A' (\d+) '_B' (\d) $ / {
    die "Wrong configuration $cf";
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
    die "Unknown configuration $cf";
  }
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
