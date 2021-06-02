$TITLE OUTDOORINDOOR


OPTION OPTCR=0.1;
OPTION RESLIM=1000000;
OPTION ITERLIM=1000000;


SETS
K        KEYCODE                                         /12S131/
D        DATE                                            /40967, 40969, 40972, 40974/
U        WATER USAGE                                     /INDOOR, OUTDOOR/
;


*SUBSET OUTDOOR CONSUMPTION WINDOW
SET H            HOURLY CONSUMPTION                      /0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23/
    HW(H)        OUTDOOR CONSUMPITON WINDOW              /0, 1, 2, 3, 4, 5, 6, 7, 8, 20, 21, 22, 23/
;


* -----------------------------------------------------
TABLE UTCONS(K,D,U)      WATER CONSUMED BY USAGE
* -----------------------------------------------------
                         INDOOR      OUTDOOR
12S131   .   40967       111.96      62.39
12S131   .   40969       104.79      65.91
12S131   .   40972       288.58      76.99
12S131   .   40974       85.55       52.2
* -----------------------------------------------------
;

* -----------------------------------------------------
TABLE TCONS(K,D)        TOTAL WATER CONSUMED BY USER
* -----------------------------------------------------
*                DATE            TOTAL
                 40967           40969           40972           40974
12S131           174.34          170.7           365.58          137.75
* -----------------------------------------------------
;

* -----------------------------------------------------
TABLE HCONSUMPTION(K,D,H)        TOTAL HOURLY CONSUMPTION BY USER
*KEYCODE     DATE        HOUR
* -----------------------------------------------------
                         0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23
12S131   .   40967       0       0       0       0       0       0       19      5.6     38.7    0.1     0       0       0       0       0       0       4       4.6     0       8.3     11.4    74.2    8.5     0
12S131   .   40969       0       0       0       0       0       2.4     32.1    7.5     44.6    0       0       0       0       0       0       0       2.9     1.1     71.2    1.1     0.6     6.1     0.3     0.9
12S131   .   40972       6       0.1     1       2.4     0       0       0       4.1     11      9       2.2     28.4    24.4    9.3     13.9    25.5    11.3    30.2    95.4    20.5    5       16.4    11.1    38.4
12S131   .   40974       0       0       0       0       0       0.9     0       7       23.5    1.9     0       0       0       0       0       0       0       0       0.2     0.7     1.9     85.9    15.8    0
* -----------------------------------------------------
;

* -----------------------------------------------------
VARIABLE
ETOTAL
DIFF(K,D)
* -----------------------------------------------------
;

* -----------------------------------------------------
POSITIVE VARIABLES
ODEMAND(K,D)
IDEMAND(K,D)
TDEMAND(K,D)
HOCONS(K,D,HW)
HICONS(K,D,H)
* -----------------------------------------------------
;

EQUATIONS
* -----------------------------------------------------
E1(K,D)
E2(K,D)
E3(K,D)
E4(K,D,U)
E5(K,D,U)
E6(K,D)
E7
E8
E9(K,D,HW)
E10(K,D,H)
* -----------------------------------------------------
;

* -----------------------------------------------------
E1(K,D)..             ODEMAND(K,D)=E=SUM(HW,HOCONS(K,D,HW));
E2(K,D)..             IDEMAND(K,D)=E=SUM(H,HICONS(K,D,H));
E3(K,D)..             TDEMAND(K,D)=E=ODEMAND(K,D)+IDEMAND(K,D);
E4(K,D,'OUTDOOR')..   ODEMAND(K,D)=G=UTCONS(K,D,'OUTDOOR');
E5(K,D,'INDOOR')..    IDEMAND(K,D)=G=UTCONS(K,D,'INDOOR');
E6(K,D)..             TDEMAND(K,D)=G=TCONS(K,D);
E7(K,D)..             DIFF(K,D)=E=(TDEMAND(K,D)-TCONS(K,D))/TCONS(K,D);
E8..                  ETOTAL=E=SUM((K,D),DIFF(K,D));
E9(K,D,HW)..          HOCONS(K,D,HW)=L=HCONSUMPTION(K,D,HW);
E10(K,D,H)..          HICONS(K,D,H)=L=HCONSUMPTION(K,D,H);
* -----------------------------------------------------

MODEL OUTDOORINDOOR/ALL/;

*OPTION OPTCR   = 0.0001;
*OPTION OPTCA   = 0.001;
OPTION ITERLIM = 1000000000;
OPTION RESLIM  = 100000000000000;
*OPTION SAVEPOINT = 1


OPTION LP    = CPLEX;
*OPTION LP    = LINDO;

* -----------------------------------------------------
SOLVE OUTDOORINDOOR USING LP MINIMIZING ETOTAL;
* -----------------------------------------------------