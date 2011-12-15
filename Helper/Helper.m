// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "Helper.h"
#include <syslog.h>

@implementation Helper

@synthesize euid;
@synthesize pid;
@synthesize uid;

- (id)init
{
    if ((self = [super init]) != nil)
    {
        self.uid = getuid();
        self.euid = geteuid();
        self.pid = getpid();
    }
    
    return self;
}

- (NSString*)doCommand:(NSString*)command
{
	syslog(LOG_NOTICE, "received command: %s", [command UTF8String]);
    
    NSString* result = [NSString stringWithFormat:@"did command: %@", command];
    
    return result;
}

@end

