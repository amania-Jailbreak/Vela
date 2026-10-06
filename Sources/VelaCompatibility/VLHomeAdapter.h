#import "VLPrivate.h"
#import "VelaCore/VLLayout.h"

@interface VLHomeAdapter : NSObject
+ (instancetype)shared;
- (BOOL)isHomeList:(SBIconListView *)list;
- (void)registerList:(SBIconListView *)list;
- (BOOL)validate:(VLLayout)layout reason:(NSString **)reason;
- (void)refresh;
- (id)layoutForList:(SBIconListView *)list original:(id)original;
- (BOOL)customizes:(SBIconListView *)list;
@end
