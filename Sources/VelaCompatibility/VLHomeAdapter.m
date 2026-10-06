#import "VLHomeAdapter.h"
#import "VelaCore/VLStore.h"
#import <objc/runtime.h>

static char VLNativeGridKey, VLLayoutKey, VLRevisionKey;
@implementation VLHomeAdapter {
    NSHashTable<SBIconListView *> *_lists;
    NSHashTable<SBIconListModel *> *_models;
    BOOL _refreshing;
    BOOL _refreshScheduled;
}
+ (instancetype)shared {
    static VLHomeAdapter *adapter; static dispatch_once_t once;
    dispatch_once(&once, ^{ adapter = [VLHomeAdapter new]; }); return adapter;
}
- (instancetype)init {
    if ((self = [super init])) {
        _lists = [NSHashTable weakObjectsHashTable];
        _models = [NSHashTable weakObjectsHashTable];
    }
    return self;
}
- (BOOL)isHomeList:(SBIconListView *)list {
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone ||
        ![list respondsToSelector:@selector(iconLocation)] || ![list respondsToSelector:@selector(model)]) return NO;
    /* Exact allowlist excludes Dock, folders, App Library and widget variants. */
    if (![list.iconLocation isEqualToString:@"SBIconLocationRoot"]) return NO;
    id model = list.model;
    if (![model respondsToSelector:@selector(folder)]) return NO;
    Class root = NSClassFromString(@"SBRootFolder");
    return root && [[model folder] isKindOfClass:root];
}
- (void)registerList:(SBIconListView *)list {
    if (![self isHomeList:list]) return;
    SBIconListModel *model = list.model;
    if (![model respondsToSelector:@selector(gridSize)] || ![model respondsToSelector:@selector(setGridSize:)] ||
        ![model respondsToSelector:@selector(icons)]) return;
    id folder = model.folder;
    if (![folder respondsToSelector:@selector(lists)]) return;
    id models = [(VLRootFolder *)folder lists];
    if (![models isKindOfClass:NSArray.class]) return;
    BOOL newList = ![_lists containsObject:list];
    [_lists addObject:list];
    for (SBIconListModel *page in models) {
        if (![page respondsToSelector:@selector(gridSize)] || ![page respondsToSelector:@selector(setGridSize:)] || ![page respondsToSelector:@selector(icons)]) continue;
        [_models addObject:page];
        if (!objc_getAssociatedObject(page, &VLNativeGridKey)) {
            VLGridSize grid = [page gridSize];
            objc_setAssociatedObject(page, &VLNativeGridKey, [NSData dataWithBytes:&grid length:sizeof(grid)], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    if (newList && !_refreshScheduled) {
        _refreshScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_refreshScheduled = NO;
            [self refresh];
        });
    }
}
- (BOOL)hasWidgets:(SBIconListModel *)model {
    for (id icon in model.icons) {
        /* Unknown icon types are conservatively rejected. */
        SEL selector = NSSelectorFromString(@"gridSizeClass");
        if (![icon respondsToSelector:selector]) return YES;
        NSUInteger (*send)(id, SEL) = (void *)[icon methodForSelector:selector];
        if (send(icon, selector) != 0) return YES;
    }
    return NO;
}
- (BOOL)validate:(VLLayout)s reason:(NSString **)reason {
    if (!VLLayoutValid(s)) { if (reason) *reason = @"Invalid layout values."; return NO; }
    if (!_lists.count) { if (reason) *reason = @"This iOS Home Screen layout is not supported."; return NO; }
    for (SBIconListModel *model in _models) {
        if ([self hasWidgets:model]) { if (reason) *reason = @"Phase 1 supports icon-only Home pages. Widget layout support follows in Phase 2."; return NO; }
        VLGridSize native; NSData *data = objc_getAssociatedObject(model, &VLNativeGridKey);
        if (data.length != sizeof(native)) return NO;
        [data getBytes:&native length:sizeof(native)];
        if (!VLCanFit(s.rows ?: native.rows, s.columns ?: native.columns, model.icons.count, NO)) {
            if (reason) *reason = @"This grid cannot hold every icon on every page. Choose more rows or columns.";
            return NO;
        }
    }
    for (SBIconListView *list in _lists) {
        if (![self isHomeList:list]) continue;
        if ([self hasWidgets:list.model]) { if (reason) *reason = @"Phase 1 supports icon-only Home pages. Widget layout support follows in Phase 2."; return NO; }
        VLGridSize native; NSData *data = objc_getAssociatedObject(list.model, &VLNativeGridKey);
        if (data.length != sizeof(native)) return NO;
        [data getBytes:&native length:sizeof(native)];
        unsigned rows = s.rows ?: native.rows, columns = s.columns ?: native.columns;
        if (!VLCanFit(rows, columns, list.model.icons.count, NO)) {
            if (reason) *reason = @"This grid cannot hold every icon. Choose more rows or columns; Vela does not move icons to other pages.";
            return NO;
        }
        /* Conservative fit: preserve space for 60pt icon images and labels. */
        if (list.bounds.size.width > 0 && list.bounds.size.height > 0 &&
            (columns * 60 + (columns - 1) * s.horizontalSpacing + 2 * fabs(s.x) * list.bounds.size.width > list.bounds.size.width ||
             rows * 76 + (rows - 1) * s.verticalSpacing + 2 * fabs(s.y) * list.bounds.size.height > list.bounds.size.height)) {
            if (reason) *reason = @"The grid would extend outside this page. Reduce spacing, position offset, rows or columns.";
            return NO;
        }
    }
    return YES;
}
- (BOOL)customizes:(SBIconListView *)list {
    VLLayout s = VLStore.shared.current;
    if (!s.rows && !s.columns && !s.horizontalSpacing && !s.verticalSpacing && !s.x && !s.y) return NO;
    if (![self isHomeList:list] || !objc_getAssociatedObject(list.model, &VLNativeGridKey)) return NO;
    if (list.window && list.window.bounds.size.width > list.window.bounds.size.height) return NO;
    return [self validate:s reason:nil];
}
- (id)layoutForList:(SBIconListView *)list original:(id)original {
    [self registerList:list];
    VLLayout s = VLStore.shared.current;
    if (![self customizes:list] || !s.rows || ![original respondsToSelector:@selector(layoutConfiguration)]) return original;
    NSNumber *revision = objc_getAssociatedObject(list, &VLRevisionKey);
    id cached = objc_getAssociatedObject(list, &VLLayoutKey);
    if (cached && revision.unsignedIntegerValue == VLStore.shared.revision) return cached;
    id configuration = [(SBIconListGridLayout *)original layoutConfiguration];
    if (![configuration respondsToSelector:@selector(copyWithZone:)] ||
        ![configuration respondsToSelector:@selector(setNumberOfPortraitRows:)] ||
        ![configuration respondsToSelector:@selector(setNumberOfPortraitColumns:)]) return original;
    SBIconListGridLayoutConfiguration *copy = [configuration copy];
    copy.numberOfPortraitRows = s.rows; copy.numberOfPortraitColumns = s.columns;
    Class cls = NSClassFromString(@"SBIconListGridLayout");
    if (![cls instancesRespondToSelector:@selector(initWithLayoutConfiguration:)]) return original;
    cached = [[cls alloc] initWithLayoutConfiguration:copy];
    objc_setAssociatedObject(list, &VLLayoutKey, cached, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(list, &VLRevisionKey, @(VLStore.shared.revision), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return cached ?: original;
}
- (void)refresh {
    if (_refreshing) return;
    _refreshing = YES;
    VLLayout s = VLStore.shared.current;
    BOOL apply = [self validate:s reason:nil];
    for (SBIconListModel *model in _models) {
        NSData *data = objc_getAssociatedObject(model, &VLNativeGridKey);
        if (data.length != sizeof(VLGridSize)) continue;
        VLGridSize grid; [data getBytes:&grid length:sizeof(grid)];
        if (apply && s.rows) grid = (VLGridSize){s.columns, s.rows};
        VLGridSize current = [model gridSize];
        if (current.rows != grid.rows || current.columns != grid.columns) [model setGridSize:grid];
    }
    for (SBIconListView *list in _lists) {
        objc_setAssociatedObject(list, &VLLayoutKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [list setNeedsLayout];
        if ([list respondsToSelector:@selector(layoutIconsNow)]) [list layoutIconsNow];
    }
    _refreshing = NO;
}
@end
