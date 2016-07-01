/* EX10: Correlation of blood thickness */
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

%checkTie(C);
%checkTie(K);

PROC UNIVARIATE data=bloodmeasure normal;
	VAR C K;
RUN;

/* %inc "/folders/myfolders/macro/mutinorm.sas"; */
/* %multnorm(data=BLOODMEASURE, var=C K, plot=mult); */

PROC sgplot DATA=BLOODMEASURE;
     scatter x=c y=k;
RUN;

data BLOODMEASURE;
	SET BLOODMEASURE;
	IF C < 120 THEN
		BC=1;
	ELSE
		BC=0;
		
	IF K < 120 THEN
		BK=1;
	ELSE
		BK=0;
RUN;

/* H0 : Corr = 0 ( Two variables are independent ) */
PROC CORR DATA=BLOODMEASURE KENDALL SPEARMAN PEARSON FISHER(BIASADJ=NO);
 VAR C K;
RUN;

/* Phi coefficient ( binary outcome ) */
PROC FREQ DATA=BLOODMEASURE;
TABLES BC*BK/CHISQ;
TEST PCORR;
RUN;
