#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Recherche des symétries entre les spectres de la table Spectrums (base de données MongoDB)
#     CLooking for symmetries between the records from the Spectrums table (MongoDB database)
#     Copyright (C) 2021, 2022, 2023 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use BSON::Document;
use upd-spectrum-common;

### Native Raku processing of MongoDB database
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;

my MongoDB::Client     $client        .= new(:uri('mongodb://'));
my MongoDB::Database   $database       = $client.database('Black-Box');
my MongoDB::Collection $configurations = $database.collection('Configurations');
my MongoDB::Collection $molecules      = $database.collection('Molecules');
my MongoDB::Collection $spectrums      = $database.collection('Spectrums');

### External Mongo shell processing of MongoDB database
my Str $mongo  = '/usr/bin/mongo';
my Str $dbname = 'Black-Box';

my %dispatch = canonical-molecules => &canonical-molecules
             , enantiomer-group    => &enantiomer-group
             , read-spectrum       => &read-spectrum
             , update-spectrum     => &update-spectrum
             ;

sub MAIN (Str $config, Bool :$verbose) {
  my Str $cf = $config.uc;
  upd-spectrum($cf, %dispatch, $verbose);
}

sub canonical-molecules(Str $cf) {
  my $script = q:to/EOF/;
    var cf = '?cf?';
    print('trce ' + cf);
    var spc = [];
    db.Spectrums.find({config: cf, transform: '??'})
                .forEach(function(doc) { spc.push(doc.spectrum) });
    //print('trce ' + spc);
    db.Molecules.find({config: cf, transform: 'id', spectrum: { '$in': spc }})
                .sort({number: 1})
                .forEach(function(doc) { print('data ' + doc.number) });
EOF
  # $cf has been checked, validated ans sanitised in calling function upd-spectrum.
  # So the "Bobby Tables" problem has been avoided.
  $script ~~ s/\?cf\?/$cf/;

  my Int @number;
  my $proc = run($mongo, $dbname, '--eval', $script, :out);
  for $proc.out.lines -> Str $line {
    if $line ~~ /^ 'data' \s+ (\d+) $/ {
      @number.push( + $0 );
    }
    else {
      say $line;
    }
  }
  say @number;
  return @number;
}

sub enantiomer-group(Str $cf, Int $canonical-number) {
  my BSON::Document @group;
  my BSON::Document $molecule-doc;
  my MongoDB::Cursor $cursor = $molecules.find(
        criteria   => ( config           => $cf
                      , canonical-number => $canonical-number
        ),
      );
  while $cursor.fetch -> BSON::Document $doc {
    @group.push($doc);
  }
  $cursor.kill;
  return @group.sort: { $_<number> };
}

sub read-spectrum(Str $cf, Str $spectrum) {
  my BSON::Document  $spectrum-doc;
  my MongoDB::Cursor $cursor = $spectrums.find(
        criteria   => ( config   => $cf
                      , spectrum => $spectrum
        ),
      );
  while $cursor.fetch -> BSON::Document $doc {
    $spectrum-doc = $doc;
    last;
  }
  $cursor.kill;
  return $spectrum-doc;
}

sub update-spectrum(BSON::Document $spectrum) {
   my BSON::Document $req .= new: (
      update => 'Spectrums',
      updates => [ (
        q =>  ( config   => $spectrum<config>
              , spectrum => $spectrum<spectrum>
              ),
        u => $spectrum,
      ),
    ],
  );
  my BSON::Document $doc = $database.run-command($req);
  if $doc<ok> == 0 {
    say "update ok : ", $doc<ok>, " nb : ", $doc<n>;
  }
}


=begin POD

=encoding utf8

=head1 NAME

upd-spectrum-mongo.raku -- looking for symmetries between the spectrums, MongoDB variant

=head1 DESCRIPTION

This  programme updates  the  C<transform> field  of the  C<Spectrums>
documents, so  we can  see which  spectrum is  related to  which other
spectrum through a rotation or a symmetry.

=head1 USAGE

  raku upd-spectrum-mongo.raku a4_b8

or

  raku upd-spectrum-mongo.raku --verbose a4_b8

=head2 Parameters

=item verbose switch

By using C<--verbose>,  the user can request a verbose  mode where the
programme  gives a  detailed description  of  the choices  and of  the
updates it makes.

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, 2022, 2023, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
