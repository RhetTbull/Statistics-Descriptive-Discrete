# NAME

Statistics::Descriptive::Discrete - Compute descriptive statistics for discrete data sets.

To install, use the CPAN module (https://metacpan.org/pod/Statistics::Descriptive::Discrete).

# SYNOPSIS

```perl
    use Statistics::Descriptive::Discrete;

    my $stats = new Statistics::Descriptive::Discrete;
    $stats->add_data(1,10,2,1,1,4,5,1,10,8,7);
    print "count = ",$stats->count(),"\n";
    print "uniq  = ",$stats->uniq(),"\n";
    print "sum = ",$stats->sum(),"\n";
    print "min = ",$stats->min(),"\n";
    print "min index = ",$stats->mindex(),"\n";
    print "max = ",$stats->max(),"\n";
    print "max index = ",$stats->maxdex(),"\n";
    print "mean = ",$stats->mean(),"\n";
    print "geometric mean = ",$stats->geometric_mean(),"\n";
    print "harmonic mean = ", $stats->harmonic_mean(),"\n";
    print "standard_deviation = ",$stats->standard_deviation(),"\n";
    print "variance = ",$stats->variance(),"\n";
    print "sample_range = ",$stats->sample_range(),"\n";
    print "mode = ",$stats->mode(),"\n";
    print "median = ",$stats->median(),"\n";
    my $f = $stats->frequency_distribution_ref(3);
    for (sort {$a <=> $b} keys %$f) {
      print "key = $_, count = $f->{$_}\n";
    }
```
# DESCRIPTION

This module provides basic functions used in descriptive statistics.
It borrows very heavily from Statistics::Descriptive::Full
(which is included with Statistics::Descriptive) with one major
difference.  This module is optimized for discretized data 
e.g. data from an A/D conversion that  has a discrete set of possible values.  
E.g. if your data is produced by an 8 bit A/D then you'd have only 256 possible 
values in your data  set.  Even though you might have a million data points, 
you'd only have 256 different values in those million points.  Instead of storing the 
entire data set as Statistics::Descriptive does, this module only stores
the values seen and the number of times each value occurs.

For very large data sets, this storage method results in significant speed
and memory improvements.  For example, for an 8-bit data set (256 possible values),
with 1,000,000 data points,  this module is about 10x faster than Statistics::Descriptive::Full 
or Statistics::Descriptive::Sparse.  

Statistics::Descriptive run time is a factor of the size of the data set. In particular,
repeated calls to `add_data` are slow.  Statistics::Descriptive::Discrete's `add_data` is 
optimized for speed.  For a give number of data points, this module's run time will increase 
as the number of unique data values in the data set increases. For example, while this module
runs about 10x the speed of Statistics::Descriptive::Full for an 8-bit data set, the 
run speed drops to about 3x for an equivalent sized 20-bit data set.  

See sdd\_prof.pl in the examples directory to play with profiling this module against 
Statistics::Descriptive::Full.

# METHODS

- $stat = Statistics::Descriptive::Discrete->new();

    Create a new statistics object.

- $stat->add\_data(1,2,3,4,5);

    Adds data to the statistics object.  Sets a flag so that
    the statistics will be recomputed the next time they're
    needed.

- $stat->add\_data\_tuple(1,2,42,3);

    Adds data to the statistics object where every two elements
    are a value and a count (how many times did the value occur?)
    The above is equivalent to `$stat->add_data(1,1,42,42,42);`
    Use this when your data is in a form isomorphic to 
    ($value, $occurrence).

- $stat->max();

    Returns the maximum value of the data set.

- $stat->min();

    Returns the minimum value of the data set.

- $stat->mindex();

    Returns the index of the minimum value of the data set.  
    The index returned is the first occurence of the minimum value.

    Note: the index is determined by the order data was added using add\_data() or add\_data\_tuple().
    It is meaningless in context of get\_data() as get\_data() does not return values in the same
    order in which they were added.  This behavior is different than Statistics::Descriptive which
    does preserve order.  

- $stat->maxdex();

    Returns the index of the maximum value of the data set.  
    The index returned is the first occurence of the maximum value.

    Note: the index is determined by the order data was added using 
    `add_data()` or `add_data_tuple()`. It is meaningless in context of 
    `get_data()` as `get_data()` does not return values in the same
    order in which they were added.  This behavior is different than 
    Statistics::Descriptive which does preserve order.  

- $stat->count();

    Returns the total number of elements in the data set.

- $stat->uniq();

    If called in scalar context, returns the total number of unique elements in the data set.
    For example, if your data set is (1,2,2,3,3,3), uniq will return 3.  

    If called in array context, returns an array of each data value in the data set in sorted order.
    In the above example, `@uniq = $stats->uniq();` would return (1,2,3)

    This function is specific to Statistics::Descriptive::Discrete
    and is not implemented in Statistics::Descriptive.

    It is useful for getting a frequency distribution for each discrete value in the data the set:
    ```perl
        my $stats = Statistics::Descriptive::Discrete->new();
        $stats->add_data_tuple(1,1,2,2,3,3,4,4,5,5,6,6,7,7);
        my @bins = $stats->uniq();
        my $f = $stats->frequency_distribution_ref(\@bins);
        for (sort {$a <=> $b} keys %$f) {
            print "value = $_, count = $f->{$_}\n";
        }
    ```
- $stat->sum();

    Returns the sum of all the values in the data set.

- $stat->mean();

    Returns the mean of the data.

- $stat->harmonic\_mean();

    Returns the harmonic mean of the data.  Since the mean is undefined
    if any of the data are zero or if the sum of the reciprocals is zero,
    it will return undef for both of those cases.

- $stat->geometric\_mean();

    Returns the geometric mean of the data.  Returns `undef` if any of the data
    are less than 0. Returns 0 if any of the data are 0.

- $stat->median();

    Returns the median value of the data.

- $stat->mode();

    Returns the mode of the data.

- $stat->variance();

    Returns the variance of the data.

- $stat->standard\_deviation();

    Returns the standard\_deviation of the data.

- $stat->sample\_range();

    Returns the sample range (max - min) of the data set.

- $stat->frequency\_distribution\_ref($num\_partitions);
- $stat->frequency\_distribution\_ref(\\@bins);
- $stat->frequency\_distribution\_ref();

    `frequency_distribution_ref($num_partitions)` slices the data into
    `$num_partitions` sets (where $num\_partitions is greater than 1) and counts
    the number of items that fall into each partition. It returns a reference to a
    hash where the keys are the numerical values of the partitions used. The
    minimum value of the data set is not a key and the maximum value of the data
    set is always a key. The number of entries for a particular partition key are
    the number of items which are greater than the previous partition key and less
    then or equal to the current partition key. As an example,
    ```perl
        $stat->add_data(1,1.5,2,2.5,3,3.5,4);
        $f = $stat->frequency_distribution_ref(2);
        for (sort {$a <=> $b} keys %$f) {
           print "key = $_, count = $f->{$_}\n";
        }
    ```
    prints

        key = 2.5, count = 4
        key = 4, count = 3

    since there are four items less than or equal to 2.5, and 3 items
    greater than 2.5 and less than 4.

    `frequency_distribution_ref(\@bins)` provides the bins that are to be used
    for the distribution.  This allows for non-uniform distributions as
    well as trimmed or sample distributions to be found.  `@bins` must
    be monotonic and must contain at least one element.  Note that unless the
    set of bins contains the full range of the data, the total counts returned will
    be less than the sample size.

    Calling `frequency_distribution_ref()` with no arguments returns the last
    distribution calculated, if such exists.

- my %hash = $stat->frequency\_distribution($partitions);
- my %hash = $stat->frequency\_distribution(\\@bins);
- my %hash = $stat->frequency\_distribution();

    Same as `frequency_distribution_ref()` except that it returns the hash
    clobbered into the return list. Kept for compatibility reasons with previous
    versions of Statistics::Descriptive::Discrete and using it is discouraged.

    Note: in earlier versions of Statistics:Descriptive::Discrete, `frequency_distribution()`
    behaved differently than the Statistics::Descriptive implementation.  Any code that uses
    this function should be carefully checked to ensure compatability with the current 
    implementation.

- $stat->get\_data();

    Returns a copy of the data array.  Note: This array could be
    very large and would thus defeat the purpose of using this
    module.  Make sure you really need it before using get\_data().

    The returned array contains the values sorted by value.  It does
    not preserve the order in which the values were added.  Preserving
    order would defeat the purpose of this module which trades speed
    and memory usage over preserving order.  If order is important,
    use Statistics::Descriptive.

- $stat->clear();

    Clears all data and resets the instance as if it were newly created

    Effectively the same as

    ```perl
        my $class = ref($stat);
        undef $stat;
        $stat = new $class;
    ```
# NOTE

The interface for this module strives to be identical to Statistics::Descriptive.  
Any differences are noted in the description for each method.

# BUGS

- Code for calculating mode is not as robust as it should be.

# TODO

- Add rest of methods (at least ones that don't depend on original order of data) 
from Statistics::Descriptive

# AUTHOR

Rhet Turnbull, rturnbull+cpan@gmail.com

# CREDIT

Thanks to the following individuals for finding bugs, providing feedback, 
and submitting changes:

- Peter Dienes for finding and fixing a bug in the variance calculation.
- Bill Dueber for suggesting the add\_data\_tuple method.

# COPYRIGHT

    Copyright (c) 2002, 2019 Rhet Turnbull. All rights reserved.  This
    program is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

    Portions of this code is from Statistics::Descriptive which is under
    the following copyrights:

    Copyright (c) 1997,1998 Colin Kuskie. All rights reserved.  This
    program is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

    Copyright (c) 1998 Andrea Spinelli. All rights reserved.  This program
    is free software; you can redistribute it and/or modify it under the
    same terms as Perl itself.

    Copyright (c) 1994,1995 Jason Kastner. All rights
    reserved.  This program is free software; you can redistribute it
    and/or modify it under the same terms as Perl itself.

# SEE ALSO

Statistics::Descriptive

Statistics::Discrete
