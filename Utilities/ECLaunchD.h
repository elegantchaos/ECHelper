// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface ECLaunchD : NSObject

+ (mach_port_t)bootstrapPortWithName:(NSString*)name;
+ (int)boostrapSocketWithName:(NSString*)name;

@end
