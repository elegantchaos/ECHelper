#import <Cocoa/Cocoa.h>

@interface HostAppController : NSObject 
{
	IBOutlet NSTextField *_textField;
}

- (BOOL)blessHelperWithLabel:(NSString *)label error:(NSError **)error;

@end
