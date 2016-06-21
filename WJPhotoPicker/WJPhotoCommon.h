//
//  WJPhotoCommon.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 15/12/28.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#ifndef WJPhotoCommon_h
#define WJPhotoCommon_h
#if 0
#   undef  WJLog
#   define WJLog(fmt, ...) NSLog((@"%@ [Line %d] " fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)
#else
#   undef  WJLog
#   define WJLog(fmt, ...)
#endif

#define WJDEBUGLOG(...) NSLog(__VA_ARGS__)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define iOS8_PHAsset @"PHAsset"
#define PADDING 2.
#define COLUMNS 4

#define WJPhotoPickerDoneColor [UIColor colorWithRed:11 / 255. green:127 / 255. blue:255 / 255. alpha:1]

typedef NS_ENUM(NSInteger, WJPhotoMediaType) {
    WJPhotoMediaTypePhoto = 0,
    WJPhotoMediaTypeVideo,
    WJPhotoMediaTypeAll,
};

// point --> pixel
static inline CGSize thumbTargetSize(NSUInteger columns) {
    return CGSizeMake(
                      ([UIScreen mainScreen].scale * MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) / columns),
                      
                      ([UIScreen mainScreen].scale * MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) / columns)
                      );
}

static inline CGSize imageTargetSize() {
    return CGSizeMake(
                      ([UIScreen mainScreen].scale * MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)),
                      ([UIScreen mainScreen].scale * MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height))
                      );
}

static inline CGSize targertSize(CGSize size) {
    return CGSizeMake(
                      size.width * [UIScreen mainScreen].scale,
                      size.height * [UIScreen mainScreen].scale
                      );
}

#endif /* WJPhotoConstant_h */
