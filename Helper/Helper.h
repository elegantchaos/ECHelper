//
//  Helper.h
//  ECHelper
//
//  Created by Sam Deane on 15/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject<NSConnectionDelegate>

- (void)doCommand:(NSString*)command;

@end
