#import <Foundation/Foundation.h>
#import "VLLayout.h"

@interface VLStore : NSObject
+ (instancetype)shared;
@property(nonatomic, readonly) VLLayout current;
@property(nonatomic, readonly) BOOL editing;
@property(nonatomic, readonly) NSUInteger revision;
- (BOOL)begin;
- (BOOL)preview:(VLLayout)layout;
- (BOOL)done:(NSError **)error;
- (void)cancel;
@end
