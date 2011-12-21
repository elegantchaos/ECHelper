// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECMachPorts.h"

#import <launch.h>
#import <servers/bootstrap.h>

@implementation NSConnection(ECMachPorts)

+ (id)serviceConnectionUsingBootstrapPortWithName:(NSString*)name rootObject:(id)root
{
    NSConnection* service = nil;
    mach_port_t mp;
    mach_port_t bootstrap_port;
    task_get_bootstrap_port(mach_task_self(), &bootstrap_port);
    kern_return_t result = bootstrap_check_in(bootstrap_port, [name UTF8String], &mp);
    if (result == err_none)
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
