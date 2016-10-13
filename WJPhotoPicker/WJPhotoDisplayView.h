//
//  WJPhotoDisplayView.h
//  Example
//
//  Created by Nius on 2016/10/13.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJPhotoDisplayView : UIView
@property (nonatomic, weak)   UIImageView *imageView;
@property (nonatomic, assign) BOOL  doubleTapZoom;

@property (nonatomic, copy)   void (^doubleTapCb)(WJPhotoDisplayView *imageBrowserView);
@property (nonatomic, copy)   void (^singleTapCb)(WJPhotoDisplayView *imageBrowserView);

@end
