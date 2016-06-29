//
//  WJPhotoDisplayToolbar.m
//  Example
//
//  Created by 森巴iOS开发部 on 16/6/22.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJPhotoDisplayToolbar.h"
#import "WJPhotoCommon.h"
#import "WJPhotoGridController.h"

@interface WJPhotoDisplayToolbar()
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UIButton *doneBtn;
@property (nonatomic, copy) void(^callback)();

@property (nonatomic, strong) NSMutableArray *seletedAssets;

@end

@implementation WJPhotoDisplayToolbar
- (instancetype)initWithSeletedAssets:(NSMutableArray *)seletedAssets callback:(void(^)())callback{
    if (self = [super init]) {
        self.callback = callback;
        self.seletedAssets = seletedAssets;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor lightGrayColor];
        lineView.alpha = 0.5;
        [self addSubview:lineView];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *lineViews = NSDictionaryOfVariableBindings(lineView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lineView]-0-|" options:0 metrics:nil views:lineViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lineView(0.5)]" options:0 metrics:nil views:lineViews]];
        self.lineView = lineView;
        
        // send button
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBtn setTitleColor:WJPhotoPickerDoneColor forState:UIControlStateNormal];
        [doneBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        doneBtn.enabled = YES;
        doneBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [doneBtn setTitle:@"完成(0)" forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(doneBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        doneBtn.enabled = NO;
        [self addSubview:doneBtn];
        doneBtn.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *rightBtnViews = NSDictionaryOfVariableBindings(doneBtn);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[doneBtn(60)]-10-|" options:0 metrics:nil views:rightBtnViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[doneBtn]-0-|" options:0 metrics:nil views:rightBtnViews]];
        self.doneBtn = doneBtn;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:WJPhotoGridCellSeletedButtonDidChage object:nil];
        [self update];
    }
    return self;
}

- (void)doneBtnTouched {
    if (self.callback) self.callback();
    [[NSNotificationCenter defaultCenter] postNotificationName:WJPhotoPickerDoneButtonClicked object:nil];
}


#pragma mark - Notification
- (void)update {
    NSString *title = [NSString stringWithFormat:@"完成(%zd)", self.seletedAssets.count];
    [self.doneBtn setTitle:title forState:UIControlStateNormal];
    self.doneBtn.enabled = self.seletedAssets.count;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}




@end
