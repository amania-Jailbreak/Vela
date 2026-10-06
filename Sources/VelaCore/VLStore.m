#import "VLStore.h"
#include <math.h>

@implementation VLStore {
    VLSession _session;
    NSUInteger _revision;
    NSURL *_url;
}
+ (instancetype)shared {
    static VLStore *store; static dispatch_once_t once;
    dispatch_once(&once, ^{ store = [VLStore new]; }); return store;
}
- (instancetype)init {
    if (!(self = [super init])) return nil;
    NSURL *library = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].firstObject;
    _url = [[library URLByAppendingPathComponent:@"Preferences"] URLByAppendingPathComponent:@"com.amania.vela.home.json"];
    NSData *data = [NSData dataWithContentsOfURL:_url];
    NSDictionary *d = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    if ([d isKindOfClass:NSDictionary.class] && [d[@"version"] isKindOfClass:NSNumber.class] && [d[@"version"] unsignedIntegerValue] == 1) {
        NSArray *keys = @[@"rows", @"columns", @"horizontalSpacing", @"verticalSpacing", @"x", @"y"];
        BOOL valid = YES;
        for (NSString *key in keys) if (![d[key] isKindOfClass:NSNumber.class]) valid = NO;
        if (valid) {
            double rows = [d[@"rows"] doubleValue], columns = [d[@"columns"] doubleValue];
            if (isfinite(rows) && isfinite(columns) && rows >= 0 && rows <= 10 && columns >= 0 && columns <= 8 && floor(rows) == rows && floor(columns) == columns) {
                VLLayout s = {(unsigned)rows, (unsigned)columns, [d[@"horizontalSpacing"] doubleValue], [d[@"verticalSpacing"] doubleValue], [d[@"x"] doubleValue], [d[@"y"] doubleValue]};
                if (VLLayoutValid(s)) _session.saved = s;
            }
        }
    }
    return self;
}
- (VLLayout)current { return VLCurrent(&_session); }
- (BOOL)editing { return _session.editing; }
- (NSUInteger)revision { return _revision; }
- (BOOL)begin { return VLBegin(&_session); }
- (BOOL)preview:(VLLayout)s {
    if (!VLPreview(&_session, s)) return NO;
    _revision++; return YES;
}
- (BOOL)done:(NSError **)error {
    if (!_session.editing) return NO;
    VLLayout s = _session.working;
    NSDictionary *d = @{@"version": @1, @"rows": @(s.rows), @"columns": @(s.columns), @"horizontalSpacing": @(s.horizontalSpacing), @"verticalSpacing": @(s.verticalSpacing), @"x": @(s.x), @"y": @(s.y)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:d options:0 error:error];
    if (!data || ![data writeToURL:_url options:NSDataWritingAtomic error:error]) return NO;
    return VLCommit(&_session, true);
}
- (void)cancel { VLCancel(&_session); _revision++; }
@end
