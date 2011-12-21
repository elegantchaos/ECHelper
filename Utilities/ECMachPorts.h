//
//  ECMachPorts.h
//  ECHelper
//
//  Created by Sam Deane on 21/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSConnection(ECMachPorts)

+ (id)serviceConnectionUsingBootstrapPortWithName:(NSString*)name rootObject:(id)root;

@end
