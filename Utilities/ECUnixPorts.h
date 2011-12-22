// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface NSSocketPort(ECUnixPorts)

+ (NSSocketPort*)clientSocketWithName:(NSString*)name;
+ (NSSocketPort*)serviceSocketWithName:(NSString*)name;

@end

@class ECASLClient;

@interface NSConnection(ECUnixPorts)

+ (id)serviceConnectionWithUnixSocketName:(NSString*)name rootObject:(id)root;
+ (id)serviceConnectionWithBootstrapUnixSocketName:(NSString*)name rootObject:(id)root;
+ (id)connectionWithUnixSocketName:(NSString*)name;

+ (void)removeUnixSocketName:(NSString*)name;
- (void)invalidateWithUnixSocketName:(NSString*)name;
@end