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

@interface Helper()
@property (nonatomic, retain) ECASLClient* asl;
@end

@implementation Helper

@synthesize asl;
@synthesize euid;
@synthesize pid;
@synthesize uid;

- (id)initWithASL:(ECASLClient*)aslIn
{
    if ((self = [super init]) != nil)
    {
        self.uid = getuid();
        self.euid = geteuid();
        self.pid = getpid();
        self.asl = aslIn;
    }
    
    return self;
}

- (void)dealloc 
{
    [asl release];
    
    [super dealloc];
}

- (NSString*)doCommand:(NSString*)command
{
	[self.asl log:@"received command: %@", command];
    
    NSString* result = [NSString stringWithFormat:@"did command: %@", command];
    
    return result;
}

@end

