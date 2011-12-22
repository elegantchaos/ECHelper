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

#import "ECUnixPorts.h"
#import "HostAppController.h"
#import "Helper.h"


@interface HostAppController()

#pragma mark - Private Properties

@property (nonatomic, retain) NSConnection* connection;
@property (nonatomic, retain) NSString* helperID;
@property (nonatomic, retain) NSString* message;

#pragma mark - Private Methods

- (Helper*)helper;
- (OSStatus)setupAuthorization:(AuthorizationRef*)authRef;
- (NSError*)installHelperApplication;
- (void)updateUI;

@end

#pragma mark -

@implementation HostAppController

#pragma mark - Properties

@synthesize connection;
@synthesize helperID;
@synthesize label;
@synthesize message;

#pragma mark - Object Lifecycle

// --------------------------------------------------------------------------
//! Cleanup.
// --------------------------------------------------------------------------

- (void)dealloc 
{
    [connection release];
    [helperID release];
    [message release];
    
    [super dealloc];
}

#pragma mark - NSApplicationDelegate

// --------------------------------------------------------------------------
//! Finish setting up after launch.
// --------------------------------------------------------------------------

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // look up the helper bundle id in our plist
    // (we're assuming that it's the one and only key inside the SMPrivilegedExecutables dictionary)
    NSDictionary* helpers = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SMPrivilegedExecutables"];
    self.helperID = [[helpers allKeys] objectAtIndex:0];

    // try to install ("bless") the helper tool
    // this will copy it into the right place and set up the launchd plist (if it isn't already there)
    self.message = @"";
    Helper* helper = [self helper];
    if (!helper)
    {
        NSError* error = [self installHelperApplication];
        if (!error)
        {
            // it worked - try to communicate with it
            self.message = @"Installed Helper";
        }
        else
        {
            // it didn't work
            self.message = @"Helper could not be installed";
            NSLog(@"install failed with error:%@", error);
            [[NSApplication sharedApplication] presentError:error];
        } 
    }
    
    [self updateUI];
}

// --------------------------------------------------------------------------
//! Refresh the UI.
// --------------------------------------------------------------------------

- (void)updateUI
{
    Helper* helper = [self helper];
    NSString* status;
    if (helper)
    {
        // we got a connection to it
        status = [NSString stringWithFormat:@"Helper is running with process id %d using %@ ports", helper.pid, HELPER_METHOD];
    }
    else
    {
        // failed to get a connection, that might just be because it's not started
        status = @"Helper is not running";
    }
    
    NSString* text = [NSString stringWithFormat:@"%@\n\n%@", status, self.message];
    [self.label setStringValue:text];
    
    [self performSelector:@selector(updateUI) withObject:nil afterDelay:1.0];
}

// --------------------------------------------------------------------------
//! Cleanup before shutdown.
// --------------------------------------------------------------------------

- (void)applicationWillTerminate:(NSNotification *)notification
{
    self.connection = nil;
}

#pragma mark - Installation

// --------------------------------------------------------------------------
//! Prepare to authorize.
// --------------------------------------------------------------------------

- (OSStatus)setupAuthorization:(AuthorizationRef*)authRef
{
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
	AuthorizationFlags flags		=	kAuthorizationFlagDefaults				| 
    kAuthorizationFlagInteractionAllowed	|
    kAuthorizationFlagPreAuthorize			|
    kAuthorizationFlagExtendRights;
    
	
	// Obtain the right to install privileged helper tools (kSMRightBlessPrivilegedHelper).
	OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, authRef);
	if (status != errAuthorizationSuccess) 
    {
        *authRef = nil;
	}
    
    return status;
}

// --------------------------------------------------------------------------
//! Attempt to install the helper.
// --------------------------------------------------------------------------

- (NSError*)installHelperApplication
{

	// Obtain the right to install privileged helper tools (kSMRightBlessPrivilegedHelper).
    NSError* error = nil;
	AuthorizationRef authRef;
    OSStatus status = [self setupAuthorization:&authRef];
	if (status == errAuthorizationSuccess) 
    {
		/* This does all the work of verifying the helper tool against the application
		 * and vice-versa. Once verification has passed, the embedded launchd.plist
		 * is extracted and placed in /Library/LaunchDaemons and then loaded. The
		 * executable is placed in /Library/PrivilegedHelperTools.
		 */
		SMJobBless(kSMDomainSystemLaunchd, (CFStringRef) self.helperID, authRef, (CFErrorRef*) error);
    }
    else
    {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:[NSDictionary dictionaryWithObject:@"failed to get authorisation" forKey:NSLocalizedFailureReasonErrorKey]];
	} 
	
	return error;
}

#pragma mark - Helper

// --------------------------------------------------------------------------
//! Return a proxy to the helper object in the helper tool.
//! Sets up the connection when it's first called.
//! Returns nil if it can't connect for any reason
//! (eg the helper isn't installed or isn't running)
// --------------------------------------------------------------------------

- (Helper*)helper
{
    Helper* helper = nil;
    
    if (!self.connection)
    {
        self.connection = [Helper startClientConnection:self.helperID];
        if (!self.connection)
        {
            NSLog(@"Helper not running on %@ port %@", HELPER_METHOD, self.helperID);
        }
        else
        {
            NSLog(@"Helper connected on %@ port %@", HELPER_METHOD, self.helperID);
        }
    }

    if (self.connection)
    {
        NSDistantObject *proxy = nil;
        @try {
            proxy = [self.connection rootProxy];
        }
        @catch (NSException *exception) {
        }

        if (!proxy) 
        {
            NSLog(@"could not get proxy");
            self.connection = nil;
        }
        
        helper = (Helper*)proxy;
    }

    return helper;
}

// --------------------------------------------------------------------------
//! Send a "command" to the helper.
//! In this example a command is just a string that we send
//! by invoking the doCommand method on the helper.
// --------------------------------------------------------------------------

- (IBAction)sendToHelper:(id)sender
{

    Helper* helper = [self helper];
    self.message = 
    [NSString stringWithFormat:
     @"description: %@\nuid = %d, euid = %d, pid = %d\nresult:'%@'",
     [helper description], 
     helper.uid, helper.euid, helper.pid,
     [helper doCommand:@"test command"]
     ];
    NSLog(@"%@", self.message);
}

@end
