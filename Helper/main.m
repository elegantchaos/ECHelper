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

#import "Helper.h"

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString* name = [[NSBundle mainBundle] bundleIdentifier];

        launch_data_t checkinRequest = launch_data_new_string(LAUNCH_KEY_CHECKIN);
        launch_data_t checkinResponse = launch_msg(checkinRequest);
        launch_data_t machServicesDict = launch_data_dict_lookup(checkinResponse, LAUNCH_JOBKEY_MACHSERVICES);
        launch_data_t machPort = launch_data_dict_lookup(machServicesDict, [name UTF8String]);
        
        mach_port_t mp = launch_data_get_machport(machPort);
        
        launch_data_free(checkinResponse);
        launch_data_free(checkinRequest);
        
        NSMachPort *receivePort = [[NSMachPort alloc] initWithMachPort:mp];
        NSConnection*server = [NSConnection connectionWithReceivePort:receivePort sendPort:nil];
        [receivePort release];
        
        Helper* helper = [[Helper alloc] init];
        [server setRootObject:helper];

        syslog(LOG_NOTICE, "helper starting! uid = %d, euid = %d, pid = %d\n", helper.uid, helper.euid, helper.pid);

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
