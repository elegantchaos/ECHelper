//
//  ECUnixPort.m
//  ECHelper
//
//  Created by Sam Deane on 21/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
