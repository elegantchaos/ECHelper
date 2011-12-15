#include <syslog.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, const char * argv[])
{
	syslog(LOG_NOTICE, "Hello world! uid = %d, euid = %d, pid = %d\n", getuid(), geteuid(), getpid());
	
	sleep(10);
	
	return 0;
}

