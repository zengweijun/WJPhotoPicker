//
//  UIImage+WJPhoto.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 15/12/30.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "UIImage+WJPhoto.h"

@implementation UIImage (WJPhoto)
+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle {
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:path ofType:type];
    return [UIImage imageWithContentsOfFile:imgPath];
}

+ (UIImage *)clearImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

@end
