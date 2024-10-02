{

  "simulate-until-year"   : 2003.0,

  "tracer-lifetime"       : 28.8811,

  "soil-thickness"        : 0.60,
  "soil-effective-volume" : 1.0,
  "soil-density"          : 1.0,

  "cell-thickness"        : 0.01,
  "numerical-cfl"         : 0.5,

  "mix-from-depth"        : 0.0,
  "mix-to-depth"          : 0.0,
  "mix-interval"          : 1.0,
  "mix-inicial-year"	  : 0.0,
  "mix-final-year"		  : 0.0,

  "fallout" :
    {
      "initial-year"        : 1954.0,
      "final-year"          : 1983.0,
      "mix-depth"           : 0.01,
      "curve" :
        [
            50.0,  150.0,  170.0,  190.0,  320.0,
           350.0,  100.0,  140.0,  530.0, 1220.0,
           670.0,  290.0,  180.0,   70.0,   70.0,
            40.0,   70.0,   70.0,   40.0,   20.0,
            40.0,   20.0,   20.0,   30.0,   30.0,
            10.0,   10.0,   20.0,   10.0,   10.0
        ],
      "reference-inventory" : 1570.0
    },

  "optimization" :
    {
      "k-initial"        :  0.00,
      "k-final"          :  0.40,
      "e-initial"        : -0.02,
      "e-final"          :  0.02,
      "k-samples"        : 70,
      "e-samples"        : 70
    }

}
