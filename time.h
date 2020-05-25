#ifndef _HTC_TIME_H
#define _HTC_TIME_H

#ifndef	_TIME

typedef	long	time_t;		/* for representing times in seconds */
struct tm {
	int	tm_sec;
	int	tm_min;
	int	tm_hour;
	int	tm_mday;
	int	tm_mon;
	int	tm_year;
	int	tm_wday;
	int	tm_yday;
	int	tm_isdst;
};
#define	_TIME
#endif	

extern int	time_zone;	/* minutes WESTWARD of Greenwich */
				/* this value defaults to 0 since with
				   operating systems like MS-DOS there is
				   no time zone information available */

extern time_t	time(time_t *);	/* seconds since 00:00:00 Jan 1 1970 */
extern char *	asctime(struct tm *);	/* converts struct tm to ascii time */
extern char *	ctime();	/* current local time in ascii form */
extern struct tm *	gmtime();	/* Universal time */
extern struct tm *	localtime();	/* local time */

#endif
