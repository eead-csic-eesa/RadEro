/*
 Radiotracer dynamics under soil erosion or sedimentation
 Copyright (C) 2012 Borja Latorre - borja.latorre@csic.es
*/

///////////////////////////////////////////////////////////

float error_rms(float *a, float *b, long j){

	long i;
	float x1, x2, x3;

	x1=x2=x3=0.;

	for(i=0;i<j;i++){

		x1+=(a[i*2]-b[i*2])*(a[i*2]-b[i*2]);
		x2+=a[i*2];
		x3+=b[i*2];

	}

	//return sqrt(x1)/(float)j;
	return 0.5*(sqrt(x1)+fabs(x2-x3))/(float)j;

}


///////////////////////////////////////////////////////////

float error_inv(float *a, float *b, long j){

	long i;
	float x2, x3;

	x2=x3=0.;

	for(i=0;i<j;i++){
		x2+=a[i*2];
		x3+=b[i*2];

	}

	return fabs(x2-x3)/(float)j;

}


///////////////////////////////////////////////////////////

float error_x(data * this, data * this2){

	return error_rms(this->c, this2->c, this->cells);

}

float error_bulk(data * this, data * this2){

	return error_inv(this->c, this2->c, this->cells);

}


///////////////////////////////////////////////////////////

void optimize(data * this, data * this2){

	int i, j, ii, ij;
	float k, e, dk, de;

	float min, mink, mine;

	float x1, x2, x3;

	ii=this->opt_ne;
	ij=this->opt_nk;

	e = this->opt_ei;
	de= (this->opt_ef-this->opt_ei)/(float)ii;

	k = this->opt_ki;
	dk= (this->opt_kf-this->opt_ki)/(float)ij;
	
	x2=invent(this2);

	min   = 1.E15;
	mink = this->opt_ki;
	mine = this->opt_ei;

	for(i=0;i<ii;i++){
		k=this->opt_ki;
		for(j=0;j<ij;j++){
		
			this->k = k;
			this->e = e;
			this->k = this->k * 0.01 * 0.01 * 12. / this->vol;
			this->e = this->e * 0.01 * 12.;
			simulate (this);

			if(ij==1){
				x1 = error_bulk(this, this2);
			}
			else{
				x1 = error_x(this, this2);
			}
			
			x3 = invent(this);

			//fprintf(stderr, "%e\t%e\n", e, x3);

			if(fabs(x2-x3)/(0.5*(x2+x3))<0.02 && x1<min){
				mink = k;
				mine = e;
				min = x1;
			}

			k+=dk;

		}

		e+=de;

	}

	this->k = mink;
	this->e = mine;
	this->k = this->k * 0.01 * 0.01 * 12. / this->vol;
	this->e = this->e * 0.01 * 12.;
	simulate (this);
	this->k = mink;
	this->e = mine;
	
	printf("e = %.6f cm/month, m = %.4f Mg/ha/year, k = %.4f cm2/month, kv = %.4f cm2/month, Experimental-inventory = %.0f Bq/m2, Simulated-inventory = %.0f Bq/m2\n",mine,mine*1200*this->dens,mink,mink*this->vol,invent(this2),invent(this));
	
	    FILE *output_file;
    output_file = fopen("resultstemp.txt", "w"); // Abre el archivo para escritura

    if (output_file == NULL) {
        perror("Error al abrir el archivo resultstemp.txt");
        return;
    }

    fprintf(output_file, "e = %.6f cm/month, m = %.4f Mg/ha/year, k = %.4f cm2/month, kv = %.4f cm2/month, Experimental-inventory = %.0f Bq/m2, Simulated-inventory = %.0f Bq/m2\n", mine, mine * 1200 * this->dens, mink, mink * this->vol, invent(this2), invent(this));

    fclose(output_file); // Cierra el archivo

}
s