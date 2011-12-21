// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECUnixPorts.h"

#import <sys/socket.h>
#import <sys/un.h>

@implementation NSSocketPort(ECUnixPorts)

- (id)initWithSocketName:(NSString *)name
{
    const char* name_c = [name fileSystemRepresentation];
    
    // make sure socket file doesn't exist, or we'll fail
    unlink(name_c);
    
    // create an AF_UNIX socket address
    struct sockaddr_un socketAddress;
    bzero(&socketAddress,sizeof(socketAddress));
    socketAddress.sun_family = AF_UNIX;
    strcpy(socketAddress.sun_path, name_c);
    socketAddress.sun_len = SUN_LEN(&socketAddress);
    NSData* socketAddressData = [NSData dataWithBytes:&socketAddress length: sizeof(socketAddress)];
    
    return [self initWithProtocolFamily: AF_UNIX socketType: SOCK_STREAM protocol: 0 address: socketAddressData];
}

@end
