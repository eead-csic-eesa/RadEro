/*
 Radiotracer dynamics under soil erosion or sedimentation
 Copyright (C) 2012 Borja Latorre - borja.latorre@csic.es

 For the latest updates, please visit:
 https://github.com/B0RJA/cs-model

 This program is free software: you can redistribute it
 and/or modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation,
 either version 3 of the License, or (at your option) any
 later version.

 This program is distributed in the hope that it will be
 useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE. See the GNU General Public License for more
 details.

 You should have received a copy of the GNU General Public
 License along with this program. If not, see:
 http://www.gnu.org/licenses/
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#if defined (__WIN32__)
#include <dir.h>
#endif
#include <math.h>
#include "cJSON.h"
#include "defs.h"
#include "data_io.h"
#include "simulation.h"
#include "optimization.h"
#include "R.h"
#define CONFIGJS "_config.js"
#define TXTEXP "_exp.txt"
#define TXTNUM1 "_num.txt"
#define TXTNUM2 "_num2.txt"
#define TXTNUM3 "_num3.txt"


int cs_model(void)
{
	// Check usage
	char fname[1024];
	//if( argc != 2 )
	//{
	//	printf("Usage: %s project-folder\n", argv[0]);
	//	return 1;
	//}

	// Change directory to project folder
	//chdir (argv[1]);
	
	// Declare data structure and init
	data d;
	init (&d);

	// Debug mode
	d.debug = 0;

	// Read configuration
	snprintf (fname, 1024, CONFIGJS);
	read_config (&d, fname);

	// Declare data structure and init
	data d2;
	init (&d2);
	// Debug mode
	d2.debug = 0;
	// Read configuration
	read_config (&d2, fname);

	// Read measured activity
	read_activity (&d2, TXTEXP);

	// Optimize
	optimize (&d, &d2);

	// Write results
	write_activity (&d , 1, TXTNUM1, TXTNUM2, TXTNUM3);

	return 0;
	
}

int main(int argc, char *argv[])
{

	// Check usage
	char fname[1024];
	if( argc != 2 )
	{
		snprintf (fname, 1024,"Usage: %s project-folder\n", argv[0]);
		return 1;
	}

	// Change directory to project folder
	//chdir (argv[1]);
	
	// Declare data structure and init
	data d;
	init (&d);

	// Debug mode
	d.debug = 0;

	// Read configuration
	snprintf (fname, 1024, "%s/_config.js", argv[1]);
	read_config (&d, fname);

	// Declare data structure and init
	data d2;
	init (&d2);
	// Debug mode
	d2.debug = 0;
	// Read configuration
	read_config (&d2, fname);

	// Read measured activity
	read_activity (&d2, "_exp.txt");
	
	// Optimize
	optimize (&d, &d2);

	// Write results
	write_activity (&d , 1,"_num.txt","_num2.txt","_num3.txt");

	return 0;

}
