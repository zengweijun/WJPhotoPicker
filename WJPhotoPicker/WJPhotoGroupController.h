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

// The 'seletedPhotos' contain WJPhotos or subclass of WJPhotoAssets
@property (copy, nonatomic) void(^doneCallback)(NSArray *seletedPhotos);

@end
