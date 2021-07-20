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

unit module explore-common;

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
my Int $E-or-S; # coordinate of the Eastern-most peripheral column and of the Southern-most peripheral line
my @rotation90;
my @symm-h;
my @symm-diag;

sub explore (Str $config, %dispatch) is export {
  my Str $cf = $config.uc;
  unless $cf ~~ /^ 'A' (\d+) '_B' (\d) $ / {
    die "Wrong configuration $config";
  }
  $nb_atoms = + $0;
  $width    = + $1;
  $E-or-S   = $width + 1;

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
      my Int $l-r90 = $c;
      my Int $c-r90 = $width + 1 - $l;
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
  while $not-there - $there > 1 {
    my Int $found  = 0;
    my Int $middle = (($there + $not-there) / 2).floor;
    $cursor = $molecules.find(
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
  if $there == 0 {
    say "starting from scratch";
    $number = 1;
    $molecule = 'O' x $nb_atoms ~ '-' x ($width² - $nb_atoms);
  }
  else {
    $number = $there;
    $cursor = $molecules.find(
        criteria   => ( config => $cf
                      , number => $number
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
    my Str $mol1 = substr($molecule, 0, $pos);
    my Str $mol3 = substr($molecule, $pos + 2);
    $molecule = $mol1 ~ '-O' ~ $mol3.flip;
  }

}

sub new-molecule (Str $cf, Int $number, Str $molecule) {
  #printf "%6d %s\n", $number, $molecule;
  my @box;
  for 1 .. $width -> $l {
    for 1 .. $width -> $c {
      @box[ $l; $c ] = substr($molecule, $width × ($l - 1) + $c - 1, 1);
    }
    @box[ $l     ; 0       ] = '-';
    @box[ $l     ; $E-or-S ] = '-';
    # Well... below, $l is the column, not the line.
    @box[ 0      ; $l      ] = '-';
    @box[ $E-or-S; $l      ] = '-';
  }
  # and do not forget the corners!
  @box[ 0      ; 0       ] = '-';
  @box[ 0      ; $E-or-S ] = '-';
  @box[ $E-or-S; 0       ] = '-';
  @box[ $E-or-S; $E-or-S ] = '-';

  # statistics
  my Int $absorbed-number      = 0;
  my Int $absorbed-max-length  = 0;
  my Int $absorbed-max-turns   = 0;
  my Int $absorbed-tot-length  = 0;
  my Int $absorbed-tot-turns   = 0;
  my Int $reflected-number     = 0;
  my Int $reflected-max-length = 0;
  my Int $reflected-max-turns  = 0;
  my Int $reflected-tot-length = 0;
  my Int $reflected-tot-turns  = 0;
  my Int $out-number           = 0;
  my Int $out-max-length       = 0;
  my Int $out-max-turns        = 0;
  my Int $out-tot-length       = 0;
  my Int $out-tot-turns        = 0;

  my Str $spectrum = ' ' x (4 × $width);
  my Str $marker   = 'a';
  for 0 .. 4 × $width -1 -> $i {
    if substr($spectrum, $i, 1) eq ' ' {
      my ($res, $boxes, $turns) = ray(@box, $i);
      given $res {
        when '@' {
          substr-rw($spectrum, $i, 1) = $res;
          $absorbed-number++;
          $absorbed-tot-length += $boxes;
          $absorbed-tot-turns  += $turns;
          if $absorbed-max-length < $boxes { $absorbed-max-length = $boxes }
          if $absorbed-max-turns  < $turns { $absorbed-max-turns  = $turns }
        }
        when '&' {
          substr-rw($spectrum, $i, 1) = $res;
          $reflected-number++;
          $reflected-tot-length += $boxes;
          $reflected-tot-turns  += $turns;
          if $reflected-max-length < $boxes { $reflected-max-length = $boxes }
          if $reflected-max-turns  < $turns { $reflected-max-turns  = $turns }
        }
        when '?' {
          say "Problem with molecule $molecule and ray $i";
        }
        default {
          substr-rw($spectrum, $i,   1) = $marker;
          substr-rw($spectrum, $res, 1) = $marker;
          ++$marker;
          ++$out-number;
          $out-tot-length += $boxes;
          $out-tot-turns  += $turns;
          if $out-max-length < $boxes { $out-max-length = $boxes }
          if $out-max-turns  < $turns { $out-max-turns  = $turns }
        }
      }
    }
  }
  my BSON::Document $canonical-molecule .= new: (
              config             => $cf
            , number             => $number
            , canonical-number   => $number
            , molecule           => $molecule
            , spectrum           => $spectrum
            , transform          => 'id'
            , dh1                => time-stamp()
            , dh2                => time-stamp
  );

  my @boxes = $molecule.comb;
  my $spectrum-diag1 = $spectrum.flip;
  my %group;
  %group{$molecule} = $canonical-molecule;

  my BSON::Document $rotated180 .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule.flip
            , spectrum           => substr($spectrum, 2 × $width) ~ substr($spectrum, 0, 2 × $width)
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
            , spectrum           => substr($spectrum, 3 × $width) ~ substr($spectrum, 0, 3 × $width)
            , transform          => 'rot90'
            , dh1                => time-stamp
  );
  %group{$molecule-rot90} //= $rotated90;

  my BSON::Document $rotated270 .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-rot90.flip
            , spectrum           => substr($spectrum, $width) ~ substr($spectrum, 0, $width)
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
            , spectrum           => substr($spectrum-diag1, $width) ~ substr($spectrum-diag1, 0, $width)
            , transform          => 'symm-h'
            , dh1                => time-stamp
  );
  %group{$molecule-symmh} //= $symm-h;

  my BSON::Document $symm-v .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-symmh.flip
            , spectrum           => substr($spectrum-diag1, 3 × $width) ~ substr($spectrum-diag1, 0, 3 × $width)
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
            , spectrum           => $spectrum-diag1
            , transform          => 'diag-1'
            , dh1                => time-stamp
  );
  %group{$molecule-diag} //= $diag_1;

  my BSON::Document $diag_2 .= new: (
              config             => $cf
            , number             => 0
            , canonical-number   => $number
            , molecule           => $molecule-diag.flip
            , spectrum           => substr($spectrum-diag1, 2 × $width) ~ substr($spectrum-diag1, 0, 2 × $width)
            , transform          => 'diag-2'
            , dh1                => time-stamp
  );
  %group{$molecule-diag.flip} //= $diag_2;

  for %group.values -> BSON::Document $doc {
    # normalise the spectrum
    $doc<spectrum> = normalise($doc<spectrum>);
    # statistics
    $doc<absorbed-number>      = $absorbed-number     ;
    $doc<absorbed-max-length>  = $absorbed-max-length ;
    $doc<absorbed-max-turns>   = $absorbed-max-turns  ;
    $doc<absorbed-tot-length>  = $absorbed-tot-length ;
    $doc<absorbed-tot-turns>   = $absorbed-tot-turns  ;
    $doc<reflected-number>     = $reflected-number    ;
    $doc<reflected-max-length> = $reflected-max-length;
    $doc<reflected-max-turns>  = $reflected-max-turns ;
    $doc<reflected-tot-length> = $reflected-tot-length;
    $doc<reflected-tot-turns>  = $reflected-tot-turns ;
    $doc<out-number>           = $out-number          ;
    $doc<out-max-length>       = $out-max-length      ;
    $doc<out-max-turns>        = $out-max-turns       ;
    $doc<out-tot-length>       = $out-tot-length      ;
    $doc<out-tot-turns>        = $out-tot-turns       ;
  }

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

sub ray (@box, Int $entry) {
  my Int ($l, $c, $dl, $dc);
  my Str $dir;

  my %dl     = N => -1,  E =>  0,  S => +1,  W =>  0;
  my %dc     = N =>  0,  E => +1,  S =>  0,  W => -1;
  my %turn-l = N => 'W', E => 'N', S => 'E', W => 'S';
  my %turn-r = N => 'E', E => 'S', S => 'W', W => 'N';
  if $entry < $width {
    # Entry 0 to 7 → line 1 to 8, column 0
    $l   =  $entry + 1;
    $c   =  0;
    $dir = 'E';
  }
  elsif $entry < 2 × $width {
    # Entry 8 to 15 → line 9, column 1 to 8
    $l   =  $E-or-S;
    $c   =  $entry + 1 - $width;
    $dir = 'N';
  }
  elsif $entry < 3 × $width {
    # Entry 16 to 23 → line 8 to 1, column 9
    $l   =  3 × $width - $entry;
    $c   =  $E-or-S;
    $dir = 'W';
  }
  else {
    # Entry 24 to 31 → line 0, column 8 to 1
    $l   =  0;
    $c   =  4 × $width - $entry;
    $dir = 'S';
  }

  # Absorbed on entry
  my Int $l-forward = $l + %dl{$dir};
  my Int $c-forward = $c + %dc{$dir};
  #say $l, ' ', $c, ' ', $dir, ' ', $l-forward, ' ', $c-forward, ' ', @box[$l-forward; $c-forward];
  if @box[$l-forward; $c-forward] eq 'O' {
    return '@', 0, 0;
  }

  # Reflected on entry
  my Int $l-left = $l + %dl{$dir} + %dl{%turn-l{$dir}};
  my Int $c-left = $c + %dc{$dir} + %dc{%turn-l{$dir}};
  if @box[$l-left; $c-left] eq 'O' {
    return '&', 0, 0;
  }
  my Int $l-right = $l + %dl{$dir} + %dl{%turn-r{$dir}};
  my Int $c-right = $c + %dc{$dir} + %dc{%turn-r{$dir}};
  if @box[$l-right; $c-right] eq 'O' {
    return '&', 0, 0;
  }

  my $res = '?';
  my Int $length;
  my Int $turns = 0;
  # fail-safe: using a loop with a fixed number of iterations, although
  # this loop is theoretically a "while" loop.
  for (1 .. 2 × $width²) -> Int $i {
    $l += %dl{$dir};
    $c += %dc{$dir};

    # out
    if $c == 0 {
      # For A4_B8, (1, 0) → 1 and (8, 0) → 8 (when 1-based),
      #            (1, 0) → 0 and (8, 0) → 7 (when 0-based)
      $res = $l - 1;
      return $res, $i - 1, $turns;
    }
    if $l == $E-or-S {
      # For A4_B8, (9, 1) → 9 and (9, 8) → 16 (when 1-based),
      #            (9, 1) → 8 and (9, 8) → 15 (when 0-based)
      $res = $c + $width - 1;
      return $res, $i - 1, $turns;
    }
    if $c == $E-or-S {
      # For A4_B8, (8, 9) → 17 and (1, 9) → 24 (when 1-based),
      #            (8, 9) → 16 and (1, 9) → 23 (when 0-based)
      $res = 3 × $width - $l;
      return $res, $i - 1, $turns;
    }
    if $l == 0 {
      # For A4_B8, (0, 8) → 25 and (0, 1) → 32 (when 1-based),
      #            (0, 8) → 24 and (0, 1) → 31 (when 0-based)
      $res = 4 × $width - $c;
      return $res, $i - 1, $turns;
    }

    # absorbed
    $l-forward = $l + %dl{$dir};
    $c-forward = $c + %dc{$dir};
    if @box[$l-forward; $c-forward] eq 'O' {
      return '@', $i, $turns;
    }

    # reflected
    $l-left  = $l + %dl{$dir} + %dl{%turn-l{$dir}};
    $c-left  = $c + %dc{$dir} + %dc{%turn-l{$dir}};
    $l-right = $l + %dl{$dir} + %dl{%turn-r{$dir}};
    $c-right = $c + %dc{$dir} + %dc{%turn-r{$dir}};
    if @box[$l-left; $c-left] eq 'O' && @box[$l-right; $c-right] eq 'O' {
      return '&', $i, $turns;
    }

    # deflected
    if @box[$l-left; $c-left] eq 'O' {
      $dir = %turn-r{$dir};
      $turns++;
    }
    if @box[$l-right; $c-right] eq 'O' {
      $dir = %turn-l{$dir};
      $turns++;
    }
  }
  return '?', 0, 0;

}

sub normalise(Str $str) {
  my %trans   = '@' => '@', '&' =>'&';
  my $symbol  = 'a';
  my @letters = $str.comb;
  for @letters -> $letter is rw {
    unless %trans{$letter} {
      %trans{$letter} = $symbol++;
    }
    $letter = %trans{$letter};      
  }
  return @letters.join;
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

=head1 SYNOPSIS

  raku explore.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box. If necessary, letters C<a> and
C<b> can be converted to upper-case.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD