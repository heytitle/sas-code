data BLOODMEASURE;
   INPUT PATID C K;
   DATALINES;
1 120 132
2 114 116
3 129 135
4 128 115
5 155 134
6 105 56
7 114 114
8 145 133
9 120 123
10 129 116
11 126 127
12 136 140
13 135 140
14 125 114
15 117 123
16 125 108
17 136 131
18 151 119
19 130 129
20 136 124
21 113 112
;
RUN;


data BLOODMEASURE;
	SET BLOODMEASURE;
	ZD = C-K;
	ZL = log(C)- log(K);
	ZR = C/K - 1;
	ZRR = K/C - 1;
		
	IF ( C < 120 ) THEN
		C_BELOW_120 = 1;
	ELSE
		C_BELOW_120 = 0;
		
		IF ( K < 120 ) THEN
		K_BELOW_120 = 1;
	ELSE
		K_BELOW_120 = 0;
	
RUN;

%macro checkTie( column );

PROC SQL ;
	CREATE TABLE TIES AS
	SELECT &column, COUNT(&column) AS TIES FROM BLOODMEASURE GROUP BY &column;
RUN;

PROC PRINT DATA=TIES;
	VAR &column TIES;
	TITLE "TIES FOR &column";
RUN;
%mend;

%checkTie(ZD);
%checkTie(ZL);
%checkTie(ZR);
%checkTie(ZRR);

TITLE;
proc univariate data=bloodmeasure normal;
	VAR ZD ZL ZR ZRR;
	HISTOGRAM ZD ZL ZR ZRR / NORMAL;
RUN;

/* title "Binary Paired-test"; */
/* proc freq data=bloodmeasure; */
/* 	tables C_BELOW_120*K_BELOW_120/AGREE; */
/* 	Test Kappa; */
/* RUN; */