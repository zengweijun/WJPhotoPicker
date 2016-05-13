//
//  WJPhotoAsset.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/17.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhoto.h"
/**
 一个资源数据模型
 */
@interface WJPhotoAsset : WJPhoto
@property (strong, nonatomic) ALAsset *aAsset;
@property (strong, nonatomic) PHAsset *pAsset;

@property (assign, nonatomic) BOOL selected;

@end
