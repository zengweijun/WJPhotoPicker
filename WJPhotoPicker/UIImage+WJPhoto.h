//
//  UIImage+WJPhoto.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 15/12/30.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WJPhoto)
+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type;
+ (UIImage *)clearImageWithSize:(CGSize)size;
@end
