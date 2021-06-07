#  STRANGE ATTRACTOR PROGRAM  QuickC Ver 2.0 (c) 1993 by J. C. Sprott */

global glob = Dict()

glob[:CODE] = ""
glob[:FAV] = "XDATA.DAT"
glob[:XS] = zeros(Float64, 500)
glob[:YS] = zeros(Float64, 500)
glob[:ZS] = zeros(Float64, 500)
glob[:WS] = zeros(Float64, 500)
glob[:AS] = zeros(Float64, 505)
glob[:V] = zeros(Float64, 100)
glob[:XY] = zeros(Float64, 5)
glob[:XN] = zeros(Float64, 5)

glob[:F1] = nothing
glob[:F2] = nothing
glob[:F3] = nothing

function main()
	global glob
	glob[:PREV] = 5;                   #  Plot versus fifth previous iterate */
	glob[:NMAX] = 11000;               #  Maximum number of iterations */
	glob[:OMAX] = 5;                   #  Maximum order of polynomial */
	glob[:D] = 2;                      #  Dimension of system */
	glob[:EPS] = .1;                   #  Step size for ODE */
	glob[:ODE] = 0;                    #  System is map */
	glob[:SND] = 0;                    #  Turn sound off */
	glob[:PJT] = 0;                    #  Projection is planar */
	glob[:TRD] = 1;                    #  Display third dimension as shadow */
	glob[:FTH] = 2;                    #  Display fourth dimension as colors */
	glob[:SAV] = 0;                    #  Don't save any data */

	menu();                  #  Display menu screen */

	glob[:T] = 1;
	if glob[:Q] == 'X'
		glob[:T] = 0;        #  Exit immediately on command */
	end

	while glob[:T] > 0
		if glob[:T] == 1
			initialize();  #  Initialize */
			glob[:T] = 2
		end
		if glob[:T] == 2
			set_parameters();  #  Set parameters */
			glob[:T] = 3
		end

		if glob[:T] == 3
			iterate();   #  Iterate equations */
			glob[:T] = 4
		end

		if glob[:T] == 4
			display_results()
			glob[:T] = 5
		end

		if glob[:T] == 5
			test_results()
			glob[:T] = 1
		end
	end
end

function initialize() #  Initialize */
	global glob
	glob[:W] = 80
	println("Searching...");

	set_colors()

	if glob[:QM] == 2
		glob[:NE] = 0
		if glob[:F1] != nothing
			fclose(f1)
		end
		glob[:F1] = open("SA.DIC", "r")
	end
end

function set_parameters() #  Set parameters */
	global glob
	glob[:X] = .05                    #  Initial condition */
	glob[:Y] = .05
	glob[:Z] = .05
	glob[:W] = .05
	glob[:XE] = glob[:X] + .000001
	glob[:YE] = glob[:Y]
	glob[:ZE] = glob[:Z]
	glob[:WE] = glob[:W]

	got_coefficients()

	glob[:T] = 3
	glob[:P] = 0
	glob[:LSUM] = 0
	glob[:N] = 0
	glob[:NL] = 0
	glob[:N1] = 0
	glob[:N2] = 0
	glob[:XMIN] = 1000000
	glob[:XMAX] = -glob[:XMIN]
	glob[:YMIN] = glob[:XMIN]
	glob[:YMAX] = glob[:XMAX]
	glob[:ZMIN] = glob[:XMIN]
	glob[:ZMAX] = glob[:XMAX]
	glob[:WMIN] = glob[:XMIN]
	glob[:WMAX] = glob[:MAX]
	glob[:TWOD] = 2glob[:D]
end

function iterate() #  Iterate equations */
	global glob
	if glob[:ODE] > 1
		fun6200()              #  Special function */
	else
		glob[:M] = 1;
		glob[:XY][1] = glob[:X]
		glob[:XY][2] = glob[:Y]
		glob[:XY][3] = glob[:Z]
		glob[:XY][4] = glob[:W]
		for I in 1:glob[:D]
			glob[:XN][I] = glob[:A][glob[:M]]
			glob[:M] = glob[:M] + 1
			for I1 in 1:glob[:D]
				glob[:XN][I] = glob[:XN][I] + glob[:A][glob[:M]] * glob[:XY][I1]
				glob[:M] = glob[:M] + 1
				for I2 in I1:glob[:D]
					glob[:XN][i] = glob[:XN][I] + glob[:A][glob[:M]] * glob[:XY][I1] * glob[:XY][I2]
					glob[:M] = glob[:M] + 1
					for I3 in I2:glob[:D]
						if ! glob[:O] > 2
							break
						end
						glob[:XN][I] = glob[:XN][I] + glob[:A][glob[:M]] * glob[:XY][I1] * glob[:XY][I2] * glob[:XY][I3]
						glob[:M] = glob[:M] + 1
						for I4 in I3:glob[:D]
							if ! glob[:O] > 3
								break
							end
							glob[:XN][I] = glob[:XN][I] + glob[:A][glob[:M]] * glob[:XY][I1] * glob[:XY][I2] * glob[:XY][I3] * glob[:XY][I4]
							glob[:M] = glob[:M] + 1
							for I5 in I4:glob[:D]
								if ! glob[:O] > 4
									break
								end
								glob[:XN][I] = glob[:XN][I] + glob[:A][glob[:M]] * glob[:XY][I1] * glob[:XY][I2] * glob[:XY][I3] * glob[:XY][I4] * glob[:XY][I5]
								glob[:M] = glob[:M] + 1;
							end
						end
					end
				end
			end
			if glob[:ODE] == 1
				glob[:XN][I] = glob[:XY][I] + glob[:EPS] * glob[:XN][I]
			end
		end
		glob[:XNEW] = glob[:XN][1];
		glob[:YNEW] = glob[:XN][2];
		glob[:ZNEW] = glob[:XN][3];
		glob[:WNEW] = glob[:XN][4];
	end
	glob[:N] = glob[:N] + 1;
	glob[:M] = glob[:M] - 1;
end

function display_results()

	if glob[:N] >= 100 && glob[:N] <= 1000
		if glob[:X] < glob[:XMIN]
			 glob[:XMIN] = glob[:X]
		end
		if glob[:X] > glob[:XMAX]
			glob[:XMAX] = glob[:X]
		end
		if glob[:Y] < glob[:YMIN]
			glob[:YMIN] = glob[:Y]
		end
		if glob[:Y] > glob[:YMAX]
			glob[:YMAX] = glob[:Y]
		end
		if glob[:Z] < glob[:ZMIN]
			glob[:ZMIN] = glob[:Z]
		end
		if glob[:Z] > glob[:ZMAX]
			glob[:ZMAX] = glob[:Z]
		end
		if glob[:W] < glob[:WMIN
			glob[:WMIN] =glob[:W]
		end
		if glob[:W] > glob[:WMAX]
			glob[:WMAX] = glob[:W]
		end
	end
	if glob[:N] == 1000
		fun3100();  #  Resize the screen */
	end
	glob[:XS][glob[:P]] = glob[:X]
	glob[:YS][glob[:P]] = glob[:Y]
	glob[:ZS][glob[:P]] = glob[:Z]
	glob[:WS][glob[:P]] = glob[:W]
	glob[:P] = (glob[:P] + 1) % 500
	glob[:I] = (glob[:P] + 500 - glob[:PREV]) % 500
	if glob[:D] == 1
		glob[:XP] = glob[:XS][glob[:I]]
		blog[:YP] = glob[:XNEW]
	else
		glob[:XP] = glob[:X]
		glob[:YP] = glob[:Y]
	end
	if (N >= 1000 && XP > XL && XP < XH && YP > YL && YP < YH) {
		if (PJT == 1) fun4100();    #  Project onto a sphere */
		if (PJT == 2) fun6700();    #  Project onto a horizontal cylinder */
		if (PJT == 3) fun6800();    #  Project onto a vertical cylinder */
		if (PJT == 4) fun6900();    #  Project onto a torus */
		fun5000();                  #  Plot point on screen */
		if (SND == 1) fun3500();    #  Produce sound */
	}
}

function test_results() #  Test results */
{
if (fabs(XNEW) + fabs(YNEW) + fabs(ZNEW) + fabs(WNEW) > 1000000) T = 2;
if (QM != 2) {              #  Speed up evaluation mode */
	fun2900();              #  Calculate Lyapunov exponent */
	fun3900();              #  Calculate fractal dimension */
	if (QM == 0) {          #  Skip tests unless in search mode */
		if (N >= NMAX) {    #  Strange attractor found */
			T = 2;
			fun4900();      #  Save attractor to disk file SA.DIC */
		}
		if (fabs(XNEW - X) + fabs(YNEW - Y) + fabs(ZNEW - Z) + fabs(WNEW - W) < .000001) T = 2;
		if (N > 100 && L < .005) T = 2; #  Limit cycle */
	}
}
if (kbhit()) Q = getch(); else Q = 0;
if (Q) fun3600();           #  Respond to user command */
if (SAV > 0) if (N > 1000 && N < 17001) fun7000();  #  Save data */
X = XNEW;                   #  Update value of X */
Y = YNEW;
Z = ZNEW;
W = WNEW;
}

function get_coefficients()
	global glob
	if glob[:QM] == 2              #  In evaluate mode */
		glob[:CODE] = read(glob[:F1], nb=515)
	end
	if eof(glob[:F1)
		glob[:QM] = 0
		fun6000()          #  Update SA.DIC file */
	else
		fun4700()          #  Get dimension and order */
		set_colors()          #  Set colors */
	end

	if glob[:QM] == 0              #  In search mode */
		glob[:O] = 2 + floor(Int64, ((glob[:OMAX] - 1) * rand() / 32768.0)
		glob[:CODE][1] = 59 + 4glob[:D] + glob[:O] + 8glob[:ODE]
		if glob[:ODE] > 1
			 glob[:CODE][1] = 87 + glob[:ODE]
		end
		fun4700();              #  Get value of M */
		for i in 2:glob[:M]  #  Construct CODE */
		   shuffle()           #  Shuffle random numbers */
		   glob[:CODE][i] = 65 + floor(Int, 25 * glob[:RAN]);
	   end
	end

	glob[:A] = map(x->(x-77)/10), glob[:CODE])
end

function shuffle()
	if glob[:V][1] == 0
		glob[:V] = rand(100)
	end
	j = floor(Int, 1 + 99rand())
	glob[:RAN] = glob[:V][j]
	glob[:V][j] = rand()
end

function lyapunov() # fun2900() #  Calculate Lyapunov exponent */
	glob[:XSAVE] = glob[:XNEW]
	glob[:YSAVE] = glob[:YNEW]
	glob[:ZSAVE] = glob[:ZNEW]
	glob[:WSAVE] = glob[:WNEW]
	glob[:X] = glob[:XE]
	glob[:Y] = glob[:YE]
	glob[:Z] = glob[:ZE]
	glob[:W] = glob[:WE]
	glob[:N] = glob[:N] - 1
	fun1700();                  #  Reiterate equations */
	glob[:DLX] = glob[:XNEW] - glob[:XSAVE]
	glob[:DLY] = glob[:YNEW] - glob[:YSAVE]
	glob[:DLZ] = glob[:ZNEW] - glob[:ZSAVE]
	glob[:DLW] = glob[:WNEW] - glob[:WSAVE]
	glob[:DL2] = glob[:DLX] * glob[:DLX] + glob[:DLY] * glob[:DLY] + glob[:DLZ] * glob[:DLZ] + glob[:DLW] * glob[:DLW]
	if glob[:DL2] > 0              #  Check for division by zero */
		glob[:DF] = 1E12 * glob[:DL2]
		glob[:RS] = 1 / sqrt(glob[:DF])
		glob[:XE] = glob[:XSAVE] + glob[:RS] * (glob[:XNEW] - glob[:XSAVE])
		glob[:YE] = glob[:YSAVE] + glob[:RS] * (glob[:YNEW] - glob[:YSAVE])
		glob[:ZE] = glob[:ZSAVE] + glob[:RS] * (glob[:ZNEW] - glob[:ZSAVE])
		glob[:WE] = glob[:WSAVE] + glob[:RS] * (glob[:WNEW] - glob[:WSAVE])
		glob[:XNEW] = glob[:XSAVE]
		glob[:YNEW] = glob[:YSAVE]
		glob[:ZNEW] = glob[:ZSAVE]
		glob[:WNEW] = glob[:WSAVE]
		glob[:LSUM] = glob[:LSUM] + log(glob[:DF]);
		glob[:NL] = glob[:NL] + 1;
		glob[:L] = .721347 * glob[:LSUM] / glob[:NL];
		if glob[:ODE] == 1 || glob[:ODE] == 7
			glob[:L] = glob[:L] / glob[:EPS]
		end
		if glob[:N] > 1000 && glob[:N] % 10 == 0
			printf("%5.2f", glob[:L]);
		end
	end
end

fun3100() #  Resize the screen */
{
_setcolor(WH);
if (D == 1) {
	YMIN = XMIN;
	YMAX = XMAX;
}
if (XMAX - XMIN < .000001) {
	XMIN = XMIN - .0000005;
	XMAX = XMAX + .0000005;
}
if (YMAX - YMIN < .000001) {
	YMIN = YMIN - .0000005;
	YMAX = YMAX + .0000005;
}
if (ZMAX - ZMIN < .000001) {
	ZMIN = ZMIN - .0000005;
	ZMAX = ZMAX + .0000005;
}
if (WMAX - WMIN < .000001) {
	WMIN = WMIN - .0000005;
	WMAX = WMAX + .0000005;
}
MX = .1 * (XMAX - XMIN);
MY = .1 * (YMAX - YMIN);
XL = XMIN - MX;
XH = XMAX + MX;
YL = YMIN - MY;
YH = YMAX + 1.5 * MY;
SW = 640 / (XH - XL);
SH = 480 / (YL - YH);
_setvieworg((short)(-SW * XL), (short)(-SH * YH));
_clearscreen(_GCLEARSCREEN);
YH = YH - .5 * MY;
XA = (XL + XH) / 2;
YA = (YL + YH) / 2;
if (D > 2) {
	ZA = (ZMAX + ZMIN) / 2;
	if (TRD == 1) {
		_setcolor(COLR[1]);
		_rectangle_w(_GFILLINTERIOR, SW * XL, SH * YL, SW * XH, SH * YH);
		fun5400();          #  Plot background grid */
	}
	if (TRD == 4) {
		_setcolor(WH);
		_rectangle_w(_GFILLINTERIOR, SW * XL, SH * YL, SW * XH, SH * YH);
	}
	if (TRD == 5) {
		_moveto_w(SW * XA, SH * YL);
		_lineto_w(SW * XA, SH * YH);
	}
	if (TRD == 6) {
		for (I = 1; I <= 3; I++) {
			XP = XL + I * (XH - XL) / 4;
			_moveto_w(SW * XP, SH * YL);
			_lineto_w(SW * XP, SH * YH);
			YP = YL + I * (YH - YL) / 4;
			_moveto_w(SW * XL, SH * YP);
			_lineto_w(SW * XH, SH * YP);
		}
	}
}
if (PJT != 1) _rectangle_w(_GBORDER, SW * XL + 1, SH * YL - 1, SW * XH - 1, SH * YH + 1);
if (PJT == 1 && TRD < 5) _ellipse_w(_GBORDER, SW * XL - SH * (YH - YL) / 6, SH * YH, SW * XH + SH * (YH - YL) / 6, SH * YL);
TT = 3.1416 / (XMAX - XMIN);
PT = 3.1416 / (YMAX - YMIN);
if (QM == 2) {              #  In evaluate mode */
	_settextposition(1, 1);
	printf("<Space Bar>: Discard       <Enter>: Save");
	if (WID >= 80) {
		_settextposition(1, 49);
		printf("<Esc>: Exit");
		_settextposition(1, 69);
		printf("%d K left", (int)((filelength(fileno(F1)) - ftell(F1)) / 1024.0));
	}}
else {
	_settextposition(1, 1);
	if (strlen(CODE) < WID - 18)
		_outtext(CODE);
	else {
		printf("%*.*s...", WID - 23, WID - 23, CODE);
	}
	_settextposition(1, WID - 17);
	printf("F =");
	_settextposition(1, WID - 7);
	printf("L = ");
}
TIA = .05;                  #  Tangent of illumination angle */
XZ = -TIA * (XMAX - XMIN) / (ZMAX - ZMIN);
YZ = TIA * (YMAX - YMIN) / (ZMAX - ZMIN);
}

fun3500() #  Produce sound */
{
FREQ = 220 * pow(2, (int)(36 * (XNEW - XL) / (XH - XL)) / 12.0);
DUR = 1;
if (D > 1) DUR = pow(2, (int)floor(.5 * (YH - YL) / (YNEW - 9 * YL / 8 + YH / 8)));
#  A sound statement should be placed here */
}

fun3600() #  Respond to user command */
{
if (Q > 96) Q = Q - 32;     #  Convert to upper case */
if (QM == 2) fun5800();     #  Process evaluation command */
if (strchr("ACDEHINPRSVX", Q) == 0) menu();  #  Display menu screen */
if (Q == 'A') {
	T = 1;
	QM = 0;
}
if (ODE > 1) D = ODE + 5;
if (ODE == 1) D = D + 2;
if (Q == 'C') if (N > 999) N = 999;
if (Q == 'D') {
	D = 1 + D % 12;
	T = 1;
}
if (D > 6) {
	ODE = D - 5;
	D = 4;
}
else {
	if (D > 4) {
		ODE = 1;
		D = D - 2;
	}
	else ODE = 0;
}
if (Q == 'E') {
	T = 1;
	QM = 2;
}
if (Q == 'H') {
	FTH = (FTH + 1) % 3;
	T = 3;
	if (N > 999) {
		N = 999;
		set_colors()          #  Set colors */
	}
}
if (Q == 'I') {
	if (T != 1) {
		_setvideomode(_TEXTC80);
		_settextcolor(15);
		_setbkcolor(1L);
		_clearscreen(_GCLEARSCREEN);
		printf("Code? ");
		I = 0;
		CODE[0] = 0;
		do {
			CODE[I] = getche();
			if (CODE[I] == 8 && I >= 0) I = I - 2;
			if (CODE[I] == 27) {
				I = 0;
				CODE[I] = 13;
			}
		}
		while (CODE[I++] != 13 && I < 506);
		CODE[I - 1] = 0;
		if (CODE[0] == 0) {
			Q = ' ';
			_clearscreen(_GCLEARSCREEN);}
		else {
			T = 1;
			QM = 1;
			fun4700();
		}
	}
}
if (Q == 'N') {
	NMAX = 10 * (NMAX - 1000) + 1000;
	if (NMAX > 1E10) NMAX = 2000;
}
if (Q == 'P') {
	PJT = (PJT + 1) % 5;
	T = 3;
	if (N > 999) N = 999;
}
if (Q == 'R') {
	TRD = (TRD + 1) % 7;
	T = 3;
	if (N > 999) {
		N = 999;
		set_colors() # although this might be a bug
	}
}
if (Q == 'S') {
	SND = (SND + 1) % 2;
	T = 3;
}
if (Q == 'V') {
	SAV = (SAV + 1) % 5;
	FAV[0] = 87 + SAV % 4;
	T = 3;
	if (N > 999) N = 999;
}
if (Q == 'X') T = 0;
}

fun3900() #  Calculate fractal dimension */
{
if (N >= 1000) {            #  Wait for transient to settle */
	if ((int)N == 1000) {
		D2MAX = pow(XMAX - XMIN, 2);
		D2MAX = D2MAX + pow(YMAX - YMIN, 2);
		D2MAX = D2MAX + pow(ZMAX - ZMIN, 2);
		D2MAX = D2MAX + pow(WMAX - WMIN, 2);
	}
	J = (P + 1 + (int)floor(480 * (float)rand() / 32768.0)) % 500;
	DX = XNEW - XS[J];
	DY = YNEW - YS[J];
	DZ = ZNEW - ZS[J];
	DW = WNEW - WS[J];
	D2 = DX * DX + DY * DY + DZ * DZ + DW * DW;
	if (D2 < .001 * TWOD * D2MAX) N2 = N2 + 1;
	if (D2 <= .00001 * TWOD * D2MAX) {
		N1 = N1 + 1;
		F = .434294 * log(N2 / (N1 - .5));
		_settextposition(1, WID - 14);
		printf("%5.2f", F);
	}
}
}

fun4100() #  Project onto a sphere */
{
TH = TT * (XMAX - XP);
PH = PT * (YMAX - YP);
XP = XA + .36 * (XH - XL) * cos(TH) * sin(PH);
YP = YA + .5 * (YH - YL) * cos(PH);
}

menu() #  Display menu screen */
{
_setvideomode(_TEXTC80);
_settextcolor(15);
_setbkcolor(1L);
regs.h.ah = 1;
regs.h.ch = 1;
regs.h.cl = 0;
int86(16, &regs, &regs);    #  Turn cursor off */
_clearscreen(_GCLEARSCREEN);
while (Q == 0 || strchr("AEIX", Q) == 0) {
	_settextposition(1, 27);
	printf("STRANGE ATTRACTOR PROGRAM\n");
	printf("%26cIBM PC QuickC Version 2.0\n", ' ');
	printf("%26c(c) 1993 by J. C. Sprott\n", ' ');
	printf("\n");
	printf("\n");
	printf("%26cA: Search for attractors\n", ' ');
	printf("%26cC: Clear screen and restart\n", ' ');
	if (ODE > 1) {
		printf("%26cD: System is 4-D special map %c \n", ' ', 87 + ODE);}
	else {
		printf("%26cD: System is %d-D polynomial ", ' ', D);
		if (ODE == 1) printf("ODE\n"); else printf("map\n");
	}
	printf("%26cE: Evaluate attractors\n", ' ');
	printf("%26cH: Fourth dimension is ", ' ');
		if (FTH == 0) printf("projection\n");
		if (FTH == 1) printf("bands     \n");
		if (FTH == 2) printf("colors    \n");
	printf("%26cI: Input code from keyboard\n", ' ');
	printf("%26cN: Number of iterations is 10^%1.0f\n", ' ', log10(NMAX - 1000));
	printf("%26cP: Projection is ", ' ');
		if (PJT == 0) printf("planar   \n");
		if (PJT == 1) printf("spherical\n");
		if (PJT == 2) printf("horiz cyl\n");
		if (PJT == 3) printf("vert cyl \n");
		if (PJT == 4) printf("toroidal \n");
	printf("%26cR: Third dimension is ", ' ');
		if (TRD == 0) printf("projection\n");
		if (TRD == 1) printf("shadow    \n");
		if (TRD == 2) printf("bands     \n");
		if (TRD == 3) printf("colors    \n");
		if (TRD == 4) printf("anaglyph  \n");
		if (TRD == 5) printf("stereogram\n");
		if (TRD == 6) printf("slices    \n");
	printf("%26cS: Sound is ", ' ');
		if (SND == 0) printf("off\n");
		if (SND == 1) printf("on \n");
	printf("%26cV: ", ' ');
		if (SAV == 0) printf("No data will be saved       \n");
		if (SAV > 0) printf("%c will be saved in %cDATA.DAT\n", FAV[0], FAV[0]);
	printf("%26cX: Exit program", ' ');
	if (kbhit()) Q = getch(); else Q = 0;
	if (Q) fun3600();       #  Respond to user command */
}
}

fun4700() #  Get dimension and order */
{
D = 1 + (int)floor((CODE[0] - 65) / 4);
if (D > 6) {
	ODE = CODE[0] - 87;
	D = 4;
	fun6200();              #  Special function */
}
else {
	if (D > 4) {
		D = D - 2;
		ODE = 1;
	}
	else ODE = 0;
	O = 2 + (CODE[0] - 65) % 4;
	M = 1;
	for (I = 1; I <= D; I++) {M = M * (O + I);}
	if (D > 2) for (I = 3; I <= D; I++) {M = M / (I - 1);}
}
if (strlen(CODE) != M + 1 && QM == 1) {
   printf("\a");            #  Illegal code warning */
   while (strlen(CODE) < M + 1) strcat(CODE, "M");
   if (strlen(CODE) > M + 1) CODE[M + 1] = 0;
}
}

fun4900() #  Save attractor to disk file SA.DIC */
{
F1 = fopen("SA.DIC", "a");
fprintf(F1, "%s%5.2f%5.2f\n", CODE, F, L);
fclose(F1);
}

fun5000() #  Plot point on screen */
{
C4 = WH;
if (D > 3) {
   if (FTH == 1) if ((int)floor(30 * (W - WMIN) / (WMAX - WMIN)) % 2) return(0);
   if (FTH == 2) C4 = 1 + (int)floor(NC * (W - WMIN) / (WMAX - WMIN) + NC) % NC;
}
if (D < 3) {                #  Skip 3-D stuff */
	_setpixel_w(SW * XP, SH * YP);
	return(0);
}
if (TRD == 0) {
	_setcolor(C4);
	_setpixel_w(SW * XP, SH * YP);
}
if (TRD == 1) {
	if (D > 3 && FTH == 2) {
		_setcolor(C4);
		_setpixel_w(SW * XP, SH * YP);
	}
	else {
		C = _getpixel_w(SW * XP, SH * YP);
		if (C == COLR[2]) {
			_setcolor(COLR[3]);
			_setpixel_w(SW * XP, SH * YP);}
		else {
			if (C != COLR[3]) {
				_setcolor(COLR[2]);
				_setpixel_w(SW * XP, SH * YP);
			}
		}
	}
	XP = XP - XZ * (Z - ZMIN);
	YP = YP - YZ * (Z - ZMIN);
	if (_getpixel_w(SW * XP, SH * YP) == COLR[1]) {
		_setcolor(0);
		_setpixel_w(SW * XP, SH * YP);
	}
}
if (TRD == 2) {
	if (D > 3 && FTH == 2 && ((int)floor(15 * (Z - ZMIN) / (ZMAX - ZMIN) + 2) % 2) == 1) {
		_setcolor(C4);}
	else {
		C = COLR[(int)floor(60 * (Z - ZMIN) / (ZMAX - ZMIN) + 4) % 4];
		_setcolor(C);
	}
	_setpixel_w(SW * XP, SH * YP);
}
if (TRD == 3) {
	_setcolor(COLR[(int)floor(NC * (Z - ZMIN) / (ZMAX - ZMIN) + NC) % NC]);
	_setpixel_w(SW * XP, SH * YP);
}
if (TRD == 4) {
	XRT = XP + XZ * (Z - ZA);
	C = _getpixel_w(SW * XRT, SH * YP);
	if (C == WH) {
		_setcolor(RD);
		_setpixel_w(SW * XRT, SH * YP);
	}
	if (C == CY) {
		_setcolor(BK);
		_setpixel_w(SW * XRT, SH * YP);
	}
	XLT = XP - XZ * (Z - ZA);
	C = _getpixel_w(SW * XLT, SH * YP);
	if (C == WH) {
		_setcolor(CY);
		_setpixel_w(SW * XLT, SH * YP);
	}
	if (C == RD) {
		_setcolor(BK);
		_setpixel_w(SW * XLT, SH * YP);
	}
}
if (TRD == 5) {
	HSF = 2;                #  Horizontal scale factor */
	XRT = XA + (XP + XZ * (Z - ZA) - XL) / HSF;
	_setcolor(C4);
	_setpixel_w(SW * XRT, SH * YP);
	XLT = XA + (XP - XZ * (Z - ZA) - XH) / HSF;
	_setcolor(C4);
	_setpixel_w(SW * XLT, SH * YP);
}
if (TRD == 6) {
   DZ = (15 * (Z - ZMIN) / (ZMAX - ZMIN) + .5) / 16;
   XP = (XP - XL + ((int)floor(16 * DZ) % 4) * (XH - XL)) / 4 + XL;
   YP = (YP - YL + (3 - (int)floor(4 * DZ) % 4) * (YH - YL)) / 4 + YL;
   _setcolor(C4);
   _setpixel_w(SW * XP, SH * YP);
}
}

fun5400() #  Plot background grid */
{
_setcolor(0);
for (I = 0; I <= 15; I++) { #  Draw 15 vertical grid lines */
	XP = XMIN + I * (XMAX - XMIN) / 15;
	_moveto_w(SW * XP, SH * YMIN);
	_lineto_w(SW * XP, SH * YMAX);
}
for (I = 0; I <= 10; I++) { #  Draw 10 horizontal grid lines */
	YP = YMIN + I * (YMAX - YMIN) / 10;
	_moveto_w(SW * XMIN, SH * YP);
	_lineto_w(SW * XMAX, SH * YP);
}
}

fun5600() #  Set colors */
{
NC = 15;                    #  Number of colors */
COLR[0] = 0;
COLR[1] = 8;
COLR[2] = 7;
COLR[3] = 15;
if (TRD == 3 || (D > 3 && FTH == 2 && TRD != 1)) {
	for (I = 0; I <= NC; I++) COLR[I] = I + 1;
}
WH = 15;
BK = 8;
RD = 12;
CY = 11;
}

fun5800() #  Process evaluation command */
{
if (Q == ' ') {
	T = 2;
	NE = NE + 1;
	_clearscreen(_GCLEARSCREEN);
}
if (Q == 13) {
	T = 2;
	NE = NE + 1;
	_clearscreen(_GCLEARSCREEN);
	fun5900();              #  Save favorite attractors to disk */
}
if (Q == 27) {
	_clearscreen(_GCLEARSCREEN);
	fun6000();              #  Update SA.DIC file */
	Q = ' ';
	QM = 0;
}
else {
	if (strchr("CHNPRVS", Q) == 0) Q = 0;
}
}

fun5900() #  Save favorite attractors to disk file FAVORITE.DIC */
{
F2 = fopen("FAVORITE.DIC", "a");
fprintf(F2, CODE);
fclose(F2);
}

fun6000() #  Update SA.DIC file */
{
_settextposition(11, 9);
printf("Evaluation complete\n");
_settextposition(12, 8);
printf(" %d cases evaluated", (int)NE);
F2 = fopen("SATEMP.DIC", "w");
if (QM == 2) fprintf(F2, CODE);
while (feof(F1) == 0) {
	fgets(CODE, 515, F1);
	if (feof(F1) == 0) fprintf(F2, CODE);
}
fcloseall();
remove("SA.DIC");
rename("SATEMP.DIC", "SA.DIC");
}

fun6200() #  Special function definitions */
{
ZNEW = X * X + Y * Y;       #  Default 3rd and 4th dimension */
WNEW = (N - 100) / 900;
if (N > 1000) WNEW = (N - 1000) / (NMAX - 1000);
if (ODE == 2) {
	M = 10;
	XNEW = A[1] + A[2] * X + A[3] * Y + A[4] * fabs(X) + A[5] * fabs(Y);
	YNEW = A[6] + A[7] * X + A[8] * Y + A[9] * fabs(X) + A[10] * fabs(Y);
}
if (ODE == 3) {
	M = 14;
	XNEW = A[1] + A[2] * X + A[3] * Y + ((int)(A[4] * X + .5) & (int)(A[5] * Y + .5)) + ((int)(A[6] * X + .5) | (int)(A[7] * Y + .5));
	YNEW = A[8] + A[9] * X + A[10] * Y + ((int)(A[11] * X + .5) & (int)(A[12] * Y + .5)) + ((int)(A[13] * X + .5) | (int)(A[14] * Y + .5));
}
if (ODE == 4) {
	M = 14;
	XNEW = A[1] + A[2] * X + A[3] * Y + A[4] * pow(fabs(X), A[5]) + A[6] * pow(fabs(Y), A[7]);
	YNEW = A[8] + A[9] * X + A[10] * Y + A[11] * pow(fabs(X), A[12]) + A[13] * pow(fabs(Y), A[14]);
}
if (ODE == 5) {
	M = 18;
	XNEW = A[1] + A[2] * X + A[3] * Y + A[4] * sin(A[5] * X + A[6]) + A[7] * sin(A[8] * Y + A[9]);
	YNEW = A[10] + A[11] * X + A[12] * Y + A[13] * sin(A[14] * X + A[15]) + A[16] * sin(A[17] * Y + A[18]);
}
if (ODE == 6) {
	M = 6;
	if (N < 2) {
		AL = TWOPI / (13 + 10 * A[6]);
		SINAL = sin(AL);
		COSAL = cos(AL);
	}
	DUM = X + A[2] * sin(A[3] * Y + A[4]);
	XNEW = 10 * A[1] + DUM * COSAL + Y * SINAL;
	YNEW = 10 * A[5] - DUM * SINAL + Y * COSAL;
}
if (ODE == 7) {
	M = 9;
	XNEW = X + EPS * A[1] * Y;
	YNEW = Y + EPS * (A[2] * X + A[3] * X * X * X + A[4] * X * X * Y + A[5] * X * Y * Y + A[6] * Y + A[7] * Y * Y * Y + A[8] * sin(Z));
	ZNEW = Z + EPS * (A[9] + 1.3);
	if (ZNEW > TWOPI) ZNEW = ZNEW - TWOPI;
}
}

fun6700() #  Project onto a horizontal cylinder */
{
PH = PT * (YMAX - YP);
YP = YA + .5 * (YH - YL) * cos(PH);
}

fun6800() #  Project onto a vertical cylinder */
{
TH = TT * (XMAX - XP);
XP = XA + .5 * (XH - XL) * cos(TH);
}

fun6900() #  Project onto a torus (unity aspect ratio) */
{
TH = TT * (XMAX - XP);
PH = 2 * PT * (YMAX - YP);
XP = XA + .18 * (XH - XL) * (1 + cos(TH)) * sin(PH);
YP = YA + .25 * (YH - YL) * (1 + cos(TH)) * cos(PH);
}

fun7000() #  Save data */
{
if ((int)N == 1001) {
	fclose(F3);
	F3 = fopen(FAV, "w");
}
if (SAV == 1) DUM = XNEW;
if (SAV == 2) DUM = YNEW;
if (SAV == 3) DUM = ZNEW;
if (SAV == 4) DUM = WNEW;
fprintf(F3, "%f\n", DUM);
}


main()
