//
//  UIImage+WJPhoto.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 15/12/30.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "UIImage+WJPhoto.h"

@implementation UIImage (WJPhoto)
+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type {
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:type]];
}

+ (UIImage *)clearImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

@end
