#import <UIKit/UIKit.h>
#import "VelaCompatibility/VLPrivate.h"

@interface VLEditor : NSObject
+ (instancetype)shared;
- (void)updateForList:(SBIconListView *)list;
- (void)cancel;
- (void)suspend;
@end
