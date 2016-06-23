//
//  WJPhotoNavBar.m
//  Example
//
//  Created by 森巴iOS开发部 on 16/6/22.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJPhotoNavBar.h"

@interface WJPhotoNavBar()
@property (nonatomic, copy) void(^leftCallback)();
@property (nonatomic, copy) void(^rightCallback)();

@end

@implementation WJPhotoNavBar
- (instancetype)initWithTitle:(NSString *)title leftCallback:(void (^)())leftCallback rightCallback:(void (^)())rightCallback {
    if (self = [super init]) {
        self.leftCallback = leftCallback;
        self.rightCallback = rightCallback;
        self.backgroundColor = [UIColor redColor];
        
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
//        barbuttonicon_back
//        [backBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//        doneBtn.titleLabel.font = [UIFont systemFontOfSize:17];
//        [doneBtn setTitle:@"完成(0)" forState:UIControlStateNormal];
//        [doneBtn addTarget:self action:@selector(doneBtnTouched) forControlEvents:UIControlEventTouchUpInside];
//        doneBtn.enabled = NO;
//        [self addSubview:doneBtn];
//        doneBtn.translatesAutoresizingMaskIntoConstraints = NO;
//        NSDictionary *rightBtnViews = NSDictionaryOfVariableBindings(doneBtn);
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[doneBtn(60)]-10-|" options:0 metrics:nil views:rightBtnViews]];
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[doneBtn]-0-|" options:0 metrics:nil views:rightBtnViews]];
//        self.doneBtn = doneBtn;
        
    }
    return self;
}





@end

