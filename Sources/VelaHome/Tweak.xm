#import "VelaCompatibility/VLHomeAdapter.h"
#import "VelaCore/VLStore.h"
#import "VelaEditor/VLEditor.h"

%group VelaHome
%hook SBIconListView
- (id)layout {
    id original = %orig;
    return [VLHomeAdapter.shared layoutForList:self original:original];
}
- (void)layoutSubviews {
    [VLHomeAdapter.shared registerList:self];
    %orig;
    [VLEditor.shared updateForList:self];
}
- (void)setEditing:(BOOL)editing {
    %orig;
    [VLEditor.shared updateForList:self];
}
- (CGPoint)originForIconAtCoordinate:(VLCoordinate)coordinate metrics:(id)metrics options:(NSUInteger)options {
    CGPoint origin = %orig;
    if ([VLHomeAdapter.shared customizes:self]) {
        unsigned rows = (unsigned)self.iconRowsForCurrentOrientation;
        unsigned columns = (unsigned)self.iconColumnsForCurrentOrientation;
        VLCoordinate firstCoordinate = {1, 1}, lastCoordinate = {rows, columns};
        CGPoint first = %orig(firstCoordinate, metrics, options);
        CGPoint last = %orig(lastCoordinate, metrics, options);
        VLLayout fitted = VLFittedLayout(VLStore.shared.current, rows, columns,
                                        first.x, first.y, last.x, last.y,
                                        self.bounds.size.width, self.bounds.size.height);
        VLAdjustedOrigin(fitted, rows, columns,
                         coordinate.row, coordinate.column, self.bounds.size.width, self.bounds.size.height,
                         &origin.x, &origin.y);
    }
    return origin;
}
%end
%end

%group VelaLockLifecycle
%hook SBLockScreenManager
- (void)_setUILocked:(BOOL)locked {
    if (locked) [VLEditor.shared suspend];
    %orig;
}
%end
%end

%group VelaEditing
%hook SBHIconManager
- (void)setEditing:(BOOL)editing {
    if (!editing) [VLEditor.shared cancel];
    %orig;
}
%end
%end

%ctor {
    @autoreleasepool {
        if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone ||
            NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 16) return;
        Class list = NSClassFromString(@"SBIconListView");
        SEL selectors[] = {@selector(layout), @selector(layoutSubviews), @selector(setEditing:),
            @selector(iconRowsForCurrentOrientation), @selector(iconColumnsForCurrentOrientation),
            NSSelectorFromString(@"originForIconAtCoordinate:metrics:options:")};
        BOOL supported = list != Nil;
        for (unsigned i = 0; i < sizeof(selectors) / sizeof(SEL); i++)
            if (![list instancesRespondToSelector:selectors[i]]) supported = NO;
        Class configuration = NSClassFromString(@"SBIconListGridLayoutConfiguration");
        Class gridLayout = NSClassFromString(@"SBIconListGridLayout");
        Class model = NSClassFromString(@"SBIconListModel");
        if (![configuration instancesRespondToSelector:@selector(copyWithZone:)] ||
            ![configuration instancesRespondToSelector:@selector(setNumberOfPortraitRows:)] ||
            ![configuration instancesRespondToSelector:@selector(setNumberOfPortraitColumns:)] ||
            ![gridLayout instancesRespondToSelector:@selector(layoutConfiguration)] ||
            ![gridLayout instancesRespondToSelector:@selector(initWithLayoutConfiguration:)] ||
            ![model instancesRespondToSelector:@selector(gridSize)] ||
            ![model instancesRespondToSelector:@selector(setGridSize:)] ||
            ![NSClassFromString(@"SBRootFolder") instancesRespondToSelector:@selector(lists)]) supported = NO;
        if (supported) { %init(VelaHome); }
        Class manager = NSClassFromString(@"SBHIconManager");
        if ([manager instancesRespondToSelector:@selector(setEditing:)]) { %init(VelaEditing); }
        Class lock = NSClassFromString(@"SBLockScreenManager");
        if ([lock instancesRespondToSelector:NSSelectorFromString(@"_setUILocked:")]) { %init(VelaLockLifecycle); }
    }
}
