/* Normality Exercise */

DATA MYDATA; 
   INPUT ID Y; 
   DATALINES;
1 104.3
2 132.4
3 112.4
4 100.7
5 105.3
6 99.0
7 109.4
8 101.9
9 100.5
10 110.5
11 112.5
12 98.8
13 97.0
14 114.8
15 110.7
16 114.0
17 98.9
18 112.1
19 100.6
20 119.3
; 
RUN;

DATA MYDATA;
	set MYDATA;
/* 	Y=log(Y); */
	LOG_Y=Y;
RUN;

/* Check ties */
proc rank data=MYDATA out=MYDATA;
   var Y;
   ranks RANK;
run;

/* Regular Normality tests */
PROC UNIVARIATE data=MYDATA normal;
	VAR Y LOG_Y;
	HISTOGRAM Y / normal( mu=est sigma=est  );
	HISTOGRAM LOG_Y / normal ( mu=est sigma=est  ) ;
CDFPLOT Y/ normal ( mu=est sigma=est  ) ;;
RUN;

PROC UNIVARIATE data=MYDATA noprint;
	VAR Y;
	OUTPUT OUT=MYDATA_STATS STDDEV=STDDEV N=N SKEW=SKEW;
RUN;

PROC SQL ;
	CREATE TABLE MYDATA AS
	SELECT * FROM MYDATA, MYDATA_STATS;
RUN;

/* D’Agostino */
DATA D_AGOS;
	SET MYDATA;
	D = Y*(RANK - 0.5*(N+1))/( STDDEV*SQRT(N**3*(N-1)) );
RUN;

PROC UNIVARIATE data=d_agos noprint;
	OUTPUT OUT=D_AGOS_STATS SUM=D  N=N;
	VAR D;
RUN;

DATA D_AGOS_RESULT;
	SET D_AGOS_STATS;
	MU_D = 0.28209479;
	STDDEV_D = 0.02998598/SQRT(N);
	Un = ( D - MU_D)/STDDEV_D;
	
	/* Critical value corresponding to N=20 */
	C_Un = 0.628;
	C_Ln = -3.04; 
	/* END INPUT */
	
	IF ( Un < C_Un and Un > C_Ln ) THEN
		REJECT_H0 = "NO";
	ELSE
		REJECT_H0 = "YES";
RUN;

TITLE "D’Agostino normality test";
proc print data=d_agos_result;
	VAR N D MU_D STDDEV_D C_Ln Un C_Un REJECT_H0;
RUN;

/* Skewness */
PROC UNIVARIATE data=MYDATA noprint;
	VAR Y;
	OUTPUT OUT=SKEWNESS_RES N=N SKEW=SKEW;
RUN;

DATA SKEWNESS_RES;
	SET SKEWNESS_RES;
	
	SQRT_B1 = (N-2)*SKEW/SQRT(N*(N-1));

	/* FOR N=20 */
	C_UT = 0.951;
	
	IF ( SQRT_B1 < C_UT ) THEN
		REJECT_H0 = "NO";
	ELSE
		REJECT_H0 = "YES";
RUN;

TITLE "SKEWNESS normality test";
TITLE2 "pleasec check critical values corresponding to n";
PROC PRINT DATA=SKEWNESS_RES;
RUN;

/* Kurtosis */
PROC UNIVARIATE data=MYDATA noprint;
	VAR Y;
	OUTPUT OUT=KURTOSIS_RES N=N KURT=KURT;
RUN;


DATA KURTOSIS_RES;
	SET KURTOSIS_RES;
	
	/* FOR N = 20 */
	C_LT = 1.73;
	C_UT = 4.68;
	
	
	B2 = (N-2)*(N-3)/((N+1)*(N-1))*KURT + 3*(N-1)/(N+1);
	
	IF ( B2 > C_LT and B2 < C_UT ) THEN
		REJECT_H0 = "NO";
	ELSE
		REJECT_H0 = "YES";
RUN;

TITLE "KURTOSIS normality test";
TITLE2 "pleasec check critical values corresponding to n";
PROC PRINT DATA=KURTOSIS_RES;
RUN;

