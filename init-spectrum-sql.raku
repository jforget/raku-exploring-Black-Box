#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation de la table Spectrums pour une configuration de Black Box (base de données SQLite)
#     Initialising the Spectrums table for a Black Box configuration (SQLite database)
#     Copyright (C) 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use DBIish;
use db-conf-sql;

my $dbh = DBIish.connect('SQLite', database => dbname());

sub MAIN (Str $config) {
  my $cf = $config.uc;
  unless $cf ~~ / ^ 'A' <[0..9]> ** 1..2 '_B' <[0..9]> $ / {
    die "Invalid configuration $cf";
  }
  create-table();
  purge-Spectrums($cf);
  fill-Spectrums($cf);
}

sub create-table {
  $dbh.execute(q:to/SQL/);
create table if not exists Spectrums (
              config
            , spectrum
            , nb_mol
            , transform
            );
SQL
}

sub purge-Spectrums(Str $cf) {
  $dbh.execute('delete from Spectrums where config = ?', $cf);
}

sub fill-Spectrums(Str $cf) {
  my $sth = $dbh.execute(q:to/SQL/, $cf);
  insert into Spectrums (config, spectrum, nb_mol, transform)
       select   max(config), max(spectrum), count(*) as nb, '??'
       from     Molecules
       where    config = ?
       group by spectrum
       having   nb > 1
SQL

}

=begin POD

=encoding utf8

=head1 NAME

init-spectrum-sql.raku -- loading the Spectrums table for a Black Box configuration, SQLite variant

=head1 DESCRIPTION

This programme  aggregates the C<spectrum> fields  of the C<Molecules>
table for  a given  Black Box configuration  and stores  the aggregate
values into the C<Spectrums> table.

Only  spectrums  leading  to   ambiguous  games,  that  is,  spectrums
appearing in  more than  one molecule are  stored in  the C<Spectrums>
table.

=head1 USAGE

  raku init-spectrum-sql.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box.

=head2 Database Configuration

The   filename  of   the  SQLite   database  is   hard-coded  in   the
F<lib/db-conf-sql.rakumod> file.  Be sure to update  this value before
running the F<init-conf-sql.raku> program.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
