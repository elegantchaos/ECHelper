//
//  ECUnixPort.h
//  ECHelper
//
//  Created by Sam Deane on 21/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSocketPort(ECUnixPorts)

- (id)initWithSocketName:(NSString*)name;

@end
