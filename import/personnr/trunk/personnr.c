
/*
 * Skriver ut alle gyldige norske personnummer p� en gitt dato
 * $Id: personnr.c,v 1.2 1999/04/25 03:33:43 sunny Exp $
 *
 * Bare for � ha sagt det: Jeg tar ikke ansvar for hva folk m�tte finne p�
 * med dette programmet, lagde det bare p� g�y.
 *
 * Oppbygningen av personnummeret 020656-45850:
 *
 * 020656 = F�dselsdato (ddmm��)
 *    458 = F�dselsnummer.
 *          Den f�rste registrerte gutten den dagen fikk f�dselsnummeret 499.
 *          Den neste fikk 497. Den f�rste registrerte jenta fikk 498, den
 *          neste 496 osv.
 *          Oddetall = hankj�nn, like tall = hunkj�nn.
 *          For personer f�dt i forrige eller neste �rhundre (18XX/20XX)
 *          brukes tall fra 999/998 ned til 500/501.
 *     50 = Kontrollsiffer som er regnet ut etter en spesiell formel. Enhver
 *          som kjenner denne formelen har mulighet for � kontrollere om det
 *          personnummeret som oppgis er beregnet p� den riktige m�ten. Det
 *          vil bare v�re de registere som har tilgang til folkeregisteret
 *          som vil kunne sjekke om personnummeret er det som er det riktige.
 *
 * Formel for � regne ut kontrollsiffer:
 *
 * Utgangspunktet er to faste rekker med multiplikatorer. Den f�rste rekken
 * blir brukt til � regne ut f�rste kontrollsiffer, og den andre rekken til
 * det andre kontrollsifferet.
 *
 * ---------------------------
 * | f�dselsdato f.num ktr   |
 * | -----------|-----|---   |
 * | a b c d e f g h i j k   |
 * | 3 7 6 1 8 9 4 5 2 - - x |
 * | 5 4 3 2 7 6 5 4 3 2 - y |
 * ---------------------------
 *
 * x = a*3 + b*7 + c*6 + d*1 + e*8 + f*9 + g*4 + h*5 +i*2
 * j = 11 [1 - frac(x/11)]
 * y = a*5 + b*4 + c*3 + d*2 + e*7 + f*6 + g*5 + h*4 + i*3 + j*2
 * k = 11 [1 - frac(y/11)]
 *
 * j og k avrundes etter vanlige avrundingsregler.
 * Dersom j eller k <= 9 er j eller k riktige kontrollsiffer.
 * Dersom j eller k = 10 er personnummeret ugyldig.
 * Dersom j eller k = 11 er j eller k = 0.
 * Det betyr at det for en f�dselsdato ikke finnes mer enn noe over 200
 * mulige personnummer for hvert kj�nn.
 *
 * "Frac" er desimaltallene ved resultatet av divisjonen med 11 som skal
 * trekkes fra 1. Eksempel: frac(126/11) = frac(11.45) = 0.45.
 * Det er ikke n�dvendig � bruke mer enn to desimaler ved denne utregningen.
 *
 * (C)opyleft by sunny
 * License: GNU GPL
 */

#define VERSION "1.10"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define c2i(c)  ((c) - '0')  /* (char)tall --> (int)tall */
#define frac(a) (((int)((a) * 100) % 100) / (float)100)  /* Returnerer 2 desimaler */

#define EXIT_OK    0
#define EXIT_ERROR 1

static char rcs_id[] = "$Id: personnr.c,v 1.2 1999/04/25 03:33:43 sunny Exp $";

char *persnr(char *);

int main(int argc, char *argv[])
{
	register int i; /* Tellevariabel */
	int retval = EXIT_OK,
		startnum = 499; /* Avhengig av next_century */
	char *progname = argv[0],
		buf[12], birthdate[20], tmpbuf[12], century[3], iso_date[12];
	char next_century = 0; /* 0 = 499 og nedover, 1 = 999 og nedover */

	if (argc != 2 || (!strcmp(argv[1], "--help") || !strcmp(argv[1], "?") || !strcmp(argv[1], "-?"))) {
		int charnum; /* Cosmetic thing... */

		putchar('\n');
		charnum = printf("%s ver. %s - (C)opyleft by sunny", progname, VERSION);
		putchar('\n');

		for (; charnum; charnum--)
			putchar('-');
		printf("\nBruk: %s f�dselsdato\n\n", progname);
		printf("Skriver ut alle gyldige norske personnummer for en gitt dato.\n");
		printf("F�dselsdatoen spesifiseres p� formatet ddmm��. Hvis et annet �rhundre enn\n");
		printf("1900 skal brukes, brukes formatet ddmm����.\n\n");
		if (argc != 2)
			retval = EXIT_ERROR;
		goto endfunc;
	}

	fprintf(stderr, "\n--- Program for generering av norske personnummer ---\n\n");

	sprintf(birthdate, "%.15s", argv[1]);

	if ((strlen(birthdate) != 6) && (strlen(birthdate) != 8)) { /* Sjekk at lengden p� datoen er seks eller �tte tegn */
		fprintf(stderr, "%s: Feil format p� datoen. Formatet skal v�re ddmm�� eller ddmm����.", progname);
		retval = EXIT_ERROR;
		goto endfunc;
	}

	strcpy(century, "19"); /* Default �rhundre er 1900 */

	/*
	 * Her kommer det en sjekk som finner ut om det er spesifisert et
	 * annet �rhundre, f.eks. 17081889, dvs. to ekstra siffer i �ret.
	 */

	if (strlen(birthdate) == 8) {
		strncpy(century, birthdate + 4, 2); /* Nytt �rhundre p� gang */
		next_century = (atoi(century) % 2) ? 0 : 1;

		strcpy(tmpbuf, birthdate);
		sprintf(birthdate, "%c%c%c%c%c%c",
		birthdate[0],
		birthdate[1],
		birthdate[2],
		birthdate[3],
		birthdate[6],
		birthdate[7]);
	}

	startnum = next_century ? 999 : 499; /* Hvilket �rhundre skal brukes? */

	snprintf(iso_date, 11, "%2.2s%c%c-%c%c-%c%c",
		century,
		birthdate[4],
		birthdate[5],
		birthdate[2],
		birthdate[3],
		birthdate[0],
		birthdate[1]);

	fprintf(stdout, "Liste over alle gyldige norske personnummer for %s:\n\n", iso_date);
	fprintf(stdout, "Gutter:\n\n");
	for (i = startnum; i >= (startnum-499); i -= 2) {
		sprintf(buf, "%s%3.3d\n", birthdate, i);
		strcpy(tmpbuf, persnr(buf));
		if (!strlen(tmpbuf))
			continue;
		fprintf(stdout, "%6.6s-%5.5s\n", tmpbuf, tmpbuf + 6);
	}

	fprintf(stdout, "\nJenter:\n\n");
	for (i = (startnum-1); i >= (startnum-499); i -= 2) {
		sprintf(buf, "%s%3.3d\n", birthdate, i);
		strcpy(tmpbuf, persnr(buf));
		if (!strlen(tmpbuf))
			continue;
		fprintf(stdout, "%6.6s-%5.5s\n", tmpbuf, tmpbuf + 6);
	}

	fprintf(stdout, "\n--- Utlisting slutt ---\n");

endfunc:
;
	return(retval);
} /* main() */

char *persnr(char *orgbuf)
{
	int x, y;
	float j, k;
	static char buf[12];

	strcpy(buf, orgbuf);

	x = c2i(buf[0])*3 + c2i(buf[1])*7 + c2i(buf[2])*6 + c2i(buf[3])*1 + \
	c2i(buf[4])*8 + c2i(buf[5])*9 + c2i(buf[6])*4 + c2i(buf[7])*5 + c2i(buf[8])*2;

	j = 11 * (1 - frac((float)x / 11));
	if (frac(j) >= 0.5)
		j++;
	j = (int)j;

	y = c2i(buf[0])*5 + c2i(buf[1])*4 + c2i(buf[2])*3 + c2i(buf[3])*2 + \
	c2i(buf[4])*7 + c2i(buf[5])*6 + c2i(buf[6])*5 + c2i(buf[7])*4 + \
	c2i(buf[8])*3 + j*2;

	k = 11 * (1 - frac((float)y / 11));
	if (frac(k) >= 0.5)
		k++;
	k = (int)k;

	if (j == 10 || k == 10) { /* Hvis j eller k == 10 er nummeret falskt */
		strcpy(buf, ""); /* Returnerer tom streng hvis ulovlig */
		goto endfunc;
	}

	if (j == 11)
		j = 0;
	if (k == 11)
		k = 0;

	buf[9] = j + '0';
	buf[10] = k + '0';
	buf[11] = '\0';

endfunc:
;
	return(buf);
} /* persnr() */

/**** End of file $Id: personnr.c,v 1.2 1999/04/25 03:33:43 sunny Exp $ ****/
