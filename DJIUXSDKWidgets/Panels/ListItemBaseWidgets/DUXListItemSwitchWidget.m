//
//  DUXListItemSwitchWidget.m
//  DJIUXSDKWidgets
//
//  Copyright © 2018-2020 DJI
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DUXListItemSwitchWidget.h"
@import DJIUXSDKCore;

@interface DUXListItemSwitchWidget ()
@property (nonatomic, weak) SwitchChangedActionBlock    actionBlock;
@end

@implementation DUXListItemSwitchWidget

- (void)setupCustomizableSettings {
    [super setupCustomizableSettings];
    _switchTintColor = UIColor.systemGreenColor;
}

/*********************************************************************************/
#pragma mark - View Lifecycle Methods
/*********************************************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BindRKVOModel(self, @selector(switchEnabledStateChanged), onOffSwitch.enabled);
    BindRKVOModel(self, @selector(updateSwitchTint), switchTintColor);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UnBindRKVOModel(self);
}

- (void)setSwitchAction:(SwitchChangedActionBlock)newBlock {
    self.actionBlock = newBlock;
}

- (void)switchEnabledStateChanged {
    [DUXStateChangeBroadcaster send:[ListItemSwitchUIState switchEnabled:self.onOffSwitch.enabled]];
    [self updateUI];
}

// This setupUI does not set a hard width. That should probably be imposed externally.
- (void)setupUI {
    [super setupUI];
    
    self.onOffSwitch = [[UISwitch alloc] init];
    self.onOffSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.onOffSwitch];
    
    // These are indded magic number for Apple switches. They aren't actually documented, but are the internal sizes always used
    // for a switch. Using different numbers is non-optimal.
    [self.onOffSwitch.widthAnchor constraintEqualToConstant:51.0].active = YES;
    [self.onOffSwitch.heightAnchor constraintEqualToConstant:31.0].active = YES;

    [self.onOffSwitch.trailingAnchor constraintEqualToAnchor:self.trailingMarginGuide.leadingAnchor].active = YES;
    [self.onOffSwitch.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    [self.onOffSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateUI];
}

- (void)updateSwitchTint {
    self.onOffSwitch.onTintColor = self.switchTintColor;
}

- (IBAction)switchChanged:(id)sender {
    [DUXStateChangeBroadcaster send:[ListItemSwitchUIState switchValueChanged:self.onOffSwitch.on]];
    if (self.actionBlock) {
        self.actionBlock(self.onOffSwitch.on);
    }
    
//    [self.widgetModel toggleSettingWithCompletionBlock:^(NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"error setting option '%@': %@", self.titleString, error);
//        }
//    }];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    CGFloat height = 44.0;
    CGFloat width = 320.0;
    DUXBetaWidgetSizeHint hint = {width/height, width, height};
    return hint;
}

@end

@implementation ListItemSwitchUIState

+ (instancetype)switchValueChanged:(BOOL)isOn {
    return [[self alloc] initWithKey:@"switchValueChanged" number:@(isOn)];
}

+ (instancetype)switchEnabled:(BOOL)isEnabled {
    return [[self alloc] initWithKey:@"switchEnabled" number:@(isEnabled)];
}

@end
