//
//  WJAssetsPickerController.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoCommon.h"

#define WJPhotoPickerDoneButtonClicked @"WJPhotoPickerDoneButtonClicked"

@class WJPhotoGroup;

@interface WJPhotoGridController : UIViewController

@property (strong, nonatomic) WJPhotoGroup *group;
@property (assign, nonatomic) NSInteger maxCount;
@property (assign, nonatomic) BOOL selectionMode;
@property (assign, nonatomic) WJPhotoMediaType mediaType;

@property (strong, nonatomic) NSMutableArray *selectedPhotos;

@end
