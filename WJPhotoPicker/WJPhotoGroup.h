//
//  WJPhotoGroup.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoCommon.h"
#import "WJPhoto.h"

/**
 一组资源的数据模型
 */
@interface WJPhotoGroup : WJPhoto
@property (assign, nonatomic) NSInteger count;

@property (strong, nonatomic) ALAssetsGroup *assetsGroup;
@property (strong, nonatomic) PHAssetCollection *assetCollection;

+ (instancetype)photoGroupWithAssetsGroup:(ALAssetsGroup *)assetsGroup;
+ (instancetype)photoGroupAssetCollection:(PHAssetCollection *)assetCollection;

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup;
- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection;

@end
