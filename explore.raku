#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Exploration exhaustive des molécules dans Black Box
#     Exploring all the molecules for a Black Box configuration
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

my @rotation90;
my @symm-h;
my @symm-diag;

sub MAIN (Str $config) {
  my Str $cf = $config.uc;
  unless $cf ~~ /^ 'A' (\d+) '_B' (\d) $ / {
    die "Wrong configuration $config";
  }
  my Int $nb_atoms = + $0;
  my Int $width    = + $1;

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

  for 1 .. $width -> $l {
    for 1 .. $width -> $c {
      my $l-r90 = $c;
      my $c-r90 = $width + 1 - $l;
      @rotation90[ $width × ($l - 1) + $c - 1 ] = $width × ($l-r90 - 1) + $c-r90 - 1;
      @symm-h[     $width × ($l - 1) + $c - 1 ] = $width × ($l     - 1) + $width - $c;
      @symm-diag[  $width × ($l - 1) + $c - 1 ] = $width × ($c     - 1) + $l - 1;
    }
  }

  say "$nb_atoms atoms in a $width × $width square";

  my Str $molecule;
  my Int $number;

  my BSON::Document $req;
  my BSON::Document $result;

  # Finding the last number processed in the previous run, which will be the first
  # one to be processed in the current run. In Mongo-shell, it would be easy:
  #         db.Molecules.find({ config: $cf} ).sort({number: -1}).limit(1)
  # But in Raku, we have to scan all the molecules for the current configuration
  # and store the maximum value of the 'number' property. Not a full table scan
  # but nearly so, especially with the A4_B8 configuration which may have up to 365376
  # molecules. I do not know how to add a 'sort' parameter
  # to the 'find' method. 'number-to-return' is a fine substitute for "limit()',
  # but there is nothing similar for 'sort()'
  # A bad anti-optimization, but I cannot do otherwise (or maybe migrate to SQLite?)
  $number   = 1;
  $cursor = $molecules.find(
      criteria   => ( 'config' => $cf,  ),
      projection => ( 'number' => 1, ),
    );
  while $cursor.fetch -> BSON::Document $doc {
    if $doc<number> > $number {
      $number = $doc<number>;
    }
  }
  $cursor.kill;
  if $number == 1 {
    say "starting from scratch";
    $molecule = 'O' x $nb_atoms ~ '-' x ($width² - $nb_atoms);
  }
  else {
    $cursor = $molecules.find(
        criteria   => ( 'config' => $cf,
                        'number' => $number,
        ),
      );
    while $cursor.fetch -> BSON::Document $doc {
      $molecule = $doc<molecule>;

      # If the highest numbered molecule is the canonical molecule of a group
      # of enantiomers, reprocessing it will recreate the group of enantiomers.
      # So we delete this group before recreating. A very minor anti-optimization.
      #
      # If the highest numbered molecule is not the canonical molecule of
      # its group, it will be modified again. A very very very minor anti-optimization.
      if $doc<number> == $doc<canonical-number> {
        $req .= new: (
          delete    => 'Molecules',
          deletes   => [ (
                q     => ( config => ($cf), canonical-number => ($number), ),
                limit => 0,
          ), ],
        );
        $result = $database.run-command($req);
        say "Clean-up molecules     ok : ", $result<ok>, " nb : ", $result<n>;
      }
    }
    $cursor.kill;
    say "restarting from $number $molecule";
  }

  loop {
    my Int $found = 0;
    my BSON::Document $enantiomer;
    $cursor = $molecules.find(
        criteria   => ( config   => $cf
                      , molecule => $molecule
        ),
      );
    while $cursor.fetch -> BSON::Document $doc {
      $found = 1;
      $enantiomer = $doc;
    }
    $cursor.kill;
    if $found {
      $enantiomer<number> = $number;
      $enantiomer<dh2>    = time-stamp;
      upd-molecule($enantiomer);
    }
    else {
      new-molecule($cf, $number, $molecule);
    }

    last unless $molecule ~~ /'O-'/;

    ++$number;
    my Int $pos = rindex($molecule, 'O-');
    my $mol1 = substr($molecule, 0, $pos);
    my $mol3 = substr($molecule, $pos + 2);
    $molecule = $mol1 ~ '-O' ~ $mol3.flip;
  }

}

sub new-molecule (Str $cf, Int $number, Str $molecule) {
  #printf "%6d %s\n", $number, $molecule;
  my BSON::Document $canonical-molecule .= new: (
              config             => $cf
            , number             => $number
            , canonical-number   => $number
            , molecule           => $molecule
            , transform          => 'id'
            , dh1                => time-stamp
  );

  my @boxes = $molecule.comb;
  my %group;
  %group{$molecule} = $canonical-molecule;

  my BSON::Document $rotated180 .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule.flip
            , transform          => 'rot180'
            , dh1                => time-stamp
  );
  %group{$molecule.flip} //= $rotated180;

  my Str $molecule-rot90 = @boxes[@rotation90].join;
  my BSON::Document $rotated90 .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-rot90
            , transform          => 'rot90'
            , dh1                => time-stamp
  );
  %group{$molecule-rot90} //= $rotated90;

  my BSON::Document $rotated270 .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-rot90.flip
            , transform          => 'rot270'
            , dh1                => time-stamp
  );
  %group{$molecule-rot90.flip} //= $rotated270;

  my Str $molecule-symmh = @boxes[@symm-h].join;
  my BSON::Document $symm-h    .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-symmh
            , transform          => 'symm-h'
            , dh1                => time-stamp
  );
  %group{$molecule-symmh} //= $symm-h;

  my BSON::Document $symm-v .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-symmh.flip
            , transform          => 'symm-v'
            , dh1                => time-stamp
  );
  %group{$molecule-symmh.flip} //= $symm-v;

  my Str $molecule-diag = @boxes[@symm-diag].join;
  my BSON::Document $diag_1 .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-diag
            , transform          => 'diag-1'
            , dh1                => time-stamp
  );
  %group{$molecule-diag} //= $diag_1;

  my BSON::Document $diag_2 .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-diag.flip
            , transform          => 'diag-2'
            , dh1                => time-stamp
  );
  %group{$molecule-diag.flip} //= $diag_2;

  my BSON::Document $req;
  my BSON::Document $result;

  $req .= new: (
    insert    => 'Molecules',
    documents => [ %group.values ],
  );
  $result = $database.run-command($req);
  unless $result<ok> {
    die "Problem when storing molecule # $number '$molecule'";
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

sub time-stamp {
  return sprintf "%04d-%02d-%02dT%02d:%02d:%02d", .year, .month, .day, .hour, .minute, .whole-second
           given DateTime.now.utc;
}

=begin POD

=encoding utf8

=head1 NAME

explore.raku -- Exploring all the molecules for a Black Box configuration

=head1 DESCRIPTION

This  program   lists  all   possible  molecules   for  a   Black  Box
configuration,  compute   their  spectrum   and  store  it   into  the
C<Molecules> collection of the database.

=head1 LANCEMENT

  raku explore.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
