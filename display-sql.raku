#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Affichage des molécules dans Black Box (base MongoDB)
#     Display some molecules for a Black Box configuration (MongoDB version)
#     Copyright (C) 2021, 2022 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use DBIish;
use BSON::Document;
use display-common;
use db-conf-sql;

my $dbh = DBIish.connect('SQLite', database => dbname());

my Int $width;

multi sub MAIN (Str :$config, Int :$from, Int :$to) {
  my Str $cf = $config.uc;
  check-conf($cf);

  say "from $from to $to";
  my $sth = $dbh.prepare('select * from Molecules where config = ? and number >= ? and number <= ? order by number');
  my @result  = $sth.execute($cf, + $from, + $to).allrows(:array-of-hash);
  for @result -> $result {
    display($cf, convert-molecule($result))
  }
}

multi sub MAIN (Str :$config, *@num) {
  my Str $cf = $config.uc;
  check-conf($cf);

  my BSON::Document @doc;

  for (@num) -> Int $num {
    my $sth = $dbh.prepare('select * from Molecules where config = ? and number = ?');
    my $result  = $sth.execute($cf, + $num).row(:hash);
    if $result<config> {
      display($cf, convert-molecule($result))
    }
  }
}

multi sub MAIN (Str :$config, Str :$spectrum) {
  my Str $cf = $config.uc;
  check-conf($cf);

  my $sth = $dbh.prepare('select * from Molecules where config = ? and spectrum = ? order by number');
  my @result  = $sth.execute($cf, $spectrum).allrows(:array-of-hash);
  for @result -> $result {
    display($cf, convert-molecule($result))
  }
}

sub check-conf(Str $cf) {
  unless $cf ~~ /^ 'A' (\d+) '_B' (\d) $ / {
    die "Wrong configuration $cf";
  }
  $width    = + $1;

  my $sth = $dbh.prepare('select * from Configurations where config = ?');
  my $doc = $sth.execute($cf).row(:hash);
  unless $doc {
    die "Unknown configuration $cf";
  }
}

sub convert-molecule ($result) {
  my BSON::Document $molecule-doc .= new;
  for $result.keys -> $key {
    $molecule-doc{$key.trans('_' => '-')} = $result{$key};
  }
  return $molecule-doc;

}


=begin POD

=encoding utf8

=head1 NAME

display-sql.raku -- Display some molecules and their spectrum for a Black Box configuration

=head1 DESCRIPTION

This program extracts the molecules  for a Black Box configuration and
a range of numbers and displays them.

=head1 SYNOPSIS

  raku display-sql.raku --config=a4_b8 --from=10 --to=19
  raku display-sql.raku --config=a4_b4 --spectrum='@&&@@&@a@@a@&@@@'
  reku display-sql.raku --config=a4_b4 1 3 5

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

Copyright (C) 2021, 2022, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
