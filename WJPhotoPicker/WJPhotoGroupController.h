//
//  WJPhotoGroupController.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoCommon.h"
#import "WJPhotoAsset.h"

@interface WJPhotoGroupController : UIViewController
@property (assign, nonatomic) BOOL selectionMode;
@property (assign, nonatomic) WJPhotoMediaType mediaType;
@property (assign, nonatomic) NSInteger maxCount;

// The 'seletedImages' contain UIImages that's 'original image' objects
@property (copy, nonatomic) void(^doneCallback)(NSArray<UIImage *> *seletedImages);

// The 'seletedPhotos' contain WJPhotoAssets
// Note: if the version is iOS8.0+, use PHAssets Otherwise ALAssets
/**
 Use the following methods to obtain images
 - (UIImage *)synchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb;
 - (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb completeCb:(void(^)(UIImage *image))completeCb;
 - (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset completeCb:(void(^)(UIImage *originalImage, UIImage *thumbImage))completeCb;
 */
@property (copy, nonatomic) void(^completedCallback)(NSArray<WJPhotoAsset *> *seletedAssets);

// Fetch image methods synchronous or asynchronous
- (UIImage *)synchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb;
- (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb completeCb:(void(^)(UIImage *image))completeCb;
- (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset completeCb:(void(^)(UIImage *originalImage, UIImage *thumbImage))completeCb;

@end
