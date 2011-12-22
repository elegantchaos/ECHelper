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

@interface Helper()
@property (nonatomic, retain) ECASLClient* asl;
@end

@implementation Helper

@synthesize asl;
@synthesize euid;
@synthesize pid;
@synthesize timeToQuit;
@synthesize uid;

+ (BOOL)useMachPorts
{
    static BOOL inited = NO;
    static BOOL useMach = NO;
    if (!inited)
    {
        inited = YES;
        useMach = [HELPER_METHOD isEqualToString:@"Mach"]; // HELPER_METHOD is defined in Settings.xcconfig
    }

    return useMach;
}

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

+ (NSConnection*)startClientConnection:(NSString*)name
{
    NSConnection* result;
    if ([Helper useMachPorts])
    {
        result = [NSConnection connectionWithRegisteredName:name host:nil];
    }
    else
    {
        result = [NSConnection connectionWithUnixSocketName:name];
    }
    
    return result;
}

- (void)stopClientConnection:(NSConnection*)connection
{
    [connection invalidate];
}

- (NSConnection*)startServerConnection:(NSString*)name
{
    // set up the connection
    NSConnection* result;
    if ([Helper useMachPorts])
    {
        result = [NSConnection serviceConnectionWithBootstrapPortWithName:name rootObject:self];
    }
    else
    {
        result = [NSConnection serviceConnectionWithUnixSocketName:name rootObject:self];
    }
    
    return result;
}

- (void)stopServerConnection:(NSConnection*)connection name:(NSString*)name
{
    if ([Helper useMachPorts])
    {
        [connection invalidate];
    }
    else
    {
        [connection invalidateWithUnixSocketName:name];
    }
}

@end

