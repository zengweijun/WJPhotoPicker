//
//  WJPhotoPickerController.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoCommon.h"
#import "WJPhotoAsset.h"

@class WJPhotoPickerController;
typedef void(^CompletedCallback)(WJPhotoPickerController *picker, NSArray<WJPhotoAsset *> *seletedAssets);
typedef void(^FetchVideoCallback)(WJPhotoPickerController *picker, WJPhotoAsset *asset, NSString *filePath, NSError *error);

@interface WJPhotoPickerController : UIViewController
@property (assign, nonatomic) WJPhotoMediaType mediaType;
@property (assign, nonatomic) NSInteger maxCount;
@property (assign, nonatomic) BOOL selectionMode;

// The 'seletedPhotos' contain WJPhotoAssets
// Note: if the version is iOS8.0+, use PHAssets Otherwise ALAssets
/**
 Use the following methods to obtain images
 - (UIImage *)synchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb;
 - (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb completeCb:(void(^)(UIImage *image))completeCb;
 - (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset completeCb:(void(^)(UIImage *originalImage, UIImage *thumbImage))completeCb;
 */
@property (copy, nonatomic) CompletedCallback completedCallback;
@property (copy, nonatomic) FetchVideoCallback fetchVideoCallback;

// General initialize
- (instancetype)initWithCompletedCallback:(CompletedCallback)completedCallback;

// Fetch video
- (instancetype)initWithFetchVideo:(NSString *)filePath presetName:(NSString *)presetName fetchVideoCallback:(FetchVideoCallback)fetchVideoCallback;

- (instancetype)show:(UIViewController *)viewController;

// Fetch image methods synchronous or asynchronous
- (UIImage *)synchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb;
- (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb completeCb:(void(^)(UIImage *image))completeCb;
- (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset completeCb:(void(^)(UIImage *originalImage, UIImage *thumbImage))completeCb;

- (void)getVideoURLFromAsset:(WJPhotoAsset *)asset completeCb:(void (^)(NSURL *videURL))completeCb;

/**
 Export a video file to file path, adaptive iOS7 and iOS8 automatically.
 The presetName Default is `AVAssetExportPresetHighestQuality` type
 eg.
 ALAsset:
    NSString *doctumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
 
    NSString *filename = [NSString stringWithFormat:@"output-%@.mp4", [formater stringFromDate:[NSDate date]]];
    NSString *resultPath = [doctumentsPath stringByAppendingPathComponent:filename];
    [self exportVideoFileFromALAsset:asset filePath:resultPath completeCb:^(NSString *errStr) {
        if (!errStr) {
            NSLog(@"处理完成:resultPath = %@",resultPath);
        }
    }];
 
 PHAsset:
    NSString *doctumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
 
    NSString *filename = [NSString stringWithFormat:@"output-%@.mp4", [formater stringFromDate:[NSDate date]]];
    NSString *resultPath = [doctumentsPath stringByAppendingPathComponent:filename];
    [self exportVideoFileFromPHAsset:asset filePath:resultPath completeCb:^(NSString *errStr) {
        if (!errStr) {
            NSLog(@"处理完成:resultPath = %@",resultPath);
        }
    }];
 */
- (void)exportVideoFileFromAsset:(WJPhotoAsset *)asset filePath:(NSString *)filePath completeCb:(void (^)(NSString *errStr))completeCb;
- (void)exportVideoFileFromAsset:(WJPhotoAsset *)asset filePath:(NSString *)filePath presetName:(NSString *)presetName completeCb:(void (^)(NSString *errStr))completeCb;


@end
