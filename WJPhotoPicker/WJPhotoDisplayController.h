//
//  WJPhotoDisplayController.h
//  Example
//
//  Created by 森巴iOS开发部 on 16/6/21.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WJPhotoGridController;
@interface WJPhotoDisplayController : UIViewController

@property (nonatomic, weak) WJPhotoGridController *gridViewController;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSArray *thumbs;

@property (nonatomic, copy) void(^popCompleted)();

@end
