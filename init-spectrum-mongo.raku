#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation de la table Spectrums pour une configuration de Black Box (base de données MongoDB)
#     Initialising the Spectrums table for a Black Box configuration (MongoDB database)
#     Copyright (C) 2021, 2022 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';

### Native Raku processing of MongoDB database
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;

my MongoDB::Client     $client        .= new(:uri('mongodb://'));
my MongoDB::Database   $database       = $client.database('Black-Box');
my MongoDB::Collection $configurations = $database.collection('Configurations');
my MongoDB::Collection $molecules      = $database.collection('Molecules');
my MongoDB::Collection $spectrums      = $database.collection('Spectrums');

### External Mongo shell processing of MongoDB database
my $mongo  = '/usr/bin/mongo';
my $dbname = 'Black-Box';

sub MAIN (Str $config) {
  my $cf = $config.uc;
  unless $cf ~~ / ^ 'A' <[0..9]> ** 1..2 '_B' <[0..9]> $ / {
    die "Invalid configuration $cf";
  }
  purge-Spectrums($cf);
  fill-Spectrums($cf);
}

sub purge-Spectrums(Str $cf) {
  my BSON::Document $req .= new: (
          delete    => 'Spectrums',
          deletes   => [ (
                q     => ( config => ($cf), ),
                limit => 0,
          ), ],
        );
  my BSON::Document $result = $database.run-command($req);
  say "Clean-up spectrums ok : ", $result<ok>, " nb : ", $result<n>;
}

sub fill-Spectrums(Str $cf) {
  my $aggreg = q:to/EOF/;
  db.Molecules.aggregate({'\$match':   {config: '?1?'}},
                         {'\$project': {_id: 0, config:1, spectrum: 1}},
                         {'\$group':   { '_id':    '\$spectrum'
                                       , 'config': {'\$first': '\$config'}
                                       , 'count':  {'\$sum': 1}}},
                         {'\$match':   {'count': {'\$ne': 1}}},
                         {'\$sort':    {'count': -1}}
                         ).forEach(function(doc){ print(doc.config + ' ' + doc._id + ' ' + doc.count);});
EOF

  # $cf has been checked, validated ans sanitised in MAIN. So the "Bobby Tables"
  # problem has been dealt with.
  $aggreg ~~ s/\?1\?/$cf/;
  say $aggreg;

  my $proc = run($mongo, $dbname, '--eval', $aggreg, :out);
  for $proc.out.lines -> $s {
    if $s ~~ /^ ('A' \d+ '_B' \d+) \s+ (\S+) \s+ (\d+) $/ {
      my BSON::Document $spectrum .= new: ( config           => ~ $0
                                          , spectrum         => ~ $1
                                          , nb_mol           => + $2
                                          , transform        => '??'
                                          , canonical-number => 0
                                          );
      my BSON::Document $req;
      my BSON::Document $result;
      $req .= new: (
        insert    => 'Spectrums',
        documents => [ $spectrum ],
      );
      $result = $database.run-command($req);
      unless $result<ok> {
        die "Problem when storing spectrum  $spectrum<spectrum>";
      }
    }
  }

}

=begin POD

=encoding utf8

=head1 NAME

init-spectrum-mongo.raku -- loading the Spectrums table for a Black Box configuration, MongoDB variant

=head1 DESCRIPTION

This programme  aggregates the C<spectrum> fields  of the C<Molecules>
collection  for  a  given  Black  Box  configuration  and  stores  the
aggregate values into the C<Spectrums> collection.

Only  spectrums  leading  to   ambiguous  games,  that  is,  spectrums
appearing in  more than  one molecule are  stored in  the C<Spectrums>
collection.

=head1 USAGE

  raku init-spectrum-mongo.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, 2022, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
