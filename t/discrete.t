#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;

use Statistics::Descriptive::Discrete;

{
    my $stats = Statistics::Descriptive::Discrete->new();
    #now add some data and compute the statistics
    $stats->add_data(1,2,3,4,5,4,3,2,1,2);

    #3: 
    is($stats->count,10,"Count = 10");
 
    #4: min
    is($stats->min,1,"min = 1");

    #5: max
    is($stats->max,5,"max = 5");

    #6: uniq
   is($stats->uniq,5,"uniq = 5");

    #7: mean
    is($stats->mean,2.7,"mean = 2.7");

    #8: sample_range
    is($stats->sample_range,4,"sample range = 4");

    #9: mode
    is($stats->mode,2, "mode = 2");

    #10: median
    is($stats->median,2.5,"median = 2.5");


    #11: standard_deviation
    ok(abs($stats->standard_deviation-1.33749350984926) < 0.00001,"standard_deviation ok");

    #12: variance
    ok(abs($stats->variance-1.78888888888) < 0.00001,"variance ok");
}

{
    #13: variance for small values
    my $stats = Statistics::Descriptive::Discrete->new;
    my @data;
    for (my $i=0;$i<45;$i++)
    {
        push @data,0.01113;
    }
    $stats->add_data(@data);
    ok($stats->variance > 0,"variance ok");
}

{
    #14 add_data_tuple
    my $stats = Statistics::Descriptive::Discrete->new;
    $stats->add_data_tuple(2,2);
    $stats->add_data_tuple(3,3,4,4);
    is($stats->uniq,3,"uniq = 3");
    is($stats->sum,29,"sum = 29");
    is($stats->count,9,"count = 9");
}

