//
//  WJPhotoGridCell.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 15/12/30.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#define WJPhotoGridCellSeletedButtonDidChage @"WJPhotoGridCellSeletedButtonDidChage"

#import <UIKit/UIKit.h>
@class WJPhotoAsset, WJPhotoGridController;
@interface WJPhotoGridCell : UICollectionViewCell
@property (strong, nonatomic) WJPhotoAsset *photoAsset;
@property (assign, nonatomic) BOOL selectionMode;

@property (weak, nonatomic) WJPhotoGridController *gridController;
@property (weak, nonatomic) UIButton *selectedButton;

- (void)selectionButtonPressed; // 点击选中按钮

- (void)displayImage;

@end
