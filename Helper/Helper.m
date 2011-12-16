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
#import <asl.h>

@interface Helper()
@property (nonatomic, assign) aslclient aslClient;
@property (nonatomic, assign) aslmsg aslMsg;
@end

@implementation Helper

@synthesize aslClient;
@synthesize aslMsg;
@synthesize euid;
@synthesize pid;
@synthesize uid;

- (id)initWithName:(NSString *)name mode:(HelperMode)mode
{
    if ((self = [super init]) != nil)
    {
        self.uid = getuid();
        self.euid = geteuid();
        self.pid = getpid();

        const char* name_c = [name UTF8String];
        self.aslClient = asl_open(name_c, "Daemon", ASL_OPT_STDERR);
        self.aslMsg = asl_new(ASL_TYPE_MSG);
        asl_set(self.aslMsg, ASL_KEY_SENDER, name_c);
        if (mode == HelperServer)
        {
            asl_log(self.aslClient, aslMsg, ASL_LEVEL_NOTICE, "helper server %s created: uid = %d, euid = %d, pid = %d\n", name_c, self.uid, self.euid, self.pid);
        }
        else
        {
            asl_log(self.aslClient, self.aslMsg, ASL_LEVEL_NOTICE, "helper client %s created", name_c);
        }
    }
    
    return self;
}

- (void)log:(NSString *)msg
{
    asl_log(self.aslClient, self.aslMsg, ASL_LEVEL_NOTICE, "%s", [msg UTF8String]);
}

- (void)error:(NSString *)msg
{
    asl_log(self.aslClient, self.aslMsg, ASL_LEVEL_ERR, "%s", [msg UTF8String]);
}

- (NSString*)doCommand:(NSString*)command
{
	asl_log(aslClient, aslMsg, ASL_LEVEL_NOTICE, "received command: %s", [command UTF8String]);
    
    NSString* result = [NSString stringWithFormat:@"did command: %@", command];
    
    return result;
}

@end

