//
//  WJPhotoToolbar.h
//  Example
//
//  Created by 森巴iOS开发部 on 16/6/22.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJPhotoToolbar : UIView
- (instancetype)initWithSeletedAssets:(NSMutableArray *)seletedAssets callback:(void(^)())callback;
- (void)update;

@end
