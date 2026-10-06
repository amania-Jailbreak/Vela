#import <UIKit/UIKit.h>

typedef struct { unsigned short columns, rows; } VLGridSize;
typedef struct { NSInteger row, column; } VLCoordinate;

@interface VLRootFolder : NSObject
@property(nonatomic, readonly) NSArray *lists;
@end

/* iOS 17 runtime declarations; every use is gated by selector availability.
 * Keep OS-specific names here and in VLHomeAdapter, never in the editor. */
@interface SBIconListModel : NSObject
@property(nonatomic, readonly) NSArray *icons;
@property(nonatomic, readonly) id folder;
- (VLGridSize)gridSize;
- (void)setGridSize:(VLGridSize)size;
@end
@interface SBIconListView : UIView
@property(nonatomic, readonly) NSString *iconLocation;
@property(nonatomic, readonly) SBIconListModel *model;
@property(nonatomic, readonly) id layout;
@property(nonatomic, readonly) NSUInteger iconRowsForCurrentOrientation;
@property(nonatomic, readonly) NSUInteger iconColumnsForCurrentOrientation;
@property(nonatomic, readonly, getter=isEditing) BOOL editing;
- (void)layoutIconsNow;
@end
@interface SBIconListGridLayoutConfiguration : NSObject <NSCopying>
@property(nonatomic) NSUInteger numberOfPortraitRows;
@property(nonatomic) NSUInteger numberOfPortraitColumns;
@end
@interface SBIconListGridLayout : NSObject
@property(nonatomic, readonly) SBIconListGridLayoutConfiguration *layoutConfiguration;
- (instancetype)initWithLayoutConfiguration:(id)configuration;
@end
@interface SBHIconManager : NSObject
@property(nonatomic, getter=isEditing) BOOL editing;
@end
