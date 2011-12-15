//
//  Helper.m
//  ECHelper
//
//  Created by Sam Deane on 15/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Helper.h"
#include <syslog.h>

@implementation Helper

- (void)doCommand:(NSString*)command
{
	syslog(LOG_NOTICE, "doing command: %s", [command UTF8String]);
}

@end

