/* Outlier Exercise */

DATA MYDATA;
	input y;
datalines;
104.3
132.4
112.4
100.7
105.3
99.0
109.4
101.9
100.5
110.5
112.5
98.8
97
114.8
110.7
114
98.9
112.1
100.6
119.3
RUN;

/* For testing outlier on log-transformated data */
DATA MYDATA;
	SET MYDATA;
/* 	LOG_Y = log(Y); */
	
	y =log(Y);
RUN;



PROC UNIVARIATE data=MYDATA noprint;
	VAR Y;
	OUTPUT OUT=MYDATA_STATS MEAN=MEAN STDDEV=STDDEV N=N MEDIAN=MEDIAN P25=P25 P75=P75;
	qqplot Y / normal( mu=est sigma=est color=red l=2) square;                 
	histogram Y / normal;               
/*                        qqplot LOG_Y / normal(mu=est sigma=est color=red l=2) */
/*                      square; */
/*                       */
/*                       histogram LOG_Y / normal; */          
RUN;

PROC SQL ;
	CREATE TABLE MYDATA AS
	SELECT * FROM MYDATA, MYDATA_STATS;
RUN;



DATA MYDATA;
	SET MYDATA;
	VAR     = STDDEV**2;
	AVG_K	= y - N/(N-1)*(y- MEAN );
	VAR_K   = (N-1)/(N-2)*VAR - N/((N-1)*(N-2))*( Y - MEAN )**2; 
	STDDEV_K = SQRT(VAR_K);
	U		= ( Y - MEAN )/ STDDEV;
	V  		= ( Y - MEAN)/( STDDEV*SQRT( (N-1)/N ) );
	W       = ( Y - MEAN )/ ( STDDEV_K*SQRT( (N-1)/N ) );
	
	/* FOr Doornbos */
	ABS_W   = abs(W);
	/* For Grubbs */
	ABS_U   = abs(U);

	/* For Hample */
	D_K = abs( y - MEDIAN );

	/* For Tukey */
	IQR = P75 - P25;
RUN;

proc univariate data=MYDATA;
	VAR W;
	HISTOGRAM W;
RUN;

PROC RANK
	DATA=MYDATA OUT=PRETTY_DATA;
	VAR Y;
	RANKS R;
RUN;

title "Data and studentized values";
PROC PRINT DATA=PRETTY_DATA;
	VAR  Y U V W R;
RUN;

/* DOORNBOS TEST */
PROC UNIVARIATE data=MYDATA NOPRINT;
	VAR W;
	OUTPUT OUT=W_STATS MAX=MAX MIN=MIN N=N;
RUN;


/* DATA DOORNBOS_RESULT; */
/*  SET W_STATS; */
/*    */
/*  side    = 2; */
/*  DF  	 = N - 2; */
/*  C_VALUE=quantile('T',1-0.05/(N*side),N-2); */
/*   */
/*  IF( DOORNBOS > C_value ) THEN */
/*  	REJECT_H0 = "YES"; */
/*  ELSE */
/* 	REJECT_H0 = "NO"; */
/* RUN; */

%macro doornbos(side,tail);
DATA DOORNBOS_RESULT;
 SET W_STATS;
  
 side    = &side;
 DF  	 = N - 2;
 C_VALUE=quantile('T',1-0.05/(N*side),N-2);
 
 IF( side = 2 ) THEN
 	IF( ABS(MIN) > ABS(MAX) ) THEN
		DOORNBOS = abs(MIN);
 	ELSE
 		DOORNBOS = abs(MAX);
 ELSE
 	IF( "&tail" = "MIN" ) THEN
 		DOORNBOS = -MIN;
 	ELSE
 		DOORNBOS = MAX;
 
 IF( DOORNBOS > C_value ) THEN
 	REJECT_H0 = "YES";
 ELSE
	REJECT_H0 = "NO";
RUN;

proc print data= DOORNBOS_RESULT; 
	VAR side df DOORNBOS C_value REJECT_H0;
	TITLE "DOORNBOS &side-SIDED TEST FOR &tail";
RUN;

%mend;
%doornbos(1,MAX);
%doornbos(1,MIN);
%doornbos(2,ABS);


/* GRUBBS TEST */
PROC UNIVARIATE data=MYDATA NOPRINT;
	VAR U;
	OUTPUT OUT=U_STATS MAX=MAX MIN=MIN N=N;
RUN;

%macro grubbs(side,tail);

DATA GRUBBS_RESULT;
 SET U_STATS;
 
 side    = &side;
 DF  	 = N - 2;
 T_value = quantile('T',1-0.05/( side*N ), DF );
 C_VALUE = SQRT(( N - 1 )**2*( T_value  )**2/(N*( T_value**2 + N - 2 )));
 
 IF( side = 2 ) THEN
 	IF( ABS(MIN) > ABS(MAX) ) THEN
		GRUBBS = abs(MIN);
 	ELSE
 		GRUBBS = abs(MAX);
 ELSE
 	IF( "&tail" = "MIN" ) THEN
 		GRUBBS = -MIN;
 	ELSE
 		GRUBBS = MAX;
 

 
 IF( GRUBBS > C_value ) THEN
 	REJECT_H0 = "YES";
 ELSE
	REJECT_H0 = "NO";
RUN;

proc print data= GRUBBS_RESULT; 
	VAR side df GRUBBS C_value REJECT_H0;
	TITLE "GRUBBS &side-SIDED TEST FOR &tail";
RUN;
%mend;

%grubbs(1,MAX);
%grubbs(1,MIN);
%grubbs(2,ABS);


/* Hampel */
PROC UNIVARIATE data=MYDATA NOPRINT;
	VAR D_K;
	OUTPUT OUT=HAMPEL_STATS MEDIAN=MEDIAN_D_K;
RUN;

PROC SQL ;
	CREATE TABLE MYDATA AS
		SELECT * FROM MYDATA, HAMPEL_STATS;
RUN;

DATA MYDATA;
	SET MYDATA;
	Z_K = abs( Y - MEDIAN)/MEDIAN_D_K;
	IF Z_K > 3.5 THEN
		HAMPEL_OUTLIER = "YES";
	ELSE
		HAMPEL_OUTLIER = "NO";
RUN;

PROC print data=MYDATA;
	VAR Y HAMPEL_OUTLIER;
	title 'HAMPEL TEST';
RUN;

/* Tukey */
DATA MYDATA;
	SET MYDATA;
	IF Y < (P25-1.5*IQR) or  Y > (P75+1.5*IQR) THEN
		TUKEY_OUTLIER = "YES";
	ELSE
		TUKEY_OUTLIER = "NO";
RUN;

PROC print data=MYDATA;
	VAR Y TUKEY_OUTLIER;
	title 'TUKEY TEST';
RUN;


