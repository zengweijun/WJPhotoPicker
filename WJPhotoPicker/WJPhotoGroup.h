//
//  WJPhotoGroup.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoCommon.h"

/**
 一组资源的数据模型
 */
@interface WJPhotoGroup : NSObject

@property (nonatomic, copy) NSString *caption;
@property (assign, nonatomic) NSInteger count;

#if iOS8
@property (strong, nonatomic) PHAssetCollection *assets;
#else
@property (strong, nonatomic) ALAssetsGroup *assets;
#endif


@end
