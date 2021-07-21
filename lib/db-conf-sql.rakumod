#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-

use v6;

unit module db-conf-sql;

my Str $dbname = '/home/jf/Documents/prog/rakudo/black-box/Black-Box.db';
my Int $commit-interval = 500;

sub dbname is export {
  return $dbname;
}

sub commit-interval is export {
  return $commit-interval;
}
