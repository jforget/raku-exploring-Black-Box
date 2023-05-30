#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation d'une configuration de Black Box (base MongoDB)
#     Initialising a Black Box configuration (in a MongoDB database)
#     Copyright (C) 2021, 2022, 2023 Jean Forget
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
use explore-common;

my MongoDB::Client     $client        .= new(:uri('mongodb://'));
my MongoDB::Database   $database       = $client.database('Black-Box');
my MongoDB::Collection $configurations = $database.collection('Configurations');
my MongoDB::Collection $molecules      = $database.collection('Molecules');

my %dispatch = load-configuration      => &load-configuration
             , last-number             => &last-number
             , molecule-by-number      => &molecule-by-number
             , molecule-by-molecule    => &molecule-by-molecule
             , store-molecules         => &store-molecules
             , upd-molecule            => &upd-molecule
             , remove-enantiomer-group => &remove-enantiomer-group
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

sub last-number(BSON::Document $configuration) {
  # Finding the last number processed in the previous run, which will be the first
  # one to be processed in the current run.
  # In Mongo-shell, it would be easy:
  #         db.Molecules.find({ config: $cf} ).sort({number: -1}).limit(1)
  # In SQL, it would be easy too:
  #         select max(Molecules.number) from Molecules where Molecules.config = ?
  #
  # In Raku + MongoDB, there is a substitute to 'limit(n)', which is the parameter "number-to-return",
  # but there is no substitute to 'sort(...)'.
  # The first idea is to retrieve all records, sort them in Raku, keep the first. A very bad
  # idea, because sorting is O(n.log(n)).
  # A better idea is to retrieve all records, iterate on them and extract the
  # maximum value of the (unsorted) list. This is better, but still O(n).
  # The idea implemented below is a binary search. Hoping that O(log(n)) will be fast enough.
  my Int $there     = 0;
  my Int $not-there = $configuration<nb_mol> + 1;
  my Str $cf        = $configuration<config>;
  while $not-there - $there > 1 {
    my Int $found  = 0;
    my Int $middle = (($there + $not-there) / 2).floor;
    my MongoDB::Cursor $cursor = $molecules.find(
        criteria   => ( config => $cf
                      , number => $middle ),
      );
    while $cursor.fetch -> BSON::Document $doc {
      $found = 1;
    }
    $cursor.kill;
    if $found {
      $there = $middle;
    }
    else {
      $not-there = $middle;
    }
  }
  return $there;
}

sub molecule-by-number (Str $cf, Int $number) {
  my Int             $found = 0;
  my BSON::Document  $molecule-doc;
  my MongoDB::Cursor $cursor = $molecules.find(
        criteria   => ( config => $cf
                      , number => $number
        ),
      );
  while $cursor.fetch -> BSON::Document $doc {
    $found = 1;
    $molecule-doc = $doc;
    last
  }
  $cursor.kill;
  return $found, $molecule-doc;
}

sub molecule-by-molecule (Str $cf, Str $molecule) {
  my Int             $found = 0;
  my BSON::Document  $molecule-doc;
  my MongoDB::Cursor $cursor = $molecules.find(
        criteria   => ( config   => $cf
                      , molecule => $molecule
        ),
      );
  while $cursor.fetch -> BSON::Document $doc {
    $found = 1;
    $molecule-doc = $doc;
    last
  }
  $cursor.kill;
  return $found, $molecule-doc;
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

sub remove-enantiomer-group (Str $cf, Int $number) {
  my BSON::Document $req .= new: (
          delete    => 'Molecules',
          deletes   => [ (
                q     => ( config => ($cf), canonical-number => ($number), ),
                limit => 0,
          ), ],
        );
  my BSON::Document $result = $database.run-command($req);
  say "Clean-up molecules     ok : ", $result<ok>, " nb : ", $result<n>;
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

Copyright (C) 2021, 2022, 2023, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
