// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECUnixPorts.h"
#import "ECASLClient.h"
#import "ECLaunchD.h"

#import <sys/socket.h>
#import <sys/un.h>

@implementation NSSocketPort(ECUnixPorts)

+ (NSString*)pathForUnixSocketName:(NSString*)name
{
    NSString* path = [NSString stringWithFormat:@"/var/tmp/%@", name];
    return path;
}

+ (NSData*)socketDataWithName:(NSString*)name
{
    struct sockaddr_un socketAddress;
    bzero(&socketAddress,sizeof(socketAddress));
    socketAddress.sun_family = AF_UNIX;
    strcpy(socketAddress.sun_path,"/var/tmp/");
    strcat(socketAddress.sun_path,[name cStringUsingEncoding:NSASCIIStringEncoding]);
    socketAddress.sun_len = SUN_LEN(&socketAddress);
    NSData* result = [NSData dataWithBytes:&socketAddress length:sizeof(socketAddress)];
    
    return result;
}

+ (NSSocketPort*)clientSocketWithName:(NSString*)name
{
    NSString* path = [self pathForUnixSocketName:name];
    NSSocketPort* result = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData* data = [self socketDataWithName:name];
        result = [[NSSocketPort alloc] initRemoteWithProtocolFamily:AF_UNIX socketType:SOCK_STREAM protocol:0 address:data];
    }

    return [result autorelease];
}

+ (NSSocketPort*)serviceSocketWithName:(NSString*)name
{
    NSData* data = [self socketDataWithName:name];
	NSSocketPort* result = [[NSSocketPort alloc] initWithProtocolFamily:AF_UNIX socketType:SOCK_STREAM protocol:0 address:data];

    return [result autorelease];
}

@end

@implementation NSConnection(ECUnixPorts)

+ (id)serviceConnectionWithBootstrapUnixSocketName:(NSString *)name rootObject:(id)root
{
    int socket = [ECLaunchD boostrapSocketWithName:name];
    NSConnection* connection = nil;
    if (socket)
    {
        NSSocketPort* receivePort = [[NSSocketPort alloc] initWithProtocolFamily:AF_UNIX socketType:SOCK_STREAM protocol:0 socket:socket];
        connection = [NSConnection connectionWithReceivePort:receivePort sendPort:nil];
        [connection setRootObject:root];
    }
    
    return connection;
}

+ (id)serviceConnectionWithUnixSocketName:(NSString*)name rootObject:(id)root
{
    [self removeUnixSocketName:name];
    
    NSSocketPort* receivePort = [NSSocketPort serviceSocketWithName:name];
    NSConnection* connection = [NSConnection connectionWithReceivePort:receivePort sendPort:nil];
    [connection setRootObject:root];
    
    NSString* path = [NSSocketPort pathForUnixSocketName:name];
    NSError* error = nil;
    NSDictionary* attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithShort:0777] forKey:NSFilePosixPermissions];
    [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:path error:&error];

    return connection;
}

+ (id)connectionWithUnixSocketName:(NSString *)name
{
    NSSocketPort* sendPort = [NSSocketPort clientSocketWithName:name];
    NSConnection* connection = [NSConnection connectionWithReceivePort:nil sendPort:sendPort];
    
    return connection;
}


+ (void)removeUnixSocketName:(NSString*)name
{
    NSString* path = [NSSocketPort pathForUnixSocketName:name];
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

- (void)invalidateWithUnixSocketName:(NSString*)name
{
    [NSConnection removeUnixSocketName:name];
    [self invalidate];
}

@end