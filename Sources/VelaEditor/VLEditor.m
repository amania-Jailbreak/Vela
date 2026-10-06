#import "VLEditor.h"
#import "VelaCore/VLStore.h"
#import "VelaCompatibility/VLHomeAdapter.h"

@interface VLEditor ()
@property(nonatomic, weak) SBIconListView *list;
@property(nonatomic, strong) UIButton *entry;
@property(nonatomic, strong) UIView *overlay;
@property(nonatomic, strong) UILabel *status;
@property(nonatomic, strong) NSMutableArray<UILabel *> *labels;
@property(nonatomic, strong) NSMutableArray<UISlider *> *sliders;
@property(nonatomic) VLLayout dragStart;
@end

@implementation VLEditor
+ (instancetype)shared {
    static VLEditor *editor; static dispatch_once_t once;
    dispatch_once(&once, ^{ editor = [VLEditor new]; }); return editor;
}
- (instancetype)init {
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(suspend) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (UIButton *)button:(NSString *)title action:(SEL)action {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:title forState:UIControlStateNormal];
    b.backgroundColor = UIColor.secondarySystemBackgroundColor;
    b.layer.cornerRadius = 12;
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return b;
}
- (void)updateForList:(SBIconListView *)list {
    if (![VLHomeAdapter.shared isHomeList:list] || !list.window || list.hidden || list.alpha == 0) return;
    if (list.window.bounds.size.width > list.window.bounds.size.height) { [self cancel]; return; }
    if (![list respondsToSelector:@selector(isEditing)]) return;
    if (!list.isEditing) {
        if (self.list == list) { [self cancel]; [self.entry removeFromSuperview]; self.entry = nil; }
        return;
    }
    if (self.overlay) return;
    /* Only attach to a page currently visible in its window. */
    CGRect visible = [list convertRect:list.bounds toView:list.window];
    if (!CGRectIntersectsRect(visible, list.window.bounds)) return;
    if (self.list != list) { [self.entry removeFromSuperview]; self.entry = nil; self.list = list; }
    if (!self.entry) {
        self.entry = [self button:@"Vela" action:@selector(open)];
        self.entry.accessibilityLabel = @"Edit Home Screen layout with Vela";
        [list.window addSubview:self.entry];
    }
    CGFloat top = list.window.safeAreaInsets.top + 48;
    self.entry.frame = CGRectMake((list.window.bounds.size.width - 88) / 2, top, 88, 40);
    [list.window bringSubviewToFront:self.entry];
}
- (void)open {
    SBIconListView *list = self.list;
    if (!list.window || !list.isEditing || self.overlay) return;
    NSString *reason;
    if (![VLHomeAdapter.shared validate:VLStore.shared.current reason:&reason]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vela" message:reason preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        UIViewController *controller = list.window.rootViewController;
        while (controller.presentedViewController) controller = controller.presentedViewController;
        [controller presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (![VLStore.shared begin]) return;
    self.entry.hidden = YES;
    UIView *overlay = [[UIView alloc] initWithFrame:list.window.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlay = overlay;
    [list.window addSubview:overlay];
    UIView *selection = [[UIView alloc] initWithFrame:[list convertRect:list.bounds toView:list.window]];
    selection.userInteractionEnabled = YES;
    selection.layer.borderColor = UIColor.systemBlueColor.CGColor;
    selection.layer.borderWidth = 2;
    selection.accessibilityLabel = @"Home grid. Drag to move.";
    [selection addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
    [overlay addSubview:selection];

    UIView *panel = [UIView new];
    panel.backgroundColor = UIColor.secondarySystemBackgroundColor;
    panel.layer.cornerRadius = 18;
    panel.translatesAutoresizingMaskIntoConstraints = NO;
    [overlay addSubview:panel];
    [NSLayoutConstraint activateConstraints:@[
        [panel.leadingAnchor constraintEqualToAnchor:overlay.leadingAnchor constant:12],
        [panel.trailingAnchor constraintEqualToAnchor:overlay.trailingAnchor constant:-12],
        [panel.bottomAnchor constraintEqualToAnchor:overlay.safeAreaLayoutGuide.bottomAnchor constant:-8]
    ]];
    UIStackView *stack = [UIStackView new];
    stack.axis = UILayoutConstraintAxisVertical; stack.spacing = 5;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:14],
        [stack.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-14],
        [stack.topAnchor constraintEqualToAnchor:panel.topAnchor constant:10],
        [stack.bottomAnchor constraintEqualToAnchor:panel.bottomAnchor constant:-10]
    ]];
    UILabel *title = [UILabel new]; title.text = @"Home Grid · Drag to move";
    title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [stack addArrangedSubview:title];
    self.labels = [NSMutableArray new]; self.sliders = [NSMutableArray new];
    const float low[] = {2, 2, 0, 0, -0.15, -0.15};
    const float high[] = {10, 8, 16, 16, 0.15, 0.15};
    for (NSUInteger i = 0; i < 6; i++) {
        UILabel *label = [UILabel new]; label.font = [UIFont systemFontOfSize:12];
        UISlider *slider = [UISlider new]; slider.tag = i;
        slider.minimumValue = low[i]; slider.maximumValue = high[i];
        [slider addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
        [self.labels addObject:label]; [self.sliders addObject:slider];
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[label, slider]];
        row.spacing = 8;
        [label.widthAnchor constraintEqualToConstant:130].active = YES;
        [stack addArrangedSubview:row];
    }
    self.status = [UILabel new]; self.status.font = [UIFont systemFontOfSize:12];
    self.status.numberOfLines = 3; self.status.textColor = UIColor.secondaryLabelColor;
    self.status.text = @"Changes are saved only with Done.";
    [stack addArrangedSubview:self.status];
    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self button:@"Cancel" action:@selector(cancel)],
        [self button:@"Reset" action:@selector(reset)],
        [self button:@"Done" action:@selector(done)]
    ]];
    actions.distribution = UIStackViewDistributionFillEqually; actions.spacing = 8;
    [actions.heightAnchor constraintEqualToConstant:40].active = YES;
    [stack addArrangedSubview:actions];
    [self syncControls];
}
- (void)syncControls {
    VLLayout s = VLStore.shared.current;
    unsigned rows = s.rows ?: (unsigned)self.list.iconRowsForCurrentOrientation;
    unsigned columns = s.columns ?: (unsigned)self.list.iconColumnsForCurrentOrientation;
    float values[] = {rows, columns, s.horizontalSpacing, s.verticalSpacing, s.x, s.y};
    NSArray *names = @[@"Rows", @"Columns", @"Horizontal spacing", @"Vertical spacing", @"Grid X", @"Grid Y"];
    for (NSUInteger i = 0; i < self.sliders.count; i++) {
        self.sliders[i].value = values[i];
        NSString *value = i < 2 ? [NSString stringWithFormat:@"%.0f", values[i]] :
            (i < 4 ? [NSString stringWithFormat:@"+%.0f pt", values[i]] : [NSString stringWithFormat:@"%.0f%%", values[i] * 100]);
        self.labels[i].text = [NSString stringWithFormat:@"%@: %@", names[i], value];
        self.sliders[i].accessibilityLabel = names[i];
        self.sliders[i].accessibilityValue = value;
    }
}
- (BOOL)preview:(VLLayout)s {
    NSString *reason;
    if (![VLHomeAdapter.shared validate:s reason:&reason]) {
        self.status.text = reason ?: @"This layout cannot be applied safely.";
        [self syncControls]; return NO;
    }
    if (![VLStore.shared preview:s]) return NO;
    [VLHomeAdapter.shared refresh];
    [self syncControls]; self.status.text = @"Preview · not saved"; return YES;
}
- (void)change:(UISlider *)slider {
    VLLayout s = VLStore.shared.current;
    switch (slider.tag) {
        case 0: s.rows = lroundf(slider.value); s.columns = s.columns ?: (unsigned)self.list.iconColumnsForCurrentOrientation; break;
        case 1: s.columns = lroundf(slider.value); s.rows = s.rows ?: (unsigned)self.list.iconRowsForCurrentOrientation; break;
        case 2: s.horizontalSpacing = roundf(slider.value); break;
        case 3: s.verticalSpacing = roundf(slider.value); break;
        case 4: s.x = slider.value; break;
        case 5: s.y = slider.value; break;
    }
    [self preview:s];
}
- (void)pan:(UIPanGestureRecognizer *)gesture {
    if (!VLStore.shared.editing) return;
    if (gesture.state == UIGestureRecognizerStateBegan) self.dragStart = VLStore.shared.current;
    if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self preview:self.dragStart]; return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint delta = [gesture translationInView:self.list];
        VLLayout s = self.dragStart;
        s.x = fmax(-0.15, fmin(0.15, s.x + delta.x / fmax(1, self.list.bounds.size.width)));
        s.y = fmax(-0.15, fmin(0.15, s.y + delta.y / fmax(1, self.list.bounds.size.height)));
        [self preview:s];
    }
}
- (void)close {
    [self.overlay removeFromSuperview]; self.overlay = nil;
    self.labels = nil; self.sliders = nil; self.status = nil;
    self.entry.hidden = NO;
}
- (void)cancel {
    if (VLStore.shared.editing) { [VLStore.shared cancel]; [VLHomeAdapter.shared refresh]; }
    [self close];
}
- (void)suspend {
    [self cancel];
    [self.entry removeFromSuperview]; self.entry = nil; self.list = nil;
}
- (void)done {
    NSString *reason;
    if (![VLHomeAdapter.shared validate:VLStore.shared.current reason:&reason]) { self.status.text = reason; return; }
    NSError *error;
    if (![VLStore.shared done:&error]) { self.status.text = @"Could not save. Your preview is still open; retry or Cancel."; return; }
    [self close];
}
- (void)reset {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Home Screen Layout?" message:@"Restore Apple's grid in this preview. Save with Done, or undo with Cancel." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action) { [weakSelf preview:VLDefaultLayout()]; }]];
    UIViewController *controller = self.list.window.rootViewController;
    while (controller.presentedViewController) controller = controller.presentedViewController;
    [controller presentViewController:alert animated:YES completion:nil];
}
@end
