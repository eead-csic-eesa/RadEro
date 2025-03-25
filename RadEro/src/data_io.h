/*
 Radiotracer dynamics under soil erosion or sedimentation
 Copyright (C) 2012 Borja Latorre - borja.latorre@csic.es
*/

//////////////////////////////////////////////////////////
// Data initialization

void init (data *this)
{
	this->cells   = 0;
	this->time    = 0.0;
	this->c       = NULL;
	this->ct      = NULL;
	this->fallout = NULL;
	this->debug   = 0;
}

//////////////////////////////////////////////////////////
// Check if data is loaded

int not_loaded (data *this)
{
	if (this->cells == 0)
		return 1;
	return 0;
}

//////////////////////////////////////////////////////////
// Read configuration from JSON file

void read_config (data *this, char *fname)
{

	int i;
	char trash[1024];
	(void)trash; // To avoid warnings
	float ti, tf, x1, lambda;

	// Parse JSON config file
	cJSON *root = cJSON_ParseFile(fname);
	if (root == NULL)
	{
		snprintf (this->debug_msg, 1024,"Error parsing JSON file %s", fname);
		debug (this);
		return;
	}

	// Free memory if data is already loaded
	if (!(this->c == NULL))
		free (this->c);
	if (!(this->ct == NULL))
		free (this->ct);
	if (!(this->fallout == NULL))
		free (this->fallout);

	this->tau = 
		cJSON_GetObjectItem(root, "tracer-lifetime")->valuefloat;

	this->size = 
		cJSON_GetObjectItem(root, "soil-thickness")->valuefloat;
	this->vol = 
		cJSON_GetObjectItem(root, "soil-effective-volume")->valuefloat;
	this->dens = 
		cJSON_GetObjectItem(root, "soil-density")->valuefloat;

	this->dx = 
		cJSON_GetObjectItem(root, "cell-thickness")->valuefloat;

	this->cells = (int)( this->size / this->dx + 0.5 );
	snprintf (this->debug_msg, 1024, "cells %d", this->cells);
	debug (this);

	// Memory allocation
	this->c = (float *) calloc (this->cells*2, sizeof (float));
	this->ct = (float *) calloc (this->cells*2, sizeof (float));

	this->cfl = 
		cJSON_GetObjectItem(root, "numerical-cfl")->valuefloat;

	this->mix_xi = 
		cJSON_GetObjectItem(root, "mix-from-depth")->valuefloat;
	this->mix_xf = 
		cJSON_GetObjectItem(root, "mix-to-depth")->valuefloat;
	this->mix_time = 
		cJSON_GetObjectItem(root, "mix-interval")->valuefloat;

		
	cJSON *fallout = cJSON_GetObjectItem(root, "fallout");
	cJSON *fallout_curve = cJSON_GetObjectItem(fallout, "curve");
	
	this->mix_ti = 
		cJSON_GetObjectItem(root, "mix-inicial-year")->valuefloat -
		cJSON_GetObjectItem(fallout, "initial-year")->valuefloat;
	this->mix_tf = 
		cJSON_GetObjectItem(root, "mix-final-year")->valuefloat -
		cJSON_GetObjectItem(fallout, "initial-year")->valuefloat;
	
	this->iy = 
		cJSON_GetObjectItem(fallout, "initial-year")->valuefloat;

	this->time = 
		cJSON_GetObjectItem(root, "simulate-until-year")->valuefloat -
		cJSON_GetObjectItem(fallout, "initial-year")->valuefloat;

	this->fallout_mix_depth = 
		cJSON_GetObjectItem(fallout, "mix-depth")->valuefloat;

	this->fallout_dt = 
		( cJSON_GetObjectItem(fallout, "final-year")->valuefloat + 1.0 -
		cJSON_GetObjectItem(fallout, "initial-year")->valuefloat ) /
		(float) cJSON_GetArraySize(fallout_curve);

	this->fallout_n = cJSON_GetArraySize(fallout_curve);
	this->fallout = (float *) calloc (this->fallout_n, sizeof (float));
	for (i = 0; i < this->fallout_n; i++)
	{
		this->fallout[i] =
			cJSON_GetArrayItem(fallout_curve, i)->valuefloat;
		// Unit conversion
		this->fallout[i] = this->fallout[i];
	}
	this->inv_ref = 
		cJSON_GetObjectItem(fallout, "reference-inventory")->valuefloat;
	// Unit conversion
	this->inv_ref = this->inv_ref ;

	cJSON *optimization = cJSON_GetObjectItem(root, "optimization");
	this->opt_ki = 
		cJSON_GetObjectItem(optimization, "k-initial")->valuefloat;
	this->opt_kf = 
		cJSON_GetObjectItem(optimization, "k-final")->valuefloat;
	this->opt_ei = 
		cJSON_GetObjectItem(optimization, "e-initial")->valuefloat;
	this->opt_ef = 
		cJSON_GetObjectItem(optimization, "e-final")->valuefloat;
	this->opt_nk = 
		cJSON_GetObjectItem(optimization, "k-samples")->valueint;
	this->opt_ne = 
		cJSON_GetObjectItem(optimization, "e-samples")->valueint;
		
	// Unit conversion
	this->k = this->k * 0.01 * 0.01 * 12.;	// cm^2/month to m^2/year
	this->k = this->k / this->vol;
	this->e = this->e * 0.01 * 12.;	// cm/month to m/year

	// Compute fallout constant
	x1 = 0.0;
	lambda = 0.69314718056 / this->tau;
	for (i = 0; i < 10000; i++) {
		ti = (float)i * this->time / 10000.0;
		tf = ti + this->time / 10000.0;
		x1 += isotope_input_t(this, ti, tf) * (tf - ti) *
			exp( - lambda * (this->time - 0.5 * (ti + tf)));
	}
	this->fallout_c = this->inv_ref / x1;

	// Mix the fallout in the first n cells
	x1 = this->dx * 0.5;
	this->fallout_mix_n = 0;
	for (i=0 ; i<this->cells ; i++)
	{
		if(x1 < 0.01)
			this->fallout_mix_n++;
		else
			i = this->cells;
		x1 = x1 + this->dx;
	}

	snprintf (this->debug_msg, 1024, "time %f", this->time);
	debug (this);
	snprintf (this->debug_msg, 1024, "fallout_c %f", this->fallout_c);
	debug (this);

}

///////////////////////////////////////////////////////////
// Write activity to file

void write_activity (data *this, int j, char *fname, char *fname2, char *fname3)
{

	int i, cells;
	float x1, x2, x3, dx;
	(void)x2; // To avoid warning
	(void)x3; // To avoid warning


	FILE *fp, *fp2, *fp3;
	if (not_loaded (this))
		return;

	fp = fopen (fname, "w");
	fp2 = fopen(fname2, "w");
    fp3 = fopen(fname3, "w");
	
	if (fp == NULL || fp2 == NULL || fp3 == NULL)
	{
		snprintf (this->debug_msg, 1024, "Error writing files");
		debug (this);
		return;
	}

	cells = this->cells;
	dx = this->size / (float) cells;

	fprintf (fp, "# k=%e  e=%e  c=%e\n",
			this->k, this->e, this->fallout_c);
	fprintf(fp2, "# k=%e  e=%e  c=%e\n",
            this->k, this->e, this->fallout_c);
    fprintf(fp3, "# k=%e  e=%e  c=%e\n",
            this->k, this->e, this->fallout_c);

	x1 = 0.0;
	for (i = 0; i < cells; i++)
	{
		fprintf (fp2, "%e %e\n", x1, this->c[i*2]-this->c[i*2+1]);
		fprintf (fp3, "%e %e\n", x1+dx, this->c[i*2]+this->c[i*2+1]);
		fprintf (fp, "%e %e\n", x1+dx*0.5, this->c[i*2]*this->dx); //Bq/m^3 to Bq/m^2 
		x1 += dx;
	}

	fclose(fp);
	fclose(fp2);
    fclose(fp3);

}

///////////////////////////////////////////////////////////
// Read activity from file

void read_activity (data *this, char *fname)
{

	if (not_loaded (this))
		return;

	int i, j, cells;
	(void)j; // to avoid warnings

	FILE *fp;
	fp = fopen (fname, "r");
	if (fp == NULL)
	{
		snprintf (this->debug_msg, 1024, "Error reading %s", fname);
		debug (this);
		return; 
	}

	cells = this->cells;
	for (i = 0 ; i < cells ; i++)
	{
		j = fscanf (fp, "%f", &(this->c[i*2]));
		this->c[i*2+1] = 0.0;
		this->c[i*2] = this->c[i*2] / this->dx; //Bq/m^2 to Bq/m^3
	}

	fclose (fp);

}

