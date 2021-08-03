#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Recherche des symétries entre les spectres de la table Spectrums (base de données SQLite)
#     CLooking for symmetries between the records from the Spectrums table (SQLite database)
#     Copyright (C) 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use DBIish;
use BSON::Document;
use db-conf-sql;
use upd-spectrum-common;

my $dbh = DBIish.connect('SQLite', database => dbname());

my %dispatch = canonical-molecules => &canonical-molecules
             , enantiomer-group    => &enantiomer-group
             , read-spectrum       => &read-spectrum
             , update-spectrum     => &update-spectrum
             ;

sub MAIN (Str $config) {
  my $cf = $config.uc;
  upd-spectrum($cf, %dispatch);
}

sub canonical-molecules(Str $cf) {
  my $sth = $dbh.execute(q:to/SQL/, $cf, $cf);
select number
from   Molecules
where  config = ?
  and  transform = 'id'
  and  spectrum in (select spectrum
                    from   Spectrums
                    where  config = ?
                      and  transform = '??')
SQL
  return $sth.allrows.map({ $_[0] });
}

sub enantiomer-group(Str $cf, Int $canonical-number) {
  my $sth = $dbh.execute(q:to/SQL/, $cf, $canonical-number);
select   number, spectrum, transform
from     Molecules
where    config = ?
  and    canonical_number = ?
order by number
SQL
  return $sth.allrows(:array-of-hash);
}

sub read-spectrum(Str $cf, Str $spectrum) {
  my $sth = $dbh.execute(q:to/SQL/, $cf, $spectrum);
select   *
from     Spectrums
where    config = ?
  and    spectrum = ?
SQL
  my $doc = $sth.row(:hash);
  unless $doc {
    die "Unknown spectrum $cf $spectrum";
  }
  my BSON::Document $spec-doc .= new;
  for $doc.keys -> $key {
    $spec-doc{$key} = $doc{$key};
  }
  return $spec-doc;

}

sub update-spectrum(BSON::Document $spectrum) {
  $dbh.execute(q:to/SQL/
  update Spectrums
  set    transform = ?
  where  config   = ?
    and  spectrum = ?
SQL
      , $spectrum<transform>
      , $spectrum<config>
      , $spectrum<spectrum>
     );
}


=begin POD

=encoding utf8

=head1 NAME

upd-spectrum-sql.raku -- looking for symmetries between the spectrums, SQLite variant

=head1 DESCRIPTION

This  programme updates  the  C<transform> field  of the  C<Spectrums>
records,  so we  can  see which  spectrum is  related  to which  other
spectrum through a rotation or a symmetry.

=head1 USAGE

  raku upd-spectrum-sql.raku a4_b8

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
