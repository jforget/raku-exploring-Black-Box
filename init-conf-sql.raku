#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation d'une configuration de Black Box (base de données SQLite)
#     Initialising a Black Box configuration (SQLite database)
#     Copyright (C) 2021, 2022 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use DBIish;
use BSON::Document;
use init-conf-common;
use db-conf-sql;

my $dbh = DBIish.connect('SQLite', database => dbname());

sub MAIN (Str $config) {
  my $cf = $config.uc;
  create-database();
  init($cf, &purge-Configurations, &purge-Molecules, &store-Configuration);
}

sub create-database {
  $dbh.execute(q:to/SQL/);
create table if not exists Configurations (
              config
            , nb_mol
            , nb_atoms
            , width
            , dh1
            );
SQL

  $dbh.execute(q:to/SQL/);
create table if not exists Molecules (
              config
            , number
            , canonical_number
            , molecule
            , spectrum
            , transform
            , absorbed_number
            , absorbed_max_length
            , absorbed_max_turns
            , absorbed_tot_length
            , absorbed_tot_turns
            , reflected_number
            , reflected_edge
            , reflected_deep
            , reflected_max_length
            , reflected_max_turns
            , reflected_tot_length
            , reflected_tot_turns
            , out_number
            , out_max_length
            , out_max_turns
            , out_tot_length
            , out_tot_turns
            , dh1
            , dh2
            );
SQL
}

sub purge-Configurations(Str $cf) {
  $dbh.execute('delete from Configurations where config = ?', $cf);
}

sub purge-Molecules(Str $cf) {
  $dbh.execute('delete from Molecules where config = ?', $cf);
}

sub store-Configuration(BSON::Document $doc) {
  $dbh.execute(q:to/SQL/,
  insert into Configurations
     values (?, ?, ?, ?, ?)
SQL
           $doc<config>,
           $doc<nb_mol>,
           $doc<nb_atoms>,
           $doc<width>,
           $doc<dh1>);
}

=begin POD

=encoding utf8

=head1 NAME

init-conf-sql.raku -- initialising a Black Box configuration, SQLite variant

=head1 DESCRIPTION

This program creates a single record in the C<Configurations> table of
the  Black  Box   SQLite  database  and,  if   necessary,  cleans  the
C<Molecules>  table, removing  any C<Molecule>  row identified  by the
configuration code.

=head1 USAGE

  raku init-conf-sql.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box.

=head2 Database Configuration

The   filename  of   the  SQLite   database  is   hard-coded  in   the
F<lib/db-conf-sql.rakumod> file.  Be sure to update  this value before
running the F<init-conf-sql.raku> program.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, 2022, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
