#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation d'une configuration de Black Box (base SQLite)
#     Initialising a Black Box configuration (in a SQLite database)
#     Copyright (C) 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use DBIish;
use BSON::Document;
use explore-common;
use db-conf-sql;

my $dbh = DBIish.connect('SQLite', database => dbname());

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
  ...
}

sub last-number(BSON::Document $configuration) {
 ...
}

sub molecule-by-number (Str $cf, Int $number) {
  ...
}

sub molecule-by-molecule (Str $cf, Str $molecule) {
  ...
}

sub store-molecules (@molecules) {
  ...
}

sub upd-molecule (BSON::Document $molecule) {
  ...
}

sub remove-enantiomer-group (Str $cf, Int $number) {
  ...
}

=begin POD

=encoding utf8

=head1 NAME

explore-sql.raku -- Exploring all the molecules for a Black Box configuration, SQLite version

=head1 DESCRIPTION

This  program   lists  all   possible  molecules   for  a   Black  Box
configuration. For each  molecule, it computes its  spectrum and store
it into the C<Molecules> table of the database.

=head1 SYNOPSIS

  raku explore-sql.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box. If necessary, letters C<a> and
C<b> can be converted to upper-case.

=head2 Database Configuration

The   filename  of   the  SQLite   database  is   hard-coded  in   the
F<lib/db-conf-sql.rakumod> file.  Be sure to update  this value before
running the F<init-conf-sql.raku> program.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
