//
//  WJPhotoAsset.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/17.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoCommon.h"

/**
 一个资源数据模型
 */
@interface WJPhotoAsset : NSObject

#if iOS8
@property (strong, nonatomic) PHAsset *asset;
#else
@property (strong, nonatomic) ALAsset *asset;
#endif

@property (assign, nonatomic) BOOL selected;
@property (nonatomic, assign, getter=isVideo) BOOL video;


@property (nonatomic, assign, readonly) NSTimeInterval videoDuration;

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
//@property (strong, nonatomic) PHAsset *asset;
//#else
//@property (strong, nonatomic) ALAsset *asset;
//#endif

@end
