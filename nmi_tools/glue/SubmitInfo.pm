#!/usr/bin/env perl

use strict;
use warnings;

package SubmitInfo;

# (14:06:39) Nick Leroy: #715
# (14:07:09) Nick Leroy: /p/condor/workspaces/nleroy/nmi-ports

###############################################################################
# Note: Even though a lot of information is specified in this file, the various
# glue scripts can add/subtract/manipulate the arguments and or information
# based upon "details on the ground" in the glue script.  One example is the
# location of the --with-externals directory which is not specified in this
# file but instead figured out in the remote_pre script for the build glue.
# Generally, try to put your arguments here if they are really build or test
# specific, but if they are machine specific, then you'll probably have to put
# them into the actual glue script--of course, try to keep this to a minimum.
###############################################################################

###############################################################################
# Build/Test Sets
#
# The Key is a human readable name for a set of nmi_platforms that we would
# like to run a build and test on.
# 
# The Value is an array of nmi_platform names usually (but not required) to
# be described in %submit_info.
#
# Note: Included in the tests are the cross tests if defined.
#
# With nmi_condor_submit, one can request a build/test set to submit.
###############################################################################

# The sets of ports we know about nativly in the glue script.
our %build_and_test_sets = (
	# The ports we officially support and for which we provide native binaries
	# on our download site.
	# If you don't specify what platforms you'd like built, then this is the
	# list to which we default.

	# NOTE: Keep the stable or developer release branches synchronized with
	# https://condor-wiki.cs.wisc.edu/index.cgi/wiki?p=DeveloperReleasePlan
	'official_ports' => [
		'x86_64_deb_5.0',
		'x86_64_rhap_5',
		'x86_64_rhas_3',
		'x86_deb_5.0',
		'x86_macos_10.4',
		'x86_rhap_5',
		'x86_rhas_3',
		'x86_winnt_5.1-tst', 
		#'x86_winnt_5.1',
	],

	# Occasionally, NMI would like a port on a bunch of odd platforms. These
	# are those platforms.
	'nmi_one_offs' => [
		'x86_64_rhap_5.3-updated',
		'x86_64_opensuse_11.3-updated',
		'x86_64_sol_5.10',
		'x86_64_sol_5.11',
                'x86_64_fedora_12-updated',
	],

	'stduniv' => [
		'x86_64_deb_5.0',
		'x86_64_rhap_5',
		'x86_64_rhas_3',
		'x86_deb_5.0',
	],
);

###############################################################################
# For every build, test, and cross test, of condor everywhere,
# these are the default prereqs _usually_ involved.
###############################################################################
my @default_prereqs = (
	'tar-1.14',
	'patch-2.5.4',
	'cmake-2.8.3',
	'flex-2.5.4a',
	'make-3.80',
	'byacc-1.9',
	'bison-1.25',
	'wget-1.9.1',
	'm4-1.4.1',
);

###############################################################################
# Minimal build configuration
# 
# The build arguments to configure which will result in the smallest and most
# portable build of Condor.
#
# This array is being used to initialze key/value pairs in a hash table.
# That is why it has this creepy format.
###############################################################################
my @minimal_build_configure_args =
	(
		'-DPROPER:BOOL=OFF'			=> undef,
		'-DCLIPPED:BOOL=ON'			=> undef,
		'-DWITH_BLAHP:BOOL=OFF'		=> undef,
		'-DWITH_BOOST:BOOL=OFF'		=> undef,
		'-DWITH_COREDUMPER:BOOL=OFF'	=> undef,
		'-DWITH_CREAM:BOOL=OFF'		=> undef,
		'-DWITH_DRMAA:BOOL=OFF'		=> undef,
		'-DWITH_EXPAT:BOOL=OFF'		=> undef,
		'-DWITH_GCB:BOOL=OFF'		=> undef,
		'-DWITH_GLOBUS:BOOL=OFF' 	=> undef,
		'-DWITH_GSOAP:BOOL=OFF'		=> undef,
		'-DWITH_HADOOP:BOOL=OFF'	=> undef,
		'-DWITH_KRB5:BOOL=OFF'		=> undef,
		'-DWITH_LIBDELTACLOUD:BOOL=OFF'	=> undef,
		'-DWITH_LIBVIRT:BOOL=OFF'		=> undef,
		'-DWITH_LIBXML2:BOOL=OFF'		=> undef,
		'-DWITH_UNICOREGAHP:BOOL=OFF'	=> undef,
		'-DWITH_VOMS:BOOL=OFF'		=> undef,
	);

###############################################################################
# Default List of Tests to Run.
#
# This specifies the test suite testclasses (more than one if you'd like)
# which are run by default for any test. The default of 'quick' means the
# tests we expect to be run by default every day in the nightlies.
###############################################################################
my @default_testclass = ( 'quick' );

###############################################################################
# Default Test Suite Configure Arguments
#
# When running a test suite, this is the list of default arguments to pass to
# the test suite's configure.
###############################################################################
my @default_test_configure_args =
	(
	'-DNOTHING_SPECIAL:BOOL=ON' => undef,
	);

###############################################################################
# Default Configure Arguments for a Condor Build
#
# This assumes that configure will figure out on its own the right information.
# and is generally used for official or completed ports of Condor.
#
# This array is being used to initialze key/value pairs in a hash table.
# That is why it has this creepy format.
###############################################################################
my @default_build_configure_args =
	(
	'-DPROPER:BOOL=OFF' 	=> undef,
	#'-DSCRATCH_EXTERNALS:BOOL=ON'	=> undef,
	);

###############################################################################
# Hash Table of Doom
#
# This table encodes the build and test information for each NMI platform.
###############################################################################
our %submit_info = (

	##########################################################################
	# Default platform chosen for an unknown platform.
	# This might or might not work. If it doesn't work, then likely
	# real changes to configure must be made to identify the platform, or
	# additional arguments specified to configure to set the arch, opsys, 
	# distro, etc, etc, etc.
	# A good sample of stuff to add in case it doesn't work is:
	# --with-arch=X86_64 \
	# --with-os=LINUX \
	# --with-kernel=2.6.18-194.3.1.el5 \        
	# --with-os_version=LINUX_UNKNOWN \               
	# --with-sysname=unknown \
	# <the big pile of other arguments>
	# 
	# See:
	# https://condor-wiki.cs.wisc.edu/index.cgi/wiki?p=BuildingCondorOnUnix
	##########################################################################
	'default_minimal_platform'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Microsoft Windows 6.0/2000/xp/whatever on x86_64
	# This probably doesn't work--glue scripts do funky things with it.
	##########################################################################
	'x86_winnt_6.0'	=> {
		'build' => {
			'configure_args' => { '-G \"Visual Studio 9 2008\"' => undef },
			'prereqs'	=> undef,
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> undef,
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Microsoft Windows 5.1/2000/xp/whatever on x86_64
	# This probably doesn't work--glue scripts do funky things with it.
	##########################################################################
	'x86_64_winnt_5.1'	=> {
		'build' => {
			'configure_args' => { '-G \"Visual Studio 9 2008\"' => undef },
			'prereqs'	=> undef,
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> undef,
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Microsoft Windows 5.1/2000/xp/whatever on x86
	# the official "blessed" windows build configuration
	##########################################################################
	'x86_winnt_5.1'	=> {
		'build' => {
			'configure_args' => { '-G \"Visual Studio 9 2008\"' => undef },
			'prereqs'	=> undef,
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> undef,
			'testclass'	=> [ @default_testclass ],
		},
	},
	
	##########################################################################
	# Microsoft Windows 5.1/2000/xp/whatever on x86
	# CMake build testing configuration
	##########################################################################
	'x86_winnt_5.1-tst'	=> {
		'build' => {
			'configure_args' => { '-G \"Visual Studio 9 2008\"' => undef },
			'prereqs'	=> undef,
			# when it works add x86_64_winnt_5.1 to the x_tests
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> undef,
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Microsoft Windows 5.1/2000/xp/whatever on x86
	# prereqs testing configuration (also cmake)
	##########################################################################
	'x86_winnt_5.1-prereqs'	=> {
		'build' => {
			'configure_args' => { '-G \"Visual Studio 9 2008\"' => undef },
			'prereqs'	=> [
				'cmake-2.8.3', '7-Zip-9.20', 'ActivePerl-5.10.1',
				'VisualStudio-9.0', 'WindowsSDK-6.1',
			],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> undef,
			'testclass'	=> [ @default_testclass ],
		},
	},
	
	##########################################################################
	# Platform Debian 5.0 on x86_64
	##########################################################################
	'x86_64_deb_5.0'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args,
				'-DCLIPPED:BOOL=OFF' => undef,
			 },
			'prereqs'	=> [ 'libtool-1.5.26', 'cmake-2.8.3' ],
			'xtests'	=>  [ 'x86_64_ubuntu_10.04', 'x86_64_ubuntu_8.04.3' ],
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ 'java-1.4.2_05' ],
			'testclass'	=> [ @default_testclass ],
		},
	},


	##########################################################################
	# Platform RHEL 5 on x86_64
	##########################################################################
	'x86_64_rhap_5'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args,
				'-DCLIPPED:BOOL=OFF' => undef,
			 },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> [ 
				'x86_64_fedora_13', 'x86_64_rhap_5.2',
				'x86_64_fedora_12', 'x86_64_fedora_12-updated', 
				'x86_64_fedora_13-updated' ],
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.4.2_05' ],
			'testclass'	=> [ @default_testclass ],
		},
	},


	##########################################################################
	# Platform RHEL 3 on x86_64
	##########################################################################
	'x86_64_rhas_3'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args,
				'-DCLIPPED:BOOL=OFF' => undef,
			},
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> [
				'x86_64_sles_9',
				'x86_64_rhas_4' ],
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.4.2_05', 'perl-5.8.5',
							'VMware-server-1.0.7' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Debian 5 on x86
	##########################################################################
	'x86_deb_5.0'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args,
				'-DCLIPPED:BOOL=OFF' => undef
			 },
			'prereqs'	=> [ 'libtool-1.5.26', 'cmake-2.8.3' ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ 'java-1.4.2_05' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Mac OSX 10.4 on x86
	##########################################################################
	'x86_macos_10.4'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args },
			'prereqs'	=> [ @default_prereqs,
				'coreutils-5.2.1',
				'libtool-1.5.26',],
			'xtests'	=> [
				'x86_64_macos_10.5-updated',
				'x86_64_macos_10.6',
				'x86_64_macos_10.6-updated',
			],
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ 
				@default_prereqs, 
				'java-1.4.2_09', 
				'coreutils-5.2.1'
			],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Mac OSX 10.5 on x86_64
	# condor actually builds naturally for this one, we just don't release it
	##########################################################################
	'x86_64_macos_10.5'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args },
			'prereqs'	=> [
				@default_prereqs,
				'libtool-1.5.26',
			],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Mac OSX 10.5 on x86_64 with updates
	# condor actually builds naturally for this one, we just don't release it
	##########################################################################
	'x86_64_macos_10.5-updated'	=> 'x86_64_macos_10.5',


	##########################################################################
	# Platform Mac OSX 10.6 on x86_64
	##########################################################################
	'x86_64_macos_10.6'	=> {
		'build' => {
			'configure_args' => {  @default_build_configure_args },
			'prereqs'	=> [
				@default_prereqs,
				'libtool-1.5.26',
			],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Mac OSX 10.6 with updates on x86_64
	##########################################################################
	'x86_64_macos_10.6-updated'	=> 'x86_64_macos_10.6',


	##########################################################################
	# Platform RHEL 5 on x86
	##########################################################################
	'x86_rhap_5'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args,
				'-DCLIPPED:BOOL=OFF' => undef,
			 },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> [ 
				'x86_64_rhap_5.2',
				'unmanaged-x86_rhap_5'
			],
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.4.2_05'],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform RHEL 3 on x86
	##########################################################################
	'x86_rhas_3'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args,
				'-DCLIPPED:BOOL=OFF' => undef,
			 },
			'prereqs'	=> [ 
				@default_prereqs,
				'perl-5.8.5', 'gzip-1.3.3', 'autoconf-2.59'
			],
			'xtests'	=> [ 
				'x86_64_sles_9',
			 	'x86_rhas_4', 
			 	'x86_64_rhas_3',
				'x86_64_rhas_4',
			],
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.4.2_05', 'perl-5.8.5',
							'VMware-server-1.0.7' ],
			'testclass'	=> [ @default_testclass ],
		},
	},


	# These describe what a human, sadly, had to figure out about certain
	# ports that we do in a "one off" fashion. These ports are generally
	# not released to the public, but are often needed by NMI to run their
	# cluster. If by chance work happens on these ports to make them officially
	# released, then they will move from this section to the above section, 
	# and most likely with the above arguments to configure. Most of these
	# builds of Condor are as clipped as possible to ensure compilation.

	##########################################################################
	# Platform Fedora 12 on x86_64
	# This might work.
	##########################################################################
	'x86_64_fedora_12'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.5.0_08' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Fedora 12 with updates on x86_64
	# This might work.
	##########################################################################
	'x86_64_fedora_12-updated'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.5.0_08', 'perl-5.8.9' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Fedora 13 on x86_64
	# This might work.
	##########################################################################
	'x86_64_fedora_13'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.5.0_08' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Fedora 13 with updates on x86_64
	# This might work.
	##########################################################################
	'x86_64_fedora_13-updated'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.5.0_08' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Solaris 11 on x86_64
	# Building openssl is problematic on this platform.  There is
	# some confusion betwen 64-bit and 32-bit, which causes linkage
	# problems.  Since ssh_to_job depends on openssl's base64 functions,
	# that is also disabled.
	##########################################################################
	'x86_64_sol_5.11'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args,
				'-DWITH_OPENSSL:BOOL=OFF' => undef,
				'-DWITH_CURL:BOOL=OFF' => undef,
				'-DHAVE_SSH_TO_JOB:BOOL=OFF' => undef,
				'-DWITHOUT_SOAP_TEST:BOOL=ON' => undef,
			},
			'prereqs'	=> [ @default_prereqs, 'perl-5.8.9', 'binutils-2.15',
							 'gzip-1.3.3', 'wget-1.9.1', 'coreutils-6.9',
				],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'perl-5.8.9', 'binutils-2.15',
							 'gzip-1.3.3', 'wget-1.9.1', 'coreutils-6.9' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Solaris 10 on x86_64
	# Building openssl is problematic on this platform.  There is
	# some confusion betwen 64-bit and 32-bit, which causes linkage
	# problems.  Since ssh_to_job depends on openssl's base64 functions,
	# that is also disabled.
	##########################################################################
	'x86_64_sol_5.10'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args,
				'-DWITH_OPENSSL:BOOL=OFF' => undef,
				'-DWITH_CURL:BOOL=OFF' => undef,
				'-DHAVE_SSH_TO_JOB:BOOL=OFF' => undef,
				'-DWITHOUT_SOAP_TEST:BOOL=ON' => undef,
			},
			'prereqs'	=> [ @default_prereqs, 'perl-5.8.9', 'binutils-2.21',
							 'gzip-1.3.3', 'wget-1.9.1', 'coreutils-8.9',
				],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'perl-5.8.9', 'binutils-2.15',
							 'gzip-1.3.3', 'wget-1.9.1', 'coreutils-6.9' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform RHEL 5 on x86  (umanaged!)
	# This might work.
	##########################################################################
	'unmanaged-x86_rhap_5'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},
		
		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.5.0_08' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform RHEL 5.2 on X86_64
	# This might work.
	# I suspect this could be a real port if we bothered.
	##########################################################################
	'x86_64_rhap_5.2'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform RHEL 5.3 on X86_64
	# This might work.
	# I suspect this could be a real port if we bothered.
	##########################################################################
	'x86_64_rhap_5.3'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform RHEL 5.3 with updates on X86_64
	# This might work.
	# I suspect this could be a real port if we bothered.
	##########################################################################
	'x86_64_rhap_5.3-updated'	=> {
		'build' => {
			'configure_args' => { @default_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.4.2_05' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform RHEL 5.4 on X86_64
	# This might work.
	# I suspect this could be a real port if we bothered.
	##########################################################################
	'x86_64_rhap_5.4'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform RHEL 4 on X86_64
	# This might work.
	##########################################################################
	'x86_64_rhas_4'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.5.0_08', 'perl-5.8.9' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform SLES 9 on x86_64
	##########################################################################
	'x86_64_sles_9'		=> {
		'build' => {
			'configure_args' =>{ @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs, 'wget-1.9.1' ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => {
				@default_test_configure_args,
				
			},
			'prereqs'	=> [ @default_prereqs, 'wget-1.9.1', 'java-1.4.2_05' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Ubuntu 8.04.3 on x86_64
	# This might work.
	##########################################################################
	'x86_64_ubuntu_8.04.3'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs , 'java-1.4.2_05' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform Ubuntu 10.04 on x86_64
	# This might work.
	##########################################################################
	'x86_64_ubuntu_10.04'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform RHEL 4 on x86
	# This might work.
	##########################################################################
	'x86_rhas_4'	=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args },
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => { @default_test_configure_args },
			'prereqs'	=> [ @default_prereqs, 'java-1.4.2_05', 'perl-5.8.5' ],
			'testclass'	=> [ @default_testclass ],
		},
	},

	##########################################################################
	# Platform openSUSE 11.3 on x86_64 (& updated)
	##########################################################################
	'x86_64_opensuse_11.3'		=> {
		'build' => {
			'configure_args' => { @minimal_build_configure_args,
				'-DWITHOUT_SOAP_TEST:BOOL=ON' => undef,
				'-DWITHOUT_AMAZON_TEST:BOOL=ON' => undef,
				'-DWITH_CURL:BOOL=ON' => undef,
				'-DWITH_EXPAT:BOOL=ON' => undef,
				'-DWITH_LIBVIRT:BOOL=ON' => undef,
				'-DWITH_LIBXML2:BOOL=ON' => undef,
			},
			'prereqs'	=> [ @default_prereqs ],
			'xtests'	=> undef,
		},

		'test' => {
			'configure_args' => {
				@default_test_configure_args
				
			},
			'prereqs'	=> [ @default_prereqs, 'java-1.4.2_05' ],
			'testclass'	=> [ @default_testclass ],
		},
	},
	'x86_64_opensuse_11.3-updated'		=> 'x86_64_opensuse_11.3',
);

foreach my $platform (keys %submit_info) {
	next if ref($submit_info{$platform}) eq "HASH";
	my $target = $submit_info{$platform};
	die "Self reference detected in '$platform' definition!!!"
		if ( $target eq $platform );
	if ( ! exists $submit_info{$target} ) {
		die "No matching platform '$target' for alias '$platform'";
	}
	$submit_info{$platform} = $submit_info{$target};
}

###############################################################################
# The code below this comment is used to sanity check the above data and
# check for simple type errors and other typos. The main() function is run if
# this file is executed standalone, but not if it is 'use'd by another
# perl script. Of course, the functions are available for use in the other
# perl script if desired.
###############################################################################

sub typecheck
{
	my $result = 1; # assume the typecheck passed.
	my $p;

	print "Running typecheck of submit_info.conf:\n";

	return $result;

	# An example, much more could be done...
	foreach $p (sort keys %submit_info) {
		# ensure configure_args is present and defined
		if (!exists($submit_info{$p}{'configure_args'})) {
			print "ERROR: Platform $p 'configure_args' not present\n";
			$result = 0;
		}
		# ensure 'configure_args' is defined properly.
		if (!defined($submit_info{$p}{'configure_args'})) {
			print "ERROR: Platform $p 'configure_args' not defined\n";
			$result = 0;
		}
	}

	# XXX Add that the prereqs must contain unique entries.

	return $result;
}

# A simple thing explaining some statistics about submit_info. Mostly useful
# for grant work, I'm sure. :)
sub statistics
{
	my $nump;
	my $p;

	print "Statistics of submit_info:\n";

	$nump = scalar(keys(%submit_info));

	print "\tNumber of nmi platforms described: $nump\n";

	#print "\tPlatforms:\n";
	#foreach $p (sort keys %submit_info) {
	#	print "\t\t$p\n";
	#}
};

sub dump_info
{
	my ($f) = shift(@_);
	my ($bref, $tref);

	if (!defined($f)) {
		$f = *STDOUT;
	}
	
	print $f "-------------------------------\n";
	print $f "Dump of submit_info information\n";
	print $f "-------------------------------\n";

	foreach my $p (sort keys %submit_info) {
		my $found = 0;
		foreach my $pname ( @_ ) {
			if ( $pname eq $p ) {
				$found++;
				last;
			}
			elsif ( $pname =~ /\/(.*)\// ) {
				my $re = "$1";
				if ( $p =~ /$re/ ) {
					$found++;
					last;
				}
			}
		}
		next if ( ! $found );
		print $f "Platform: $p\n";

		print $f "Build Info:\n";
		if (!defined($submit_info{$p}{'build'})) {
			print $f "Undef\n";
		} else {
			$bref = $submit_info{$p}{'build'};

			# emit the build configure arguments
			print $f "\tConfigure Args: ";
			if (!defined($bref->{'configure_args'})) {
				print $f "Undef\n";
			} else {
				print $f join(' ', args_to_array($bref->{'configure_args'})) .
					"\n";
			}
			
			# emit the build prereqs
			print $f "\tPrereqs: ";
			if (!defined($bref->{'prereqs'})) {
				print $f "Undef\n";
			} else {
				print $f join(' ', @{$bref->{'prereqs'}}) . "\n";
			}

			# emit the cross tests
			print $f "\tXTests: ";
			if (!defined($bref->{'xtests'})) {
				print $f "Undef\n";
			} else {
				print $f join(' ', @{$bref->{'xtests'}}) . "\n";
			}
		}

		print $f "Test Info:\n";
		if (!defined($submit_info{$p}{'test'})) {
			print $f "Undef\n";
		} else {
			$tref = $submit_info{$p}{'test'};

			# emit the test configure arguments
			print $f "\tConfigure Args: ";
			if (!defined($tref->{'configure_args'})) {
				print $f "Undef\n";
			} else {
				print $f join(' ', args_to_array($tref->{'configure_args'})) .
					"\n";
			}
			
			# emit the test prereqs
			print $f "\tPrereqs: ";
			if (!defined($tref->{'prereqs'})) {
				print $f "Undef\n";
			} else {
				print $f join(' ', @{$tref->{'prereqs'}}) . "\n";
			}

			# emit the testclass
			print $f "\tTestClass: ";
			if (!defined($tref->{'testclass'})) {
				print $f "Undef\n";
			} else {
				print $f join(' ', @{$tref->{'testclass'}}) . "\n";
			}
		}

		print "\n";
	}
}

# This function converts (and resonably escapes) an argument hash into an array
# usually used for hashes like 'configure_args'
sub args_to_array
{
	my ($arg_ref) = (@_);
	my $k;
	my @result;

	foreach $k (sort keys %{$arg_ref}) {
		if (defined($arg_ref->{$k})) {
			push @result, "$k='$arg_ref->{$k}'";
		} else {
			push @result, "$k";
		}
	}
	return @result;
}

sub main
{
	my @platforms;
	my $usage = "usage: $0 [--help|-h] [--list|-l] [-a|--all] [(<platform>|/<regex>/) ...]";

	foreach my $arg ( @ARGV ) {
		if (  ( $arg eq "-l" ) or ( $arg eq "--list" ) ) {
			foreach my $key ( sort keys(%submit_info) ) {
				print "$key\n";
			}
			exit( 0 );
		}
		elsif (  ( $arg eq "-a" ) or ( $arg eq "--all" ) ) {
			push( @platforms, "/.*/" );
		}
		elsif (  ( $arg eq "-h" ) or ( $arg eq "--help" ) ) {
			print "$usage\n";
			print "  --help|-h:  This help\n";
			print "  --list|-l:  List available platforms\n";
			print "  --all|-a:   Dump info on all available platforms\n";
			print "  <platform>: Dump info named platform\n";
			print "  /<regex>/:  Dump info on all platforms matching <regex>\n";
			exit(0);
		}
		elsif ( $arg =~ /_/ or $arg =~ /^\// ) {
			push( @platforms, $arg );
		}
		elsif ( $arg =~ /^-/ ) {
			print "Unknown option: '$arg'\n";
			print "$usage\n";
			exit( 1 );
		}
		else {
			print "'$arg' does not appear to be a valid platform name or regex\n";
			print "$usage\n";
			exit( 1 );
		}
	}
	if ( ! scalar(@platforms) ) {
			print "$usage\n";
			exit( 1 );
	}
	$#ARGV = -1;

	if (!typecheck()) {
		die "\tTypecheck failed!";
	} else {
		print "\tTypecheck passed.\n";
	}
	statistics();
	dump_info( undef, @platforms );
}

###############################################################################
# Topelevel code
###############################################################################

# The variable "$slaved_module" should be defined in the perl script
# that includes this perl file as a data initialization module. In this
# case, the main will not be run. It is useful to run submit_info.conf by hand
# after mucking with it and have it ensure that what you typed in made sense.
if (!defined($main::slaved_module)) {
	$main::slaved_module = undef; # silence warning
	main();
}

1;
