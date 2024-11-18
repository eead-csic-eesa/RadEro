/*
 Radiotracer dynamics under soil erosion or sedimentation
 Copyright (C) 2012 Borja Latorre - borja.latorre@csic.es
*/

///////////////////////////////////////////////////////////
// Mixing

float invent (data *this)
{

	int i;
	int cells;
	float x1;

	cells = this->cells;

	x1 = 0.0;
	for (i=0 ; i<cells ; i++)
	{
		x1 += this->c[i*2];
	}

	return x1 * this->dx;

}

///////////////////////////////////////////////////////////
// Mixing

void mixing_scheme (data *this)
{

	int i, j;
	float x, dx, xi, xf, mix;
	int cells;
	float *c;

	//printf("mixing_schem: year=%.2f time=%.2f\n", this->t+this->iy, this->t);

	cells = this->cells;
	dx = this->dx;
	c  = this->c;
	xi = this->mix_xi;
	xf = this->mix_xf;

	mix = 0.0;
	j = 0;
	x = dx * 0.5;
	for (i=0 ; i<cells ; i++)
	{
		if(x>=xi && x<=xf)
		{
			mix += c[i*2];
			j++;
		}
		x += dx;
	}

	mix = mix / (float)j;

	x = dx * 0.5;
	for (i=0 ; i<cells ; i++)
	{
		if(x>=xi && x<=xf)
		{
			c[i*2] = mix;
			c[i*2+1] = 0.0;
		}
		x += dx;
	}

}

///////////////////////////////////////////////////////////
// Isotope input.

float isotope_input_t (data * this, float ti, float tf)
{

	float x1, t, dt;
	int i, j;

	x1 = 0.0; //To avoid errors, it's needed a x1 value if the condition "if" is not met.

	i = (int) ( ti / this->fallout_dt );
	j = (int) ( tf / this->fallout_dt );

	if(i >= this->fallout_n || j >= this->fallout_n){
		return 0.0;
	}

	if(i==j){
		x1 = this->fallout[i];
	}
	else if(i+1 == j){

		if(j >= this->fallout_n){
			dt = this->fallout_dt; 
			t = dt * (float)j;
			x1 = this->fallout[i]*(t-ti)/(tf-ti) +
				0.0*(tf-t)/(tf-ti);
		}

		dt = this->fallout_dt; 
		t = dt * (float)j;
		x1 = this->fallout[i]*(t-ti)/(tf-ti) +
			this->fallout[j]*(tf-t)/(tf-ti);
	}

	return x1;

}

void isotope_input (data * this)
{

	int i, n;
	float in;

	in = isotope_input_t(this, this->t, this->t+this->dt);

	n = this->fallout_mix_n;
	for (i=0 ; i<n ; i++)
	{
		this->c[i*2] += 
			this->dt * this->fallout_c * in / this->dx / (float)n;
	}

//	this->c[0] += 
//		this->dt * this->fallout_c * in / this->dx;

}


///////////////////////////////////////////////////////////
// Set initial concentration distribution.

void set_initial_distribution (data *this)
{

	int i;
	int cells;

	cells = this->cells;
	for (i=0 ; i<cells ; i++)
	{
		this->c[i*2  ] = 0.0;
		this->c[i*2+1] = 0.0;
	}

}


///////////////////////////////////////////////////////////
// Second order advective scheme with constant velocity
// and Dx.

void advection_matrix_A( float *M, double c)
{
	M[0] = c;
	M[1] = c * ( 1.0 - c );
	M[2] = c * 3.0 * ( c - 1.0 );
	M[3] = c * ( c * c - 3.0 * ( 1.0 - c ) * ( 1.0 - c ) );
}

void advection_matrix_B1( float *M, double c)
{
	M[0] = ( 1.0 - c );
	M[1] = - ( 1.0 - c ) * c;
	M[2] = ( 1.0 - c ) * 3.0 * c;
	M[3] = ( 1.0 - c ) * ( ( 1.0 - c ) * ( 1.0 - c ) - 3.0 * c * c );
}

void advection_matrix_B2( float *M, double c)
{
	M[0] = ( 1.0 - c );
	M[1] = ( 1.0 - c ) * c;
	M[2] = - ( 1.0 - c ) * 3.0 * c;
	M[3] = ( 1.0 - c ) * ( ( 1.0 - c ) * ( 1.0 - c ) - 3.0 * c * c );
}

void advection_matrix_C( float *M, double c)
{
	M[0] = c;
	M[1] = c * ( c - 1.0 );
	M[2] = c * 3.0 * ( 1.0 - c );
	M[3] = c * ( c * c - 3.0 * ( 1.0 - c ) * ( 1.0 - c ) );
}

void advective_scheme (data *this)
{

	int i, j, k;
	float e, dt, dx, a, x1;
	int cells;
	float *c, *ct;
	float ma[4], mb[4], mc[4];

	e = this->e;
	dt = this->dt;
	dx = this->dx;
	c = this->c;
	ct = this->ct;
	cells = this->cells;

	if (e < 0.) {
		j = cells - 1;
		a = - e * dt / dx;
		advection_matrix_B2(mb, a);
		advection_matrix_C(mc, a);
		for (i = 0; i < j; i++) {
			k = i + 1;
			ct[i*2  ] = mc[0] * c[k*2] + mc[1] * c[k*2+1] + 
						mb[0] * c[i*2] + mb[1] * c[i*2+1];
			ct[i*2+1] = mc[2] * c[k*2] + mc[3] * c[k*2+1] +
						mb[2] * c[i*2] + mb[3] * c[i*2+1];
		}
		ct[i*2  ] = mb[0] * c[i*2] + mb[1] * c[i*2+1];
		ct[i*2+1] = mb[2] * c[i*2] + mb[3] * c[i*2+1];
	}
	else {
		j = cells - 1;
		a = e * dt / dx;
		advection_matrix_A(ma, a);
		advection_matrix_B1(mb, a);
		x1 = c[0] - c[1];
		if( x1 < 0.0 )
			x1 = 0.0;
		ct[0] = ma[0] * x1 + 
				mb[0] * c[0] + mb[1] * c[1];
		ct[1] = ma[2] * x1 +
				mb[2] * c[0] + mb[3] * c[1];
		for (i = 1; i < j; i++) {
			k = i - 1;
			ct[i*2  ] = ma[0] * c[k*2] + ma[1] * c[k*2+1] + 
						mb[0] * c[i*2] + mb[1] * c[i*2+1];
			ct[i*2+1] = ma[2] * c[k*2] + ma[3] * c[k*2+1] +
						mb[2] * c[i*2] + mb[3] * c[i*2+1];
		}
		/*
		// Open contour (matrix C contribution is missed)
		k = i - 1;
		ct[i*2  ] = ma[0] * c[k*2] + ma[1] * c[k*2+1] + 
					mb[0] * c[i*2] + mb[1] * c[i*2+1];
		ct[i*2+1] = ma[2] * c[k*2] + ma[3] * c[k*2+1] +
					mb[2] * c[i*2] + mb[3] * c[i*2+1];
		//*/
		//*
		// Closed contour. Only affects deposition.
		// TODO.
		// Compute the specific matrix for
		// this case and check is correct.
		k = i - 1;
		ct[i*2  ] = ma[0] * c[k*2] + ma[1] * c[k*2+1] + 
					mb[0] * c[i*2] + mb[1] * c[i*2+1] + 
					ma[0] * c[i*2] + ma[1] * c[i*2+1];
		ct[i*2+1] = ma[2] * c[k*2] + ma[3] * c[k*2+1] +
					mb[2] * c[i*2] + mb[3] * c[i*2+1] -
					ma[2] * c[i*2] - ma[3] * c[i*2+1];
		//*/
	}
	for (i = 0; i < cells; i++) {
		c[i*2  ] = ct[i*2  ];
		c[i*2+1] = ct[i*2+1];
	}

}

void tvd_scheme (data *this)
{

	int i, j, k;
	int cells;
	float *c, *ct;
	float x1, x2, x3, x4;

	c = this->c;
	ct = this->ct;
	cells = this->cells;

	for (i=1 ; i<cells-1 ; i++) {
		j = i - 1;
		k = i + 1;
		x1 = c[2*k];
		x2 = c[2*i] + c[2*i+1];
		x3 = c[2*i] - c[2*i+1];
		x4 = c[2*j];
		if(x1>x4)
		{
			if(x2>x1){ x2=x1; }
			if(x3<x4){ x3=x4; }
		}
		if(x1<x4)
		{
			if(x2<x1){ x2=x1; }
			if(x3>x4){ x3=x4; }
		}
		ct[2*i+1] = (x2-x3) * 0.5;
	}
	for (i = 1; i < cells-1; i++) {
		c[2*i+1] = ct[2*i+1];
	}

}

///////////////////////////////////////////////////////////
// First order diffusive scheme with constant K and Dx.


void diffusion_matrix_C2( float *M, double p)
{
	float T[4];
	T[0] = 0.0;
	T[1] = p * p;
	T[2] = p * p;
	T[3] = 2.0 * p * ( 1.0 - 2.0 * p );
	M[0] = 0.5  * (   T[0] + T[1] + T[2] + T[3] );
	M[1] = 0.25 * ( - T[0] + T[1] - T[2] + T[3] );
	M[2] =        ( - T[0] - T[1] + T[2] + T[3] );
	M[3] = 0.5  * (   T[0] - T[1] - T[2] + T[3] );
}

void diffusion_matrix_C( float *M, double p)
{
	float T[4];
	T[0] = p * p;
	T[1] = 0.0;
	T[2] = 2.0 * p * ( 1.0 - 2.0 * p );
	T[3] = p * p;
	M[0] = 0.5  * (   T[0] + T[1] + T[2] + T[3] );
	M[1] = 0.25 * ( - T[0] + T[1] - T[2] + T[3] );
	M[2] =        ( - T[0] - T[1] + T[2] + T[3] );
	M[3] = 0.5  * (   T[0] - T[1] - T[2] + T[3] );
}

void diffusion_matrix_B( float *M, double p)
{
	float T[4];
	T[0] = 6.0 * p * p - 4.0 * p + 1.0;
	T[1] = 2.0 * p * ( 1.0 - 2.0 * p );
	T[2] = 2.0 * p * ( 1.0 - 2.0 * p );
	T[3] = 6.0 * p * p - 4.0 * p + 1.0;
	M[0] = 0.5  * (   T[0] + T[1] + T[2] + T[3] );
	M[1] = 0.25 * ( - T[0] + T[1] - T[2] + T[3] );
	M[2] =        ( - T[0] - T[1] + T[2] + T[3] );
	M[3] = 0.5  * (   T[0] - T[1] - T[2] + T[3] );
}

void diffusion_matrix_A( float *M, double p)
{
	float T[4];
	T[0] = p * p;
	T[1] = 2.0 * p * ( 1.0 - 2.0 * p );
	T[2] = 0.0;
	T[3] = p * p;
	M[0] = 0.5  * (   T[0] + T[1] + T[2] + T[3] );
	M[1] = 0.25 * ( - T[0] + T[1] - T[2] + T[3] );
	M[2] =        ( - T[0] - T[1] + T[2] + T[3] );
	M[3] = 0.5  * (   T[0] - T[1] - T[2] + T[3] );
}

void
diffusive_scheme (data * this)
{

	int i, j, ia, ic;
	float k, dt, dx, a;
	int cells;
	float *c, *ct;
	float ma[4], mb[4], mc[4], mc2[4];

	k = this->k;
	dt = this->dt;
	dx = this->dx;
	c = this->c;
	ct = this->ct;
	cells = this->cells;

	a = dt * k / dx / dx;
	diffusion_matrix_A(ma, a);
	diffusion_matrix_B(mb, a);
	diffusion_matrix_C(mc, a);
	diffusion_matrix_C2(mc2, a);

	ct[0] = ma[0] * c[0] - ma[1] * c[1] + 
			mb[0] * c[0] + mb[1] * c[1] + 
			mc[0] * c[2] + mc[1] * c[3];
	ct[1] = ma[2] * c[0] - ma[3] * c[1] + 
			mb[2] * c[0] + mb[3] * c[1] +
			mc[2] * c[2] + mc[3] * c[3];

	j = cells - 1;
	for (i = 1; i < j; i++) {
		ia = i - 1;
		ic = i + 1;
		ct[i*2  ] = ma[0] * c[ia*2] + ma[1] * c[ia*2+1] + 
					mb[0] * c[i *2] + mb[1] * c[i *2+1] + 
					mc[0] * c[ic*2] + mc[1] * c[ic*2+1];
		ct[i*2+1] = ma[2] * c[ia*2] + ma[3] * c[ia*2+1] +
					mb[2] * c[i *2] + mb[3] * c[i *2+1] +
					mc[2] * c[ic*2] + mc[3] * c[ic*2+1];
	}

	// TODO
	// Define wall as a closed or open countour?
	i = cells - 1;
	ia = i - 1;

	/*
	// Open contour
	ct[i*2  ] = ma[0] * c[ia*2] + ma[1] * c[ia*2+1] + 
				mb[0] * c[i *2] + mb[1] * c[i *2+1];
	ct[i*2+1] = ma[2] * c[ia*2] + ma[3] * c[ia*2+1] +
				mb[2] * c[i *2] + mb[3] * c[i *2+1];
	//*/

	//*
	// Closed contour
	ct[i*2  ] = ma[0] * c[ia*2] + ma[1] * c[ia*2+1] + 
				mb[0] * c[i *2] + mb[1] * c[i *2+1] + 
				mc2[0] * c[i *2] + mc2[1] * c[i *2+1];
	ct[i*2+1] = ma[2] * c[ia*2] + ma[3] * c[ia*2+1] +
				mb[2] * c[i *2] + mb[3] * c[i *2+1] +
				mc2[2] * c[i *2] + mc2[3] * c[i *2+1];
	//*/

	for (i = 0; i < cells; i++) {
		c[i*2  ] = ct[i*2  ];
		c[i*2+1] = ct[i*2+1];
	}

}

///////////////////////////////////////////////////////////
// Radioactive decay scheme.

void
decay_scheme (data * this)
{

	int i;
	float x1;
	int cells;
	float *c;

	cells = this->cells;
	c = this->c;

	// Portion of atoms that do not decay
	x1 = exp (- 0.69314718056 / this->tau * this->dt);
	// First order approximation
	//x1 = 1.0 - 0.69314718056 / this->tau * this->dt;

	for (i=0 ; i<cells ; i++)
	{
		c[i*2] = c[i*2] * x1;
		c[i*2+1] = c[i*2+1] * x1;
	}

}


///////////////////////////////////////////////////////////
// Compute advective time step.

float
advective_dt (data * this)
{
	float dx, cfl, v;

	dx  = this->dx;
	cfl = this->cfl;
	v   = fabs(this->e);

	if (v > 1.E-15)
	{
		return cfl * dx / v;
	}

	return 1.E15;
}


///////////////////////////////////////////////////////////
// Compute diffusive time step.

float diffusive_dt (data * this)
{
	float dx, cfl, k;

	dx  = this->dx;
	cfl = this->cfl;
	k   = this->k;

	if (k > 1.E-15)
	{
		return cfl * dx * dx / k;
	}

	return 1.E15;
}


///////////////////////////////////////////////////////////
// Compute time step.

void compute_dt (data * this)
{

	this->dt =
		minimum (diffusive_dt (this), advective_dt (this));

	// Max time step is set to 1/4 month in order to
	// an accurate calculus of the decay process.
	if (this->dt > 0.25 / 12.) {
		this->dt = 0.25 / 12.;
	}

	snprintf (this->debug_msg, 1024, "Compute Dt = %.1f months, Dt_d = %.1f months, Dt_a = %.1f months",
		 this->dt * 12., diffusive_dt (this) * 12.,
		 advective_dt (this) * 12.);
	debug (this);

}


///////////////////////////////////////////////////////////
// Simulate

void simulate (data * this)
{

	if (not_loaded (this))
		return;

	int iter_n = 0;

	//printf("Simulate start. k=%f e=%f", this->k, this->e);

	snprintf (this->debug_msg, 1024, "Simulate start. k=%f e=%f", this->k,
		 this->e);
	debug (this);

	// Set initial distribution
	set_initial_distribution (this);

	// Compute max. Dt
	compute_dt (this);

	// Main loop
	this->t = 0.;
	while (this->t < this->time) {

		if (this->t + this->dt > this->time) {
			this->dt = this->time - this->t;
		}

		// Isotope input
		isotope_input (this);

		// Mixing scheme
		if (this->t == 0.0 ||
			(int)(this->t/this->mix_time) <
			(int)((this->t+this->dt)/this->mix_time)) 
		if (this->t >= this->mix_ti && this->t <= this->mix_tf)
		mixing_scheme(this);
		
		
			
		// Advective scheme
		advective_scheme (this);

		// Diffusive scheme
		// 2nd order is done in two steps
		diffusive_scheme (this);
		diffusive_scheme (this);

		// Radioactive decay scheme
		decay_scheme (this);

		// Slope limitation
		tvd_scheme (this);
		
		//printf("%.2f\n", this-> mix_time);
		//printf("%.2f\n", this->dt);
		//printf("%.2f\n", this->t);
		//printf("%.2f\n", this->mix_ti);
		//printf("%.2f\n", this->mix_tf);
		//printf("%.2f\n", this->t+this->iy);

		this->t += this->dt;
		iter_n++;
		
		
	}
	

	snprintf (this->debug_msg, 1024, "Simulate end: %d iterations", iter_n);
	debug (this);

}
