//
//  WJPhotoDisplayCell.m
//  Example
//
//  Created by 森巴iOS开发部 on 16/6/21.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJPhotoDisplayCell.h"

@implementation WJPhotoDisplayCell

- (WJPhotoDisplayView *)photoDisplayView {
    if (!_photoDisplayView) {
        WJPhotoDisplayView *photoDisplayView = [[WJPhotoDisplayView alloc] init];
        photoDisplayView.frame = self.bounds;
        photoDisplayView.clipsToBounds = YES;
        [self addSubview:photoDisplayView];
        self.photoDisplayView = photoDisplayView;
    }
    return _photoDisplayView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoDisplayView.frame = self.bounds;
}

@end
