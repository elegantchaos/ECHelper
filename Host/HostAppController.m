
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

#import "HostAppController.h"
#import "Helper.h"

@implementation HostAppController

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // look up the helper bundle id in our plist
    // (we're assuming that it's the one and only key inside the SMPrivilegedExecutables dictionary)
    NSDictionary* helpers = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SMPrivilegedExecutables"];
    NSString* helperID = [[helpers allKeys] objectAtIndex:0];
    
	NSError* error = nil;
	if (![self blessHelperWithLabel:helperID error:&error]) 
    {
		NSLog(@"Something went wrong!");
        [[NSApplication sharedApplication] presentError:error];
	} 
    else
    {
		/* At this point, the job is available. However, this is a very
		 * simple sample, and there is no IPC infrastructure set up to
		 * make it launch-on-demand. You would normally achieve this by
		 * using a Sockets or MachServices dictionary in your launchd.plist.
		 */
		NSLog(@"Job is available!");
		
		[self->_textField setHidden:false];
	}
}

- (BOOL)blessHelperWithLabel:(NSString *)label error:(NSError **)error;
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
		result = SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)label, authRef, (CFErrorRef *)error);
	}
	
	return result;
}

- (IBAction)sendToHelper:(id)sender
{
    // Create an Authenticator object to authenticate messages going
    // to the server.  The client and server need to use the same
    // authentication logic, but would not need to use the same class.
    Helper* helper = [[Helper alloc] init];
    NSDistantObject *proxy;
    
    // Lookup the server connection
    NSString* name = @"com.elegantchaos.helper.helper";
    NSConnection *conn = [NSConnection connectionWithRegisteredName:name host:nil];
    if (!conn) {
        NSLog(@"%@ server: could not find server.  You need to start one on this machine first.\n", name);
        exit(1);
    }
    
    // Set the authenticator as the NSConnection delegate; all 
    // further messages, including the first one to lookup the root 
    // proxy, will go through the authenticator.
    [conn setDelegate:helper];
    
    proxy = [conn rootProxy];
    
    if (!proxy) {
        NSLog(@"%@ server: could not get proxy.  This should not happen.\n", name);
        exit(1);
    }
    
    // Since this is an example, we don't really care what the "served" 
    // object really does, just that we can message it.  Since it is just
    // an NSObject, send it some NSObject messages.  If these aren't
    // authenticated successfully, an NSFailedAuthenticationException
    // exception is raised.
    
    NSLog(@"description: %@", [proxy description]);
    NSLog(@"isKindOfClass NSObject? %@", [proxy isKindOfClass:[NSObject self]] ? @"YES" : @"NO");
    
    NSLog(@"Done. Messages sent successfully.");
    
    [(Helper*)proxy doCommand:@"test command"];
    
}

@end
