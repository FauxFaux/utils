/*
 * - Main header file
 *
 * History:
 *
 *
 * (C)opyleft 1998 �yvind A. Solheim <sunny@sunbase.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef _STD_H
#define _STD_H

/*
 * Defines
 */

#define VERSION       "0.00"
#define RELEASE_DATE  "1998-00-00"
#define AUTHOR        "Oyvind A. Solheim <sunny@sunbase.com>"

#define FALSE  0
#define TRUE   1

#define EXIT_OK     0
#define EXIT_ERROR  1

#define ENGLISH    1

#ifndef C_LANG
#  define C_LANG  ENGLISH
#endif

#if C_LANG == ENGLISH
#  define MSG_LANGUAGE  "English"
#else
#  error C_LANG is not correctly defined
#endif

#ifdef C_ASSERT
#  ifdef NDEBUG
#    undef NDEBUG
#  endif            /* ifdef NDEBUG        */
#else               /* ifdef C_ASSERT      */
#  define NDEBUG  1
#endif              /* ifdef C_ASSERT else */

#ifdef C_SKIP_PGPKEY /* If C_SKIP_PGPKEY is defined, the --pgpkey option is disabled. */
#  ifdef C_PGPKEY
#    undef C_PGPKEY
#  endif
#else
#  define C_PGPKEY  1
#endif

#ifdef C_SKIP_LICENSE /* If C_SKIP_LICENSE, the --license option is disabled. */
#  ifdef C_LICENSE
#    undef C_LICENSE
#  endif
#else
#  define C_LICENSE  1
#endif

/*
 * Macros
 */

#define in_range(a,b,c)  ((a) >= (b) && (a) <= (c) ? TRUE : FALSE)
#define myerror(a)       { fprintf(stderr, "%s: ", progname); perror(a); }

#define debpr0(a)              if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a)); }
#define debpr1(a,b)            if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b)); }
#define debpr2(a,b,c)          if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c)); }
#define debpr3(a,b,c,d)        if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c),(d)); }
#define debpr4(a,b,c,d,e)      if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c),(d),(e)); }
#define debpr5(a,b,c,d,e,f)    if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c),(d),(e),(f)); }
#define debpr6(a,b,c,d,e,f,g)  if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c),(d),(e),(f),(g)); }

/*
 * Typedefs
 */

/*
 * Function prototypes
 */

extern void  print_version(void);
extern char  *date2iso(const char *);
extern void  usage(int);

/*
 * Global variables
 */

extern char  *progname;
extern int   debug;
extern FILE  *stddebug;

#endif /* ifndef _STD_H */

/***** End of file *****/
