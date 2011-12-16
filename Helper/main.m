// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#include <syslog.h>
#include <unistd.h>
#include <stdio.h>
#include <launch.h>
#include <servers/bootstrap.h>
#include <mach/mach_init.h>

#import "Helper.h"

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // use our bundle id as our service name
        NSString* name = [[NSBundle mainBundle] bundleIdentifier];
        const char* name_c = [name UTF8String];
        
        // get the mach port to use from launchd
        mach_port_t mp;
        mach_port_t bootstrap_port;
        task_get_bootstrap_port(mach_task_self(), &bootstrap_port);
        kern_return_t result = bootstrap_check_in(bootstrap_port, name_c, &mp);
        if (result != err_none)
        {
            syslog(LOG_NOTICE, "Unable to get bootstrap port");
            exit(1);
        }

        // set up the connection
        NSMachPort *receivePort = [[NSMachPort alloc] initWithMachPort:mp];
        NSConnection*server = [NSConnection connectionWithReceivePort:receivePort sendPort:nil];
        [receivePort release];

        // make a helper object - this is what we'll publish with the connection
        Helper* helper = [[Helper alloc] init];
        [server setRootObject:helper];
        syslog(LOG_NOTICE, "helper registered as %s: uid = %d, euid = %d, pid = %d\n", name_c, helper.uid, helper.euid, helper.pid);

        // run
        [[NSRunLoop currentRunLoop] run];

        syslog(LOG_NOTICE, "helper finishing");
        [server release];
        [helper release];
    }
    
    return 0;
}
