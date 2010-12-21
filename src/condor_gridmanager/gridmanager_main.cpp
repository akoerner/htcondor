/***************************************************************
 *
 * Copyright (C) 1990-2007, Condor Team, Computer Sciences Department,
 * University of Wisconsin-Madison, WI.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License.  You may
 * obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ***************************************************************/


#include "condor_common.h"
#include "condor_debug.h"
#include "condor_daemon_core.h"
#include "basename.h"
#include "my_username.h"
#include "subsystem_info.h"

#include "globus_utils.h"

#include "gridmanager.h"

DECL_SUBSYSTEM( "GRIDMANAGER", SUBSYSTEM_TYPE_DAEMON );// used by Daemon Core

char *myUserName = NULL;

// this appears at the bottom of this file
extern "C" int display_dprintf_header(char **buf,int *bufpos,int *buflen);

void
usage( char *name )
{
	dprintf( D_ALWAYS, 
		"Usage: %s [-f] [-b] [-t] [-p <port>] [-s <schedd addr>] [-o <owern@uid-domain>] [-C <job constraint>] [-S <scratch dir>]\n",
		condor_basename( name ) );
	DC_Exit( 1 );
}

void
main_init( int argc, char ** const argv )
{

	// Setup dprintf to display pid
	DebugId = display_dprintf_header;

	dprintf(D_FULLDEBUG,
		"Welcome to the all-singing, all dancing, \"amazing\" GridManager!\n");

	// handle specific command line args
	int i = 1;
	while ( i < argc ) {
		if ( argv[i][0] != '-' )
			usage( argv[0] );

		switch( argv[i][1] ) {
		case 'C':
			if ( argc <= i + 1 )
				usage( argv[0] );
			ScheddJobConstraint = strdup( argv[i + 1] );
			i++;
			break;
		case 's':
			// don't check parent for schedd addr. use this one instead
			if ( argc <= i + 1 )
				usage( argv[0] );
			ScheddAddr = strdup( argv[i + 1] );
			i++;
			break;
		case 'S':
			if ( argc <= i + 1 )
				usage( argv[0] );
			GridmanagerScratchDir = strdup( argv[i + 1] );
			i++;
			break;
		case 'o':
			// We handled this in main_pre_dc_init(), so just verify that
			// it has an argument.
			if ( argc <= i + 1 )
				usage( argv[0] );
			i++;
			break;
		default:
			usage( argv[0] );
			break;
		}

		i++;
	}

	// Tell DaemonCore that we want to spend all our time as the job owner,
	// not as user condor.
	daemonCore->Register_Priv_State( PRIV_USER );
	set_user_priv();

	Init();
	Register();
}

void
main_config()
{
	Reconfig();
}

void
main_shutdown_fast()
{
	DC_Exit(0);
}

void
main_shutdown_graceful()
{
	DC_Exit(0);
}

void
main_pre_dc_init( int argc, char* argv[] )
{
	// handle -o, so that we can switch euid to the user before
	// daemoncore does most of its initialization work.
	int i = 1;
	while ( i < argc ) {
		if ( !strcmp( argv[i], "-o" ) ) {
			// Say what user we're running jobs on behave of.
			// If the schedd starts us as root, we need to switch to
			// this uid for most of our life.
			if ( argc <= i + 1 ) {
				usage( argv[0] );
			}
			myUserName = strdup( argv[i + 1] );
			break;
		}
		i++;
	}

	if ( myUserName ) {
		char *owner = strdup( myUserName );
		char *domain = strchr( owner, '@' );
		if ( domain ) {
			*domain = '\0';
			domain = domain + 1;
		}
		if ( !init_user_ids(owner, domain)) {
			dprintf(D_ALWAYS, "init_user_ids() failed!\n");
			// uids.C will EXCEPT when we set_user_priv() now
			// so there's not much we can do at this point
		}
		set_user_priv();
		// We can't call daemonCore->Register_Priv_State() here because
		// there's no daemonCore object yet. We'll call it in main_init().

		free( owner );
	} else if ( is_root() ) {
		dprintf( D_ALWAYS, "Don't know what user to run as!\n" );
		DC_Exit( 1 );
	} else {
		myUserName = my_username();
	}
}

void
main_pre_command_sock_init( )
{
}

// This function is called by dprintf - always display our pid in our
// log entries. 
extern "C" 
int
display_dprintf_header(char **buf,int *bufpos,int *buflen)
{
	static pid_t mypid = 0;

	if (!mypid) {
		mypid = daemonCore->getpid();
	}

	return sprintf_realloc( buf, bufpos, buflen, "[%ld] ", (long)mypid );
}
