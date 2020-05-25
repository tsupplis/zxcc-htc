extern int _exit(int);
extern void _cleanup();

int exit(int v)
{
	_cleanup();
	_exit(v);
}
