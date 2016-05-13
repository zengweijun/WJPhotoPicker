//
//  WJPhotoAssets.m
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/17.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhotoAsset.h"

@implementation WJPhotoAsset

- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    if (self = [super initWithAsset:asset targetSize:targetSize]) {
        // 预加载image
    }
    return self;
}

- (void)setAAsset:(ALAsset *)aAsset {
    _aAsset = aAsset;
    _pAsset = nil;
}

- (void)setPAsset:(PHAsset *)pAsset {
    _pAsset = pAsset;
    _aAsset = nil;
}

@end
