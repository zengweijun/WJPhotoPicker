//
//  WJPhotoDisplayCell.m
//  Example
//
//  Created by 森巴iOS开发部 on 16/6/21.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJPhotoDisplayCell.h"

@implementation WJPhotoDisplayCell

- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_imageView = imageView];
    }
    return _imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end
