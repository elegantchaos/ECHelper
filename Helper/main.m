// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "Helper.h"

#import "ECASLClient.h"
#import "ECMachPorts.h"
#import "ECUnixPorts.h"

#import <Foundation/Foundation.h>

static const NSTimeInterval kHelperCheckInterval = 1.0; // how often to check whether to quit

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // use our bundle id as our service name
        NSString* name = [[NSBundle mainBundle] bundleIdentifier];
        
        // use ASL for logging
        ECASLClient* asl = [[ECASLClient alloc] initWithName:name];
        
        // make a helper object - this is what we'll publish with the connection
        Helper* helper = [[Helper alloc] initWithASL:asl];

        // set up the connection
        NSConnection* server = [helper startServerConnection:name];
        if (server)
        {
            [asl log:@"made helper server using %@ ports", HELPER_METHOD];
        }
        else
        {
            [asl error:@"failed to make helper server"];
        }
        
        // run until it's time to quit
        NSRunLoop* rl = [NSRunLoop currentRunLoop];
        while (!helper.timeToQuit)
        {
            [rl runUntilDate:[NSDate dateWithTimeIntervalSinceNow:kHelperCheckInterval]];
        }

        // cleanup
        [helper stopServerConnection:server name:name];
        [asl log:@"helper finishing"];
        [helper release];
        [asl release];
    }
    
    return 0;
}
