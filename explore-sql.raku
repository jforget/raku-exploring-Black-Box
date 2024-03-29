#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation d'une configuration de Black Box (base SQLite)
#     Initialising a Black Box configuration (in a SQLite database)
#     Copyright (C) 2021, 2022, 2023 Jean Forget
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
my $sql-counter = 0;
my $next-commit = commit-interval();

my %dispatch = load-configuration      => &load-configuration
             , last-number             => &last-number
             , molecule-by-number      => &molecule-by-number
             , molecule-by-molecule    => &molecule-by-molecule
             , store-molecules         => &store-molecules
             , upd-molecule            => &upd-molecule
             , remove-enantiomer-group => &remove-enantiomer-group
             ;

my @key-doc = < config
                number
                canonical-number
                molecule
                spectrum
                transform
                absorbed-number
                absorbed-max-length
                absorbed-max-turns
                absorbed-tot-length
                absorbed-tot-turns
                reflected-number
                reflected-edge
                reflected-deep
                reflected-max-length
                reflected-max-turns
                reflected-tot-length
                reflected-tot-turns
                out-number
                out-max-length
                out-max-turns
                out-tot-length
                out-tot-turns
                dh1
                dh2
                >;
@key-doc ==> map { .trans('-' => '_') } ==> my @sql-columns;
my @qst-mrk = '?' xx @key-doc.elems;

# No this is not a "Bobby tables" issue. The strings interpolated into the SQL statement
# are fully controlled by the programme maintainer. They do not come from user input or
# from an external origin.
my $sql-insert = sprintf("insert into Molecules (%s) values (%s)", @sql-columns.join(','), @qst-mrk.join(','));

sub MAIN (Str $config) {
  $dbh.execute('begin transaction');
  my $cf = $config.uc;
  explore($cf, %dispatch);
  $dbh.execute('commit transaction');
}

sub load-configuration (Str $cf) {
  my $sth = $dbh.prepare('select * from Configurations where config = ?');
  my $doc = $sth.execute($cf).row(:hash);
  unless $doc {
    die "Unknown configuration $cf";
  }
  my BSON::Document $configuration .= new;
  for $doc.keys -> $key {
    $configuration{$key} = $doc{$key};
  }
  return $configuration;
}

sub last-number(BSON::Document $configuration) {
  my $sth = $dbh.prepare('select max(number) from Molecules where config = ?');
  my $result  = $sth.execute($configuration<config>).row();
  unless $result[0] {
    return 0;
  }
  say $result[0];
  return $result[0];
}

sub molecule-by-number (Str $cf, Int $number) {
  my $sth = $dbh.prepare('select * from Molecules where config = ? and number = ?');
  my $result  = $sth.execute($cf, $number).row(:hash);
  unless $result<config> {
    return 0;
  }
  return molecule-by-any($result);
}

sub molecule-by-molecule (Str $cf, Str $molecule) {
  my $sth = $dbh.prepare('select * from Molecules where config = ? and molecule = ?');
  my $result  = $sth.execute($cf, $molecule).row(:hash);
  unless $result<config> {
    return 0;
  }
  return molecule-by-any($result);
}

sub molecule-by-any ($result) {
  my BSON::Document $molecule-doc .= new;
  for $result.keys -> $key {
    $molecule-doc{$key.trans('_' => '-')} = $result{$key};
  }
  return 1, $molecule-doc;

}

sub store-molecules (@molecules) {
  for @molecules -> $molecule {
    store-molecule($molecule);
  }
  if $sql-counter ≥ $next-commit {
    $dbh.execute('commit transaction');
    $dbh.execute('begin transaction');
    $next-commit = $sql-counter + commit-interval();
    #say time-stamp, ' commit storing group ', @molecules[0]<canonical-number>;
  }
}

sub store-molecule (BSON::Document $molecule) {
  $dbh.execute($sql-insert, |$molecule{@key-doc});
  ++ $sql-counter;
}

sub upd-molecule (BSON::Document $molecule) {
  $dbh.execute(q:to/SQL/
  update Molecules
  set    number   = ?
       , dh2      = ?
  where  config   = ?
    and  molecule = ?
SQL
      , $molecule<number>
      , $molecule<dh2>
      , $molecule<config>
      , $molecule<molecule>
     );
  ++ $sql-counter;
  if $sql-counter ≥ $next-commit {
    $dbh.execute('commit transaction');
    $dbh.execute('begin transaction');
    $next-commit = $sql-counter + commit-interval();
    #say time-stamp, ' commit upd of molecule ', $molecule<number>;
  }
}

sub remove-enantiomer-group (Str $cf, Int $number) {
  $dbh.execute(q:to/SQL/
  delete from Molecules
  where  config   = ?
  and    canonical_number = ?
SQL
      , $cf
      , $number
     );
  ++ $sql-counter;
  if $sql-counter ≥ $next-commit {
    $dbh.execute('commit transaction');
    $dbh.execute('begin transaction');
    $next-commit = $sql-counter + commit-interval();
    #say time-stamp, " commit removing group $number";
  }
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

Copyright (C) 2021, 2022, 2023, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
