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

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // use our bundle id as our service name
        NSString* name = [[NSBundle mainBundle] bundleIdentifier];
        ECASLClient* asl = [[ECASLClient alloc] initWithName:name];
        
        // make a helper object - this is what we'll publish with the connection
        Helper* helper = [[Helper alloc] initWithASL:asl];

        // set up the connection
        NSConnection* server = [NSConnection serviceConnectionUsingBootstrapPortWithName:name rootObject:helper];
        [asl log:@"helper server: %@", server];
        
        // run
        [[NSRunLoop currentRunLoop] run];

        // cleanup
        [asl log:@"helper finishing"];
        [helper release];
        [asl release];
    }
    
    return 0;
}
