//
//  WJPhotoGroup.m
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhotoGroup.h"

@implementation WJPhotoGroup

+ (instancetype)photoGroupWithAssetsGroup:(ALAssetsGroup *)assetsGroup {
    return [[self alloc] initWithAssetsGroup:assetsGroup];
}

+ (instancetype)photoGroupAssetCollection:(PHAssetCollection *)assetCollection {
    return [[self alloc] initWithAssetCollection:assetCollection];
}

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup {
    if (assetsGroup.numberOfAssets == 0) return nil;
    UIImage *image = [UIImage imageWithCGImage:assetsGroup.posterImage];
    if (self = [super initWithImage:image]) {
        self.caption = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        self.count = assetsGroup.numberOfAssets;
        self.assetsGroup = assetsGroup;
        self.assetCollection = nil;
    }
    return self;
}

- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection {
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    if (result == nil) return nil;
    if (result.count == 0) return nil;
    PHAsset *asset = result.lastObject;
    if (self = [super initWithAsset:asset targetSize:thumbTargetSize()]) {
        self.caption = assetCollection.localizedTitle;
        self.count = result.count;
        self.assetCollection = assetCollection;
        self.assetsGroup = nil;
    }
    return self;
}


@end
