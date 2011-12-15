#include <syslog.h>
#include <unistd.h>
#include <stdio.h>

#import "Helper.h"

#import <Foundation/Foundation.h>

//#define SIMPLE
#ifdef SIMPLE

int main(int argc, const char * argv[])
{
	syslog(LOG_NOTICE, "Hello world! uid = %d, euid = %d, pid = %d\n", getuid(), geteuid(), getpid());
	
	sleep(10);
	
	return 0;
}

#else

int main(int argc, const char * argv[])
{
	syslog(LOG_NOTICE, "helper starting! uid = %d, euid = %d, pid = %d\n", getuid(), geteuid(), getpid());
    @autoreleasepool
    {
        NSConnection* server = [[NSConnection alloc] init];
        Helper* helper = [[Helper alloc] init];
        [server setRootObject:helper];
        
        NSString* name = [[NSBundle mainBundle] bundleIdentifier];
        if ([server registerName:name] == NO)
        {
            syslog(LOG_NOTICE, "Unable to register as '%s'. Perhaps another copy of this program is running?", [name UTF8String]);
            exit(1);
        }
        
        syslog(LOG_NOTICE, "registered as %s", [name UTF8String]);
        [[NSRunLoop currentRunLoop] run];

        syslog(LOG_NOTICE, "helper finishing");
        [server release];
        [helper release];
    }
    
    return 0;
}

#endif