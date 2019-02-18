#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 46;
use Statistics::Descriptive::Discrete;
use lib 't/lib';
use Utils qw/array_cmp/;

{
    #check calling methonds before adding data
    my $stats = Statistics::Descriptive::Discrete->new();
    is($stats->mean,undef,"mean should be undef");
    is($stats->count,0,"count should be 0");
}

{
    my $stats = Statistics::Descriptive::Discrete->new();
    #now add some data and compute the statistics
    $stats->add_data(1,2,3,4,5,4,3,2,1,2);

    #3: 
    is($stats->count,10,"Count = 10");

    #4: get_data
    my @d = $stats->get_data();
    my @sorted_data = (1,1,2,2,2,3,3,4,4,5);
    is(array_cmp(@d,@sorted_data),1,"get_data matches");

    #4: min
    is($stats->min,1,"min = 1");

    #5: mindex
    is($stats->mindex,0,"mindex = 0");

    #5: max
    is($stats->max,5,"max = 5");

    #6: maxdex
    is($stats->maxdex,4,"maxdex = 4");

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

   #13: clear
    $stats->clear();
    is($stats->min,undef,"min should be undef now");
    
    #14: clear, check count
    is($stats->count,0,"count should be 0 now");

    #14: now add data and check again
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
    is($stats->mindex,0,"mindex = 0");
    is($stats->maxdex,5,"maxdex = 5");
    $stats->add_data_tuple(0,1);
    is($stats->mindex,9,"mindex = 9");
}

{
    #frequency distribution
    my $stats = Statistics::Descriptive::Discrete->new();
    $stats->add_data(1,1.5,2,2.5,3,3.5,4);
    my $f = $stats->frequency_distribution_ref(2);
    my %freq = (2.5 => 4, 4=>3);
    is_deeply($f,\%freq,"frequency_distribution_ref 2 partitions");

    #cached results
    my $f2 = $stats->frequency_distribution_ref();
    is_deeply($f2,\%freq,"cached frequency_distribution_ref");

    #manual bin sizes
    $stats->clear();
    $stats->add_data_tuple(1,1,2,2,3,3,4,4,5,5,6,6,7,7);
    %freq = (1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7);
    my @bins = (1,2,3,4,5,6,7);
    $f = $stats->frequency_distribution_ref(\@bins);
    is_deeply($f,\%freq,"manual bin sizes");

    #manual bin sizes less than max
    @bins = (2,4,6);
    $f = $stats->frequency_distribution_ref(\@bins);
    %freq = (2=>3,4=>7,6=>11);
    is_deeply($f,\%freq,"manual bin sizes less than max");

    #only 1 data element
    $stats->clear();
    $stats->add_data(1);
    $f = $stats->frequency_distribution_ref(2);
    is($f,undef,"can't compute frequency_distribution with a single data element");

    #only 1 partition
    $stats->clear();
    $stats->add_data(1,2,3);
    $f = $stats->frequency_distribution_ref(1);
    is_deeply($f,{3=>3},"single partition");

    #calling with no params returns last distribution calculated
    $stats->add_data(4);
    $f = $stats->frequency_distribution_ref();
    is_deeply($f,{3=>3},"no parameters returns last distribution");

    # $stats->clear();
    # $stats->add_data_tuple(1,1,2,2,3,3,4,4,5,5,6,6,7,7);
    # %freq = (1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7);
    # my @bins = [1,2,3,4,5,6,7];
    # $f = $stats->frequency_distribution_ref(\@bins);
    # is_deeply($f,\%freq,"frequency distribution bins");

}

{
    # geometric mean
    my $stats = Statistics::Descriptive::Discrete->new();
    $stats->add_data(1,2,3,4);
    my $gm = $stats->geometric_mean;
    cmp_ok(abs($gm-2.213), "<", 0.001,"geometric mean approx 2.213");

    $stats->clear();
    $stats->add_data(4,1,1.0/32.0);
    $gm = $stats->geometric_mean;
    cmp_ok(abs($gm-.5),"<",0.0001,"geometric mean = 0.5");

    # negative value should make mean undefined
    $stats->clear();
    $stats->add_data(-1,2,3,4);
    $gm = $stats->geometric_mean;
    is($gm,undef,"negative values make geometric mean undefined");

    # any zero values make mean 0
    $stats->clear();
    $stats->add_data(0,1,2,3,4);
    $gm = $stats->geometric_mean;
    is($gm,0,"zero values make geometric mean zero");
}

{
    # test normal function of harmonic mean
    my $stat = Statistics::Descriptive::Discrete->new();
    $stat->add_data( 60, 20 );
    my $single_result = $stat->harmonic_mean();
    # TEST
    ok (scalar(abs( $single_result - 30.0 ) < 0.001),
        "test normal function of harmonic mean",
    );
}