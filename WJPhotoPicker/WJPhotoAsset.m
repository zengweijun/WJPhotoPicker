//
//  WJPhotoAssets.m
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/17.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhotoAsset.h"

@implementation WJPhotoAsset

- (BOOL)isVideo {
#if iOS8
    return _asset.mediaType == PHAssetMediaTypeVideo;
#else
    return [[_asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
#endif
}

- (NSTimeInterval)videoDuration {
#if iOS8
    return _asset.duration;
#else
    return [[_asset valueForProperty:ALAssetPropertyDuration] floatValue];
#endif
}

@end
