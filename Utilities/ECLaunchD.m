// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 15/12/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLaunchD.h"
#import "ECASLClient.h"

#import <launch.h>
#import <servers/bootstrap.h>

// TODO - add proper ECLogging
//#define ECDebug(c, ...) [[ECASLClient sharedInstance] log:__VA_ARGS__]
#define ECDebug(...)

@implementation ECLaunchD

+ (mach_port_t)bootstrapPortWithName:(NSString *)name
{
    mach_port_t mp = 0;
    mach_port_t bootstrap_port;
    task_get_bootstrap_port(mach_task_self(), &bootstrap_port);
    kern_return_t result = bootstrap_check_in(bootstrap_port, [name UTF8String], &mp);
    if (result != err_none)
    {
        ECDebug(LaunchdChannel, @"failed to get bootstrap port with error %d", result);
    }
    
    return mp;
}

// --------------------------------------------------------------------------
//! Return the bootstrap socket we were passed
// --------------------------------------------------------------------------

+ (int)boostrapSocketWithName:(NSString *)name
{
    ECDebug(LaunchdChannel, @"in bootstrap");
    
    int socket = 0;
    
    launch_data_t checkin_request = launch_data_new_string(LAUNCH_KEY_CHECKIN);
    if (checkin_request) 
    {
        ECDebug(LaunchdChannel, @"got request");
        launch_data_t checkin_response = launch_msg(checkin_request);
        if (checkin_response) 
        {
            launch_data_type_t type = launch_data_get_type(checkin_response);
            ECDebug(LaunchdChannel, @"got response type %d", type);
            if (type != LAUNCH_DATA_ERRNO) 
            {
                ECDebug(LaunchdChannel, @"not error");
                launch_data_t the_label = launch_data_dict_lookup(checkin_response, LAUNCH_JOBKEY_LABEL);
                if (the_label) 
                {
                    const char* label = launch_data_get_string(the_label);
                    if (!name || (strcmp(label, [name UTF8String]) == 0))
                    {
                        ECDebug(LaunchdChannel, @"got matching label %s", label);
                        
                        launch_data_t sockets_dict = launch_data_dict_lookup(checkin_response, LAUNCH_JOBKEY_SOCKETS);
                        if (sockets_dict) 
                        {
                            size_t count = launch_data_dict_get_count(sockets_dict);
                            ECDebug(LaunchdChannel, @"got dict with count %d", count);
                            if (count > 0) 
                            {
                                launch_data_t listening_fd_array = launch_data_dict_lookup(sockets_dict, label);
                                if (listening_fd_array)
                                {
                                    ECDebug(LaunchdChannel, @"got sockets array");
                                    launch_data_t fd_data = launch_data_array_get_index(listening_fd_array, 0);
                                    socket = launch_data_get_fd(fd_data);
                                }
                            }
                        }
                    }
                }
            }
        }
        launch_data_free(checkin_request);
	}

    // TODO are we supposed to free more stuff?

    return socket;
}

@end
