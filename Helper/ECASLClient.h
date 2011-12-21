// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface ECASLClient : NSObject

- (id)initWithName:(NSString*)name;

- (void)logAtLevel:(int)level withFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(2,3);
- (void)log:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)error:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);

@end
