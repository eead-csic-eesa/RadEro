/*
 Radiotracer dynamics under soil erosion or sedimentation
 Copyright (C) 2012 Borja Latorre - borja.latorre@csic.es
*/

////////////////////////////////////////////////////////////
// Data structure

typedef struct
{
	float t, time, dt, cfl;	// Time unit  = years
	float iy; //year
	float size, dx, vol, dens, k, e;	// Space unit = meters
	int cells;
	float tau;			// Half life unit = years
	float *fallout;
	int fallout_n;
	float fallout_dt, fallout_c, fallout_mix_depth;
	int fallout_mix_n;
	float inv_ref;
	float *c, *ct;
	float mix_xi, mix_xf, mix_time;
	float mix_ti, mix_tf;
	int opt_ne, opt_nk;
	float opt_ei, opt_ef;
	float opt_ki, opt_kf;
	char debug, debug_msg[1024];
} data;


////////////////////////////////////////////////////////////
// Functions

int cs_model(void);

float advective_dt (data * this);

void advective_scheme (data * this);

void compute_dt (data * this);

void decay_scheme (data * this);

void debug (data * this);

float diffusive_dt (data * this);

void diffusive_scheme (data * this);

void mixing_scheme (data * this);

void init (data * this);

void isotope_input (data * this);

float isotope_input_t (data * this, float ti, float tf);

void write_activity (data * this, int j,  char *fname, char *fname2, char *fname3);

void set_initial_distribution (data * this);

void simulate (data * this);

void init (data * this);

int not_loaded (data * this);

void read_config (data * this, char *fname);

float minimum (float x, float y)
{
	if (x < y)
		return x;
	return y;
}

////////////////////////////////////////////////////////////

void debug (data * this)
{
	if (this->debug == 1)
	{
		// printf("DEBUG: %s\n", this->debug_msg);
	}
}

