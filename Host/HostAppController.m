// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

#import "HostAppController.h"
#import "Helper.h"

@interface HostAppController()

@property (nonatomic, retain) NSConnection* connection;

- (Helper*)helper;

@end

@implementation HostAppController

@synthesize connection;
@synthesize label;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // look up the helper bundle id in our plist
    // (we're assuming that it's the one and only key inside the SMPrivilegedExecutables dictionary)
    NSDictionary* helpers = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SMPrivilegedExecutables"];
    NSString* helperID = [[helpers allKeys] objectAtIndex:0];

    // try to install the helper
	NSError* error = nil;
	if (![self blessHelperWithLabel:helperID error:&error]) 
    {
        // it didn't work
		NSLog(@"Something went wrong!");
        [self.label setStringValue:@"Helper could not be installed"];
        [[NSApplication sharedApplication] presentError:error];
	} 
    else
    {
        // it worked - try to communicate with it
		NSLog(@"Job is available!");
        Helper* helper = [self helper];
        if (helper)
        {
            [self.label setStringValue:[NSString stringWithFormat:@"Helper is running with process id %d", helper.pid]];
        }
        else
        {
            [self.label setStringValue:@"Helper is installed, but not running yet"];
        }
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    self.connection = nil;
}

- (BOOL)blessHelperWithLabel:(NSString *)helperLabel error:(NSError **)error;
{
	BOOL result = NO;

	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
	AuthorizationFlags flags		=	kAuthorizationFlagDefaults				| 
										kAuthorizationFlagInteractionAllowed	|
										kAuthorizationFlagPreAuthorize			|
										kAuthorizationFlagExtendRights;

	AuthorizationRef authRef = NULL;
	
	/* Obtain the right to install privileged helper tools (kSMRightBlessPrivilegedHelper). */
	OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
	if (status != errAuthorizationSuccess) {
		NSLog(@"Failed to create AuthorizationRef, return code %i", status);
	} else {
		/* This does all the work of verifying the helper tool against the application
		 * and vice-versa. Once verification has passed, the embedded launchd.plist
		 * is extracted and placed in /Library/LaunchDaemons and then loaded. The
		 * executable is placed in /Library/PrivilegedHelperTools.
		 */
		result = SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)helperLabel, authRef, (CFErrorRef *)error);
	}
	
	return result;
}

- (Helper*)helper
{
    Helper* helper = nil;
    
    if (!self.connection)
    {
        // Lookup the server connection
        NSString* name = @"com.elegantchaos.helper.helper";
        self.connection = [NSConnection connectionWithRegisteredName:name host:nil];
        if (!self.connection)
        {
            NSLog(@"%@ server: could not find server.  You need to start one on this machine first.\n", name);
        }
    }

    if (self.connection)
    {
        NSDistantObject *proxy = [self.connection rootProxy];
        if (!proxy) 
        {
            NSLog(@"could not get proxy");
        }
        
        helper = (Helper*)proxy;
    }

    return helper;
}

- (IBAction)sendToHelper:(id)sender
{

    Helper* helper = [self helper];
    NSLog(@"description: %@", [helper description]);
    NSLog(@"uid = %d, euid = %d, pid = %d\n", helper.uid, helper.euid, helper.pid);
    
    NSString* result = [helper doCommand:@"test command"];
    NSLog(@"result of command was: %@", result);
}

@end
