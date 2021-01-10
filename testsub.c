#include	<stdio.h>
#include    <signal.h>

char ** _getargs(char *,char *);

char buf[256+1];

main(int argc, char ** argv)
{
	short		i;

	if(argc == 1) {
        signal(SIGINT,SIG_IGN);
        fprintf(stderr, "prefix\n");
        signal(SIGINT,SIG_DFL);
		argv = _getargs((char *)0, "test");
        fprintf(stderr,"\n");
        if(argv) {
            for(i=0;argv[i];i++) {
                fprintf(stderr, "%d; (%s)\n",i,argv[i]);
            }
        }
    } else {
        signal(SIGINT,SIG_IGN);
        fprintf(stderr, "prefix\n");
        signal(SIGINT,SIG_DFL);
        if((argv[1][0]=='L')||(argv[1][0]=='l')) {
            char * b;
            b=fgets(buf,256,stdin); 
            b[256]=0;
            fprintf(stderr, "(%s)\n",buf);
        } else {
            for(i=0;argv[i];i++) {
                fprintf(stderr, "%d; (%s)\n",i,argv[i]);
            }
        }
    }
    fprintf(stderr, "stdin %u %u\n",stdin,fileno(stdin));
    fprintf(stderr, "stdout %u %u\n",stdout,fileno(stdout));
    fprintf(stderr, "stderr %u %u\n",stderr,fileno(stderr));
	fprintf(stderr, "exiting ...\n");
    return 0;
}
