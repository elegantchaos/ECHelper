//
//  ECMachPorts.m
//  ECHelper
//
//  Created by Sam Deane on 21/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
