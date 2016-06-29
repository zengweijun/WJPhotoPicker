//
//  WJAssetsPickerController.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoCommon.h"
#import "WJPhotoPickerController.h"

@class WJPhotoGroup;
@interface WJPhotoGridController : UIViewController
@property (nonatomic, weak) WJPhotoPickerController *groupController;

@property (strong, nonatomic) WJPhotoGroup *group;
@property (assign, nonatomic) NSInteger maxCount;
@property (assign, nonatomic) BOOL selectionMode;
@property (assign, nonatomic) WJPhotoMediaType mediaType;

@property (strong, nonatomic) NSMutableArray *seletedAssets;
- (void)selectionButtonPressed:(UIButton *)seletedButton photoAsset:(WJPhotoAsset *)photoAsset;

@property (nonatomic, copy) NSString *presetName;
@property (nonatomic, copy) NSString *filePath;

@end
