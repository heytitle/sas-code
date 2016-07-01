data CU;
   INPUT VALUE;
   DATALINES;
102
104
102
97
95
106
103
08
96
97
;
RUN;

data CU;
	SET CU;
	IF( VALUE >= 97 and VALUE <= 103 ) THEN
		IN_RANGE = 1;
	ELSE
		IN_RANGE = 0;
RUN;

proc UNIVARIATE data=CU;
	VAR VALUE IN_RANGE;
RUN;