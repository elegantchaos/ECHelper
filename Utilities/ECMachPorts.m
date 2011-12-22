// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECMachPorts.h"
#import "ECLaunchD.h"

@implementation NSConnection(ECMachPorts)

+ (id)serviceConnectionWithBootstrapPortName:(NSString*)name rootObject:(id)root
{
    NSConnection* service = nil;
    mach_port_t mp = [ECLaunchD bootstrapPortWithName:name];
    if (mp)
    {
        // set up the connection
        NSMachPort *receivePort = [[NSMachPort alloc] initWithMachPort:mp];
        service = [NSConnection connectionWithReceivePort:receivePort sendPort:nil];
        [service setRootObject:root];
        [receivePort release];
    }
    
    return service;
}

@end
