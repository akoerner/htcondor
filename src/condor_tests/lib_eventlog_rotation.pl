#! /usr/bin/env perl
##**************************************************************
##
## Copyright (C) 1990-2008, Condor Team, Computer Sciences Department,
## University of Wisconsin-Madison, WI.
##
## Licensed under the Apache License, Version 2.0 (the "License"); you
## may not use this file except in compliance with the License.  You may
## obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
##**************************************************************

use strict;
use warnings;
use Cwd;

my $testname = 'lib_eventlog_rotation - runs eventlog rotation tests';
my $testbin = "../testbin_dir";
my %programs = ( reader		=> "$testbin/test_log_reader",
		 reader_state	=> "$testbin/test_log_reader_state",
		 writer		=> "$testbin/test_log_writer", );

my $event_size = ( 100000 / 1160 );
my @tests =
    (

     # Default test
     {
	 name => "defaults",
	 config => {
	     "EVENT_LOG"		=> "EventLog",
	     #"EVENT_LOG_COUNT_EVENTS"	=> "FALSE",
	     #"ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     #"EVENT_LOG_MAX_ROTATIONS"	=> 1,
	     #"EVENT_LOG_MAX_SIZE"	=> -1,
	     #"MAX_EVENT_LOG"		=> 1000000,
	 },
	 loops				=> 1,
	 size_mult			=> 1.25,
	 writer => {
	 },
     },
     {
	 name		=> "no_rotations_1",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "FALSE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     #"EVENT_LOG_MAX_ROTATIONS"	=> 0,
	     "EVENT_LOG_MAX_SIZE"	=> 0,
	     #"MAX_EVENT_LOG"		=> 0,
	 },
	 loops				=> 1,
	 size_mult			=> 1.25,
	 writer => {
	 },
     },

     {
	 name		=> "no_rotations_2",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "FALSE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     #"EVENT_LOG_MAX_ROTATIONS"	=> 0,
	     "EVENT_LOG_MAX_SIZE"	=> 0,
	     #"MAX_EVENT_LOG"		=> 0,
	 },
	 loops				=> 1,
	 size_mult			=> 1.25,
	 writer => {
	 },
     },
     {
	 name		=> "no_rotations_3",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "FALSE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     #"EVENT_LOG_MAX_ROTATIONS"	=> 0,
	     #"EVENT_LOG_MAX_SIZE"	=> 0,
	     "MAX_EVENT_LOG"		=> 0,
	 },
	 loops				=> 1,
	 size_mult			=> 1.25,
	 writer => {
	 },
     },

     {
	 name		=> "w_old_rotations",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "TRUE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     "EVENT_LOG_MAX_ROTATIONS"	=> 1,
	     "EVENT_LOG_MAX_SIZE"	=> 10000,
	     #"MAX_EVENT_LOG"		=> -1,
	 },
	 loops				=> 1,
	 size_mult			=> 1.25,
	 writer => {
	 },
     },

     {
	 name		=> "w_2_rotations",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "TRUE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     "EVENT_LOG_MAX_ROTATIONS"	=> 2,
	     "EVENT_LOG_MAX_SIZE"	=> 10000,
	     #"MAX_EVENT_LOG"		=> -1,
	 },
	 loops				=> 1,
	 size_mult			=> 1.25,
	 writer => {
	 },
     },

     {
	 name		=> "w_5_rotations",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "TRUE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     "EVENT_LOG_MAX_ROTATIONS"	=> 5,
	     "EVENT_LOG_MAX_SIZE"	=> 10000,
	     #"MAX_EVENT_LOG"		=> -1,
	 },
	 loops				=> 1,
	 size_mult			=> 1.25,
	 writer => {
	 },
     },

     {	
	 name		=> "w_20_rotations",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "TRUE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     "EVENT_LOG_MAX_ROTATIONS"	=> 20,
	     "EVENT_LOG_MAX_SIZE"	=> 10000,
	     #"MAX_EVENT_LOG"		=> -1,
	 },
	 loops				=> 1,
	 size_mult			=> 1.25,
	 writer => {
	 },
     },

     {
	 name		=> "reader_simple",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "TRUE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     "EVENT_LOG_MAX_ROTATIONS"	=> 0,
	     #"EVENT_LOG_MAX_SIZE"	=> 10000,
	     #"MAX_EVENT_LOG"		=> -1,
	 },
	 loops				=> 1,
	 size_mult			=> 0.1,
	 writer => {
	 },
	 reader => {
	 },
     },

     {
	 name		=> "reader_old_rotations",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "TRUE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     "EVENT_LOG_MAX_ROTATIONS"	=> 1,
	     "EVENT_LOG_MAX_SIZE"	=> 10000,
	 },
	 loops				=> 1,
	 size_mult			=> 0.95,
	 writer => {
	 },
	 reader => {
	     persist			=> 1,
	 },
     },

     {
	 name		=> "reader_2_rotations",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "TRUE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     "EVENT_LOG_MAX_ROTATIONS"	=> 2,
	     "EVENT_LOG_MAX_SIZE"	=> 10000,
	 },
	 loops				=> 1,
	 size_mult			=> 0.95,
	 writer => {
	 },
	 reader => {
	     persist			=> 1,
	 },
     },

     {
	 name		=> "reader_20_rotations",
	 config		=> {
	     "EVENT_LOG"		=> "EventLog",
	     "EVENT_LOG_COUNT_EVENTS"	=> "TRUE",
	     "ENABLE_USERLOG_LOCKING"	=> "TRUE",
	     "EVENT_LOG_MAX_ROTATIONS"	=> 20,
	     "EVENT_LOG_MAX_SIZE"	=> 10000,
	 },
	 loops				=> 1,
	 size_mult			=> 0.98,
	 writer => {
	 },
	 reader => {
	     persist			=> 1,
	 },
     },
);

sub usage( )
{
    print
	"usage: $0 [options] test-name\n" .
	"  -l|--list     list names of tests\n" .
	"  -f|--force    force overwrite of test directory\n" .
	"  -n|--no-exec  no execute / test mode\n" .
	"  -d|--debug    enable D_FULLDEBUG debugging\n" .
	"  --loops=<n>   Override # of loops in test\n" .
	"  -v|--verbose  increase verbose level\n" .
	"  -s|--stop     stop after errors\n" .
	"  --vg-writer   run writer under valgrind\n" .
	"  --vg-reader   run reader under valgrind\n" .
	"  -q|--quiet    cancel debug & verbose\n" .
	"  -h|--help     this help\n";
}

sub RunWriter( $$$$$ );
sub RunReader( $$$ );
sub ReadEventlogs( $$ );
sub ProcessEventlogs( $$ );
sub CheckWriterOutput( $$$$ );
sub CheckReaderOutput( $$$$ );
sub GatherData( $ );

my %settings =
(
 verbose		=> 0,
 debug			=> 0,
 execute		=> 1,
 stop			=> 0,
 force			=> 0,
 valgrind_writer	=> 0,
 valgrind_reader	=> 0,
 );
foreach my $arg ( @ARGV ) {
    if ( $arg eq "-f"  or  $arg eq "--force" ) {
	$settings{force} = 1;
    }
    elsif ( $arg eq "-l"  or  $arg eq "--list" ) {
	foreach my $test ( @tests ) {
	    print "  " . $test->{name} . "\n";
	}
	exit(0);
    }
    elsif ( $arg eq "-n"  or  $arg eq "--no-exec" ) {
	$settings{execute} = 0;
    }
    elsif ( $arg eq "-s"  or  $arg eq "--stop" ) {
	$settings{stop} = 1;
    }
    elsif ( $arg eq "--vg-writer" ) {
	$settings{valgrind_writer} = 1;
    }
    elsif ( $arg eq "--vg-reader" ) {
	$settings{valgrind_reader} = 1;
    }
    elsif ( $arg =~ /^--loops=(\d+)$/ ) {
	$settings{loops} = $1;
    }
    elsif ( $arg eq "-v"  or  $arg eq "--verbose" ) {
	$settings{verbose}++;
    }
    elsif ( $arg eq "-d"  or  $arg eq "--debug" ) {
	$settings{debug} = 1;
    }
    elsif ( $arg eq "-q"  or  $arg eq "--quiet" ) {
	$settings{verbose} = 0;
	$settings{debug} = 0;
    }
    elsif ( $arg eq "-h"  or  $arg eq "--help" ) {
	usage( );
	exit(0);
    }
    elsif ( !($arg =~ /^-/)  and !exists($settings{name}) ) {
	if ( $arg =~ /(\w+?)(?:_(\d+)_loops)/ ) {
	    $settings{name} = $1;
	    $settings{loops} = $2;
	}
	else {
	    $settings{name} = $arg;
	}
    }
    else {
	print STDERR "Unknown argument $arg\n";
	usage( );
	exit(1);
    }
}
if ( !exists $settings{name} ) {
    usage( );
    exit(1);
}

my $test;
foreach my $t ( @tests )
{
    if ( $t->{name} eq $settings{name} ) {
	$test = $t;
	last;
    }
}

if ( ! defined($test) ) {
    die "Unknown test name: $settings{name}";
}

my $dir = "test-eventlog_rotation-" . $settings{name};
if ( exists $settings{loops} ) {
    $dir .= "_".$settings{loops}."_loops";
}
my $fulldir = getcwd() . "/$dir";
if ( -d $dir  and  $settings{force} ) {
    system( "/bin/rm", "-fr", $dir );
}
if ( -d $dir ) {
    die "Test directory $dir already exists! (try --force?)";
}
mkdir( $dir ) or die "Can't create directory $dir";
print "writing to $dir\n" if ( $settings{verbose} );

my $config = "$fulldir/condor_config";
open( CONFIG, ">$config" ) or die "Can't write to config file $config";
foreach my $param ( keys(%{$test->{config}}) ) {
    my $value = $test->{config}{$param};
    if ( $value eq "TRUE" ) {
	print CONFIG "$param = TRUE\n";
    }
    elsif ( $value eq "FALSE" ) {
	print CONFIG "$param = FALSE\n";
    }
    elsif ( $param eq "EVENT_LOG" ) {
	print CONFIG "$param = $fulldir/$value\n";
    }
    else {
	print CONFIG "$param = $value\n";
    }
}
print CONFIG "TEST_LOG_READER_STATE_LOG = $fulldir/state.log\n";
print CONFIG "TEST_LOG_READER_LOG = $fulldir/reader.log\n";
print CONFIG "TEST_LOG_WRITER_LOG = $fulldir/writer.log\n";
close( CONFIG );
$ENV{"CONDOR_CONFIG"} = $config;

# Basic calculations
my $default_max_size = 1000000;
my $max_size = $default_max_size;
my $max_rotations = 1;
if ( exists $test->{config}{"EVENT_LOG_MAX_SIZE"} ) {
    $max_size = $test->{config}{"EVENT_LOG_MAX_SIZE"};
}
elsif ( exists $test->{config}{"MAX_EVENT_LOG"} ) {
    $max_size = $test->{config}{"MAX_EVENT_LOG"};
}
if ( exists $test->{config}{"EVENT_LOG_MAX_ROTATIONS"} ) {
    $max_rotations = $test->{config}{"EVENT_LOG_MAX_ROTATIONS"};
}
elsif ( $max_size == 0 ) {
    $max_rotations = 0;
    $max_size = $default_max_size;
}
my $total_files = $max_rotations + 1;
my $total_loops;
if ( exists $settings{loops} ) {
    $total_loops = $settings{loops};
    $test->{loops} = $settings{loops};
}
elsif ( exists $test->{loops} ) {
    $total_loops = $test->{loops};
}
else {
    $total_loops = 1;
    $test->{loops} = 1;
}
my $total_events;
my $loop_events;
if ( exists $test->{loop_events} ) {
    $loop_events = $test->{loop_events};
    $total_events = $loop_events * $total_loops;
}
elsif ( exists $test->{events} ) {
    $loop_events = int($test->{events} / $total_loops);
    $total_events = $test->{events};
}
else {
    my $mult = ( exists $test->{size_mult} ) ? $test->{size_mult} : 1.25;
    $loop_events =
	int($mult * $total_files * $max_size / ($event_size * $total_loops) );
    $total_events = $loop_events * $total_loops;
}


# Calculate num exec / procs
if ( !exists $test->{writer}{"--num-exec"} ) {
    my $num_procs = 1;
    if ( exists( $test->{writer}{"--num-procs"} ) ) {
	$num_procs = $test->{writer}{"--num-procs"};
    }
    else {
	$test->{writer}{"--num-procs"} = $num_procs;
    }
    $test->{writer}{"--num-exec"} = int( $loop_events / $num_procs );
}
if ( !exists $test->{writer}{"--sleep"} ) {
    $test->{writer}{"--no-sleep"} = undef;
}


# Expected results
my %expect = (
	      final_mins => {
		  num_files	=> $total_files,
		  sequence	=> $total_files,
		  num_events	=> $total_events,
		  file_size	=> $max_size,
	      },
	      maxs => {
		  file_size	=> $max_size + 512,
		  total_size	=> ($max_size + 512) * $total_files,
	      },
	      loop_mins => {
		  num_files	=> int($total_files / $total_loops),
		  sequence	=> int($total_files / $total_loops),
		  file_size	=> $max_size / $total_loops,
		  num_events	=> $loop_events,
	      },
	      cur_mins => {
		  num_files	=> 0,
		  sequence	=> 0,
		  file_size	=> 0,
		  num_events	=> 0,
	      },
	      );


# Generate the writer command line
my @writer_args = ( $programs{writer} );
foreach my $t ( keys(%{$test->{writer}}) ) {
    if ( $t =~ /^-/ ) {
	my $value = $test->{writer}{$t};
	push( @writer_args, $t );
	if ( defined($value) ) {
	    push( @writer_args, $test->{writer}{$t} );
	}
    }
}

push( @writer_args, "--verbosity" );
push( @writer_args, "INFO" );
foreach my $n ( 2 .. $settings{verbose} ) {
    push( @writer_args, "-v" );
}
if ( $settings{debug} ) {
    push( @writer_args, "--debug" );
    push( @writer_args, "D_FULLDEBUG" );
}
if ( exists $test->{writer}{file} ) {
    push( @writer_args, $test->{writer}{file} )
}
else {
    push( @writer_args, "/dev/null" )
}


# Generate the reader command line
my @reader_args;
if ( exists $test->{reader} ) {
    push( @reader_args, $programs{reader} );
    foreach my $t ( keys(%{$test->{reader}}) ) {
	if ( $t =~ /^-/ ) {
	    my $value = $test->{writer}{$t};
	    push( @reader_args, $t );
	    if ( defined($value) ) {
		push( @reader_args, $test->{reader}{$t} );
	    }
	}
    }
    push( @reader_args, "--verbosity" );
    push( @reader_args, "ALL" );
    if ( $settings{debug} ) {
	push( @reader_args, "--debug" );
	push( @reader_args, "D_FULLDEBUG" );
    }
    push( @reader_args, "--eventlog" );
    push( @reader_args, "--exit" );
    push( @reader_args, "--no-term" );

    if ( exists $test->{reader}{persist} ) {
	push( @reader_args, "--persist" );
	push( @reader_args, "$dir/reader.state" );
    }
}


my @valgrind = ( "valgrind", "--tool=memcheck", "--num-callers=24",
		 "-v", "-v", "--leak-check=full" );

system("date");
if ( $settings{verbose} ) {
    print "Using directory $dir\n";
}
my $errors = 0;

# Total writer out
my %totals = ( sequence => 0,
	       num_events => 0,
	       max_rot => 0,
	       file_size => 0,

	       events_lost => 0,
	       num_events_lost => 0,

	       writer_events => 0,
	       writer_sequence => 0,
	       );

# Actual from previous loop
my %previous;
foreach my $k ( keys(%totals) ) {
    $previous{$k} = 0;
}

foreach my $loop ( 1 .. $test->{loops} )
{
    foreach my $k ( keys(%{$expect{loop_mins}}) ) {
	$expect{cur_mins}{$k} += $expect{loop_mins}{$k};
    }

    # writer output from this loop
    my %new;
    for my $k ( keys(%totals) ) {
	$new{$k} = 0;
    }

    # Run the writer
    my $run;
    my $werrors += RunWriter( $loop, \%new, \%previous, \%totals, \$run );
    $errors += $werrors;
    if ( ! $run ) {
	next;
    }
    if ( $werrors ) {
	print STDERR "writer failed: aborting test\n";
	last;
    }

    my @files = ReadEventlogs( $dir, \%new );
    ProcessEventlogs( \@files, \%new );

    my %diff;
    foreach my $k ( keys(%previous) ) {
	$diff{$k} = $new{$k} - $previous{$k};
	$totals{$k} += $new{$k};
    }
    $errors += CheckWriterOutput( \@files, $loop, \%new, \%diff );

    # Run the reader
    $errors += RunReader( $loop, \%new, \$run );
    if ( $run ) {
	$errors += CheckReaderOutput( \@files, $loop, \%new, \%diff );
    }

    if ( $errors  or  $settings{verbose}  or  $settings{debug} ) {
	GatherData( sprintf("$dir/loop-%02d.txt",$loop) );
    }

    foreach my $k ( keys(%previous) ) {
	$previous{$k} = $new{$k};
    }
    if ( $errors  and  $settings{stop} ) {
	last;
    }
}

if ( ! $settings{execute} ) {
    exit( 0 );
}

# Final writer output checks
if ( $totals{writer_events} < $expect{final_mins}{num_events} ) {
    printf( STDERR
	    "ERROR: final: writer wrote too few events: %d < %d\n",
	    $totals{writer_events}, $expect{final_mins}{num_events} );
    $errors++;
}
$totals{seq_files} = $totals{sequence} + 1;
if ( $totals{writer_sequence} < $expect{final_mins}{sequence} ) {
    printf( STDERR
	    "ERROR: final: writer sequence too low: %d < %d\n",
	    $totals{writer_sequence}, $expect{final_mins}{sequence} );
    $errors++;
}

# Final counted checks
my %final;
foreach my $k ( keys(%totals) ) {
    $final{$k} = 0;
}
my @files = ReadEventlogs( $dir, \%final );
ProcessEventlogs( \@files, \%final );
if ( scalar(@files) < $expect{final_mins}{num_files} ) {
    printf( STDERR
	    "ERROR: final: too few actual files: %d < %d\n",
	    scalar(@files), $expect{final_mins}{num_files} );
}
if ( ! $final{events_lost} ) {
    if ( $final{num_events} < $expect{final_mins}{num_events} ) {
	printf( STDERR
		"ERROR: final: too few actual events: %d < %d\n",
		$final{num_events}, $expect{loop_mins}{num_events} );
	$errors++;
    }
}
if ( $final{sequence} < $expect{final_mins}{sequence} ) {
    printf( STDERR
	    "ERROR: final: actual sequence too low: %d < %d\n",
	    $final{sequence}, $expect{final_mins}{sequence});
    $errors++;
}

if ( $final{file_size} > $expect{maxs}{total_size} ) {
    printf( STDERR
	    "ERROR: final: total file size too high: %d > %d\n",
	    $final{total_size}, $expect{maxs}{total_size});
    $errors++;
}


if ( $errors  or  ($settings{verbose} > 1)  or  $settings{debug} ) {
    GatherData( "/dev/stdout" );
}

sub GatherData( $ )
{
    my $f = shift;
    open( OUT, ">$f" );

    my $cmd;

    print OUT "\nls:\n";
    $cmd = "/bin/ls -l $dir";
    if ( open( CMD, "$cmd |" ) ) {
	while( <CMD> ) {
	    print OUT;
	}
    }
    close( CMD );

    print OUT "\nwc:\n";
    $cmd = "wc $dir/EventLog*";
    if ( open( CMD, "$cmd |" ) ) {
	while( <CMD> ) {
	    print OUT;
	}
    }
    close( CMD );

    print OUT "\nhead:\n";
    $cmd = "head -1 $dir/EventLog*";
    if ( open( CMD, "$cmd |" ) ) {
	while( <CMD> ) {
	    print OUT;
	}
    }
    close( CMD );

    print OUT "\nconfig:\n";
    $cmd = "cat $config";
    if ( open( CMD, "$cmd |" ) ) {
	while( <CMD> ) {
	    print OUT;
	}
    }
    close( CMD );

    print OUT "\ndirectory:\n";
    print OUT "$dir\n";

    close( OUT );
}

exit( $errors == 0 ? 0 : 1 );


# #######################################
# Run the writer
# #######################################
sub RunWriter( $$$$$ )
{
    my $loop = shift;
    my $new = shift;
    my $previous = shift;
    my $totals = shift;
    my $run = shift;

    my $errors = 0;

    my $cmd = "";
    my $vg_out = sprintf( "valgrind-writer-%02d.out", $loop );
    my $vg_full = "$dir/$vg_out";
    if ( $settings{valgrind_writer} ) {
	$cmd .= join( " ", @valgrind ) . " ";
	$cmd .= " --log-file=$vg_full ";
    }
    $cmd .= join(" ", @writer_args );
    print "$cmd\n" if ( $settings{verbose} );

    if ( ! $settings{execute} ) {
	$$run = 0;
	return 0;
    }

    $$run = 1;
    my $out = sprintf( "%s/writer-%02d.out", $dir, $loop );
    open( WRITER, "$cmd 2>&1 |" ) or die "Can't run $cmd";
    open( OUT, ">$out" );
    while( <WRITER> ) {
	print if ( $settings{verbose} > 1 );
	print OUT;
	chomp;
	if ( /wrote (\d+) events/ ) {
	    $new->{writer_events} = $1;
	}
	elsif ( /global sequence (\d+)/ ) {
	    $new->{writer_sequence} = $1;
	    $new->{writer_files} = $1 - $previous->{writer_sequence};
	    $totals->{writer_sequence} = 0;	# special case
	}
    }
    close( WRITER );
    close( OUT );

    if ( $? & 127 ) {
	printf "ERROR: writer exited from signal %d\n", ($? & 127);
	$errors++;
    }
    if ( $? & 128 ) {
	print "ERROR: writer dumped core\n";
	$errors++;
    }
    if ( $? >> 8 ) {
	printf "ERROR: writer exited with status %d\n", ($? >> 8);
	$errors++;
    }
    if ( ! $errors and $settings{verbose}) {
	print "writer process exited normally\n";
    }

    if ( $settings{valgrind_writer} ) {
	$errors += CheckValgrind( $vg_out );
    }
    return $errors;
}



# #######################################
# Run the reader
# #######################################
sub RunReader( $$$ )
{
    my $loop = shift;
    my $new = shift;
    my $run = shift;

    my $errors = 0;
    if ( scalar(@reader_args) == 0 ) {
	$$run = 0;
	return 0;
    }

    my $cmd = "";
    my $vg_out = sprintf( "valgrind-reader-%02d.out", $loop );
    my $vg_full = "$dir/$vg_out";
    if ( $settings{valgrind_reader} ) {
	$cmd .= join( " ", @valgrind ) . " ";
	$cmd .= " --log-file=$vg_full ";
    }
    $cmd .= join(" ", @reader_args );
    print "$cmd\n" if ( $settings{verbose} );

    if ( ! $settings{execute} ) {
	$$run = 0;
	return 0;
    }

    $$run = 1;
    $new->{reader_files} = 0;
    $new->{reader_events} = 0;
    $new->{reader_sequence} = [ ];

    my $out = sprintf( "%s/reader-%02d.out", $dir, $loop );
    open( OUT, ">$out" );
    open( READER, "$cmd 2>&1 |" ) or die "Can't run $cmd";
    while( <READER> ) {
	print if ( $settings{verbose} > 1 );
	print OUT;
	chomp;
	if ( /^Read (\d+) events/ ) {
	    $new->{reader_events} = $1;
	}
	elsif ( /Global JobLog:.*sequence=(\d+)/ ) {
	    push( @{$new->{reader_sequence}}, $1 );
	    $new->{reader_files}++;
	}

    }
    close( READER );
    close( OUT );

    if ( $? & 127 ) {
	printf "ERROR: reader exited from signal %d\n", ($? & 127);
	$errors++;
    }
    if ( $? & 128 ) {
	print "ERROR: reader dumped core\n";
	$errors++;
    }
    if ( $? >> 8 ) {
	printf "ERROR: reader exited with status %d\n", ($? >> 8);
	$errors++;
    }
    if ( ! $errors and $settings{verbose}) {
	print "reader process exited normally\n";
    }

    if ( -f "$dir/reader.state" ) {
	my $state = sprintf( "%s/reader.state", $dir );
	my $copy = sprintf( "%s/reader-%02d.state", $dir, $loop );
	my @cmd = ( "/bin/cp", $state, $copy );
	system( @cmd );

	@cmd = ( $programs{reader_state}, "dump", $state );
	my $out = sprintf( "%s/reader-%02d.dump", $dir, $loop );

	if ( !open( OUT, ">$out" ) ) {
	    print STDERR "Can't dump state to $out\n";
	    return $errors;
	}
	my $cmd = join( " ", @cmd );
	if ( ! open( DUMP, "$cmd|" ) ) {
	    print STDERR "Can't get dump state of $state\n";
	    return $errors;
	}

	while( <DUMP> ) {
	    print OUT;
	}
	close( DUMP );
	close( OUT );
    }

    if ( $settings{valgrind_reader} ) {
	$errors += CheckValgrind( $vg_out );
    }
    return $errors;
}

sub CheckValgrind( $$ )
{
    my $errors = 0;
    my $file = shift;

    my $full;
    opendir( DIR, $dir ) or die "Can't opendir $dir";
    while( my $f = readdir(DIR) ) {
	if ( index( $f, $file ) >= 0 ) {
	    $full = "$dir/$f";
	    last;
	}
    }
    closedir( DIR );
    if ( !defined $full ) {
	print STDERR "Can't find valgrind log for $file";
	return 1;
    }

    if ( ! open( VG, $full ) ) {
	print STDERR "Can't read valgrind output $full\n";
	return 1;
    }
    if ( $settings{verbose} ) {
	print "Reading valgrind output $full\n";
    }
    while( <VG> ) {
	if ( /ERROR SUMMARY: (\d+)/ ) {
	    my $e = int($1);
	     if ( $e ) {
		 $errors++;
	     }
	    if ( $settings{verbose}  or  $e ) {
		print;
	    }
	}
	elsif ( /LEAK SUMMARY:/ ) {
	    my @lines = ( $_ );
	    my $leaks = 0;
	    while( <VG> ) {
		if ( /blocks\.$/ ) {
		    push( @lines, $_ );
		}
		if ( /lost: (\d+)/ ) {
		    if ( int($1) > 0 ) {
			$leaks++;
			$errors++;
		    }
		}
	    }
	    if ( $settings{verbose}  or  $leaks ) {
		foreach $_ ( @lines ) {
		    print;
		}
	    }
	}

    }
    close( VG );
    return $errors;
}


# #######################################
# Check the writer's output
# #######################################
sub CheckWriterOutput( $$$$ )
{
    my $files = shift;
    my $loop  = shift;
    my $new   = shift;
    my $diff  = shift;

    my $errors = 0;

    if ( $new->{writer_events} < $expect{loop_mins}{num_events} ) {
	printf( STDERR
		"ERROR: loop %d: writer wrote too few events: %d < %d\n",
		$loop,
		$new->{writer_events}, $expect{loop_mins}{num_events} );
	$errors++;
    }
    if ( $new->{writer_sequence} < $expect{cur_mins}{sequence} ) {
	printf( STDERR
		"ERROR: loop %d: writer sequence too low: %d < %d\n",
		$loop,
		$new->{writer_sequence}, $expect{cur_mins}{sequence} );
	$errors++;
    }

    my $nfiles = scalar(@{$files});
    if ( $nfiles < $expect{cur_mins}{num_files} ) {
	printf( STDERR
		"ERROR: loop %d: too few actual files: %d < %d\n",
		$loop, $nfiles, $expect{cur_mins}{num_files} );
    }
    if ( ! $new->{events_lost} ) {
	if ( $diff->{num_events} < $expect{loop_mins}{num_events} ) {
	    printf( STDERR
		    "ERROR: loop %d: too few actual events: %d < %d\n",
		    $loop,
		    $diff->{num_events}, $expect{loop_mins}{num_events} );
	    $errors++;
	}
    }
    if ( $new->{sequence} < $expect{cur_mins}{sequence} ) {
	printf( STDERR
		"ERROR: loop %d: actual sequence too low: %d < %d\n",
		$loop,
		$new->{sequence}, $expect{cur_mins}{sequence});
	$errors++;
    }

    if ( $new->{file_size} > $expect{maxs}{total_size} ) {
	printf( STDERR
		"ERROR: loop %d: total file size too high: %d > %d\n",
		$loop,
		$new->{total_size}, $expect{maxs}{total_size});
	$errors++;
    }

    return $errors;
}


# #######################################
# Check the writer's output
# #######################################
sub CheckReaderOutput( $$$$ )
{
    my $files = shift;
    my $loop  = shift;
    my $new   = shift;
    my $diff  = shift;

    my $errors = 0;

    if ( $new->{reader_events} < $new->{writer_events} ) {
	printf( STDERR
		"ERROR: loop %d: reader found fewer events than writer wrote".
		": %d < %d\n",
		$loop,
		$new->{reader_events}, $new->{writer_events} );
	$errors++;
    }

    my $nseq = $#{@{$new->{reader_sequence}}};
    my $rseq = -1;
    if ( $nseq >= 0 ) {
	$rseq = @{$new->{reader_sequence}}[$nseq];
    }

   if ( $nseq < 0 ) {
	printf( STDERR
		"ERROR: loop %d: no reader sequence\n",
		$loop );
	$errors++;
    }
    elsif ( $rseq < $new->{writer_sequence} ) {
	printf( STDERR
		"ERROR: loop %d: reader sequence too low: %d < %d\n",
		$loop,
		$rseq, $new->{writer_sequence} );
	$errors++;
    }
    elsif ( ($nseq+1) < $expect{loop_mins}{sequence} ) {
	printf( STDERR
		"ERROR: loop %d: reader too few sequences: %d < %d\n",
		$loop,
		$nseq+1, $expect{loop_mins}{sequence} );
	$errors++;
    }

    if ( $new->{reader_files} < $new->{writer_files} ) {
	printf( STDERR
		"ERROR: loop %d: reader found too few files: %d < %d\n",
		$loop,
		$new->{reader_files}, $new->{writer_files} );
    }

    return $errors;
}


# #######################################
# Read the eventlog files
# #######################################
sub ReadEventlogs( $$ )
{
    my $dir = shift;
    my $new = shift;

    my @header_fields = qw( ctime id sequence size events offset event_off );

    my @files;
    opendir( DIR, $dir ) or die "Can't read directory $dir";
    while( my $t = readdir( DIR ) ) {
	if ( $t =~ /^EventLog(\.old|\.\d+)*$/ ) {
	    $new->{num_files}++;
	    my $ext = $1;
	    my $rot = 0;
	    if ( defined $ext  and  $ext eq ".old" ) {
		$rot = 1;
	    }
	    elsif ( defined $ext  and  $ext =~ /\.(\d+)/ ) {
		$rot = $1;
	    }
	    else {
		$rot = 0;
	    }
	    $files[$rot] = { name => $t, ext => $ext, num_events => 0 };
	    my $f = $files[$rot];
	    my $file = "$dir/$t";
	    open( FILE, $file ) or die "Can't read $file";
	    while( <FILE> ) {
		chomp;
		if ( $f->{num_events} == 0  and  /^008 / ) {
		    $f->{header} = $_;
		    $f->{fields} = { };
		    foreach my $field ( split() ) {
			if ( $field =~ /(\w+)=(.*)/ ) {
			    $f->{fields}{$1} = $2;
			}
		    }
		    foreach my $fn ( @header_fields ) {
			if ( not exists $f->{fields}{$fn} ) {
			    print STDERR
				"ERROR: header in file $t missing $fn\n";
			    $errors++;
			    $f->{fields}{$fn} = 0;
			}
		    }
		}
		if ( $_ eq "..." ) {
		    $f->{num_events}++;
		    $new->{num_events}++;
		}
	    }
	    close( FILE );
	    $f->{file_size} = -s $file;
	    $new->{total_size} += -s $file;
	}
    }
    closedir( DIR );
    return @files;
}

# #######################################
# Read the eventlog files, process them
# #######################################
sub ProcessEventlogs( $$ )
{
    my $files = shift;
    my $new = shift;

    my $events_counted =
	( exists $test->{config}{EVENT_LOG_COUNT_EVENTS} and
	  $test->{config}{EVENT_LOG_COUNT_EVENTS} eq "TRUE" );

    my $min_sequence = 9999999;
    my $min_event_off = 99999999;
    my $maxfile = $#{@{$files}};
    foreach my $n ( 0 .. $maxfile ) {
	if ( ! defined ${@{$files}}[$n] ) {
	    print STDERR "ERROR: EventLog file #$n is missing\n";
	    $errors++;
	    next;
	}
	my $f = ${@{$files}}[$n];
	my $t = $f->{name};
	if ( not exists $f->{header} ) {
	    print STDERR "ERROR: no header in file $t\n";
	    $errors++;
	}
	my $seq = $f->{fields}{sequence};

	# The sequence on all but the first (chronologically) file
	# should never be one
	if (  ( $n != $maxfile ) and ( $seq == 1 )  ) {
	    print STDERR
		"ERROR: sequence # for file $t (#$n) is $seq\n";
	    $errors++;
	}
	# but the sequence # should *never* be zero
	elsif ( $seq == 0 ) {
	    print STDERR
		"ERROR: sequence # for file $t (#$n) is zero\n";
	    $errors++;
	}
	if ( $seq > 1 ) {
	    if ( $f->{fields}{offset} == 0 ) {
		print STDERR
		    "ERROR: offset for file $t (#$n / seq $seq) is zero\n";
		$errors++;
	    }
	    if ( $events_counted  and  $f->{fields}{event_off} == 0 ) {
		print STDERR
		    "ERROR: event offset for file $t ".
		    "(#$n / seq $seq) is zero\n";
		$errors++;
	    }
	}
	if ( $seq > $new->{sequence} ) {
	    $new->{sequence} = $seq;
	}
	if ( $seq < $min_sequence ) {
	    $min_sequence = $seq;
	}
	if ( $f->{fields}{event_off} < $min_event_off ) {
	    $min_event_off = $f->{fields}{event_off};
	}
	if ( $events_counted ) {
	    if ( $n  and  $f->{fields}->{events} == 0 ) {
		print STDERR
		    "ERROR: # events for file $t (#$n / seq $seq) is zero\n";
		$errors++;
	    }
	}
	else {
	    if ( $f->{fields}->{events} != 0 ) {
		printf( STDERR
			"ERROR: event count for file $t ".
			"(#$n / seq $seq) is non-zero (%d)\n",
			$f->{fields}->{events} );
		$errors++;
	    }
	    if ( $f->{fields}->{event_off} != 0 ) {
		printf( STDERR
			"ERROR: event offset for file $t ".
			"(#$n / seq $seq) is non-zero (%d)\n",
			$f->{fields}->{event_off} );
		$errors++;
	    }
	}

	if ( $n  and  ( $f->{file_size} > $expect{maxs}{file_size} ) ) {
	    printf STDERR
		"ERROR: File $t is over size limit: %d > %d\n",
		$f->{file_size},  $expect{maxs}{file_size};
		$errors++;
	}

    }

    if ( $min_sequence > 0 ) {
	$new->{events_lost} = 1;
	if ( $min_event_off > 0 ) {
	    $new->{num_events_lost} = $min_event_off;
	}
	else {
	    $new->{num_events_lost} = -1;
	}
    }
}
