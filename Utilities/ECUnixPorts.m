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

#import <sys/socket.h>
#import <sys/un.h>
#import <launch.h>
#import <servers/bootstrap.h>

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

+ (id)serviceConnectionWithBootstrapUnixSocketWithName:(NSString*)name rootObject:(id)root
{
    ECASLClient* asl = [ECASLClient sharedInstance];
    [asl log:@"in bootstrap"];
    
    int fd = 0;

    launch_data_t checkin_request = launch_data_new_string(LAUNCH_KEY_CHECKIN);
    if (checkin_request) 
    {
        [asl log:@"got request"];
        launch_data_t checkin_response = launch_msg(checkin_request);
        if (checkin_response) 
        {
            launch_data_type_t type = launch_data_get_type(checkin_response);
            [asl log:@"got response type %d", type];
            if (type != LAUNCH_DATA_ERRNO) 
            {
                [asl log:@"not error"];
                launch_data_t the_label = launch_data_dict_lookup(checkin_response, LAUNCH_JOBKEY_LABEL);
                if (the_label) 
                {
                    const char* label = launch_data_get_string(the_label);
                    [asl log:@"got label %s", label];

                    launch_data_t sockets_dict = launch_data_dict_lookup(checkin_response, LAUNCH_JOBKEY_SOCKETS);
                    if (sockets_dict) 
                    {
                        size_t count = launch_data_dict_get_count(sockets_dict);
                        [asl log:@"got dict with count %d", count];
                        if (count > 0) 
                        {
                            launch_data_t listening_fd_array = launch_data_dict_lookup(sockets_dict, label);
                            if (listening_fd_array)
                            {
                                [asl log:@"got sockets array"];
                                launch_data_t fd_data = launch_data_array_get_index(listening_fd_array, 0);
                                fd = launch_data_get_fd(fd_data);
                            }
                        }
                    }
                }
            }
        }
	}
    
    NSConnection* connection = nil;
    if (fd)
    {
        [asl log:@"got fd %d", fd];
        NSSocketPort* receivePort = [[NSSocketPort alloc] initWithProtocolFamily:AF_UNIX socketType:SOCK_STREAM protocol:0 socket:fd];
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