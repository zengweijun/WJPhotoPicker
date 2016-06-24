# WJPhotoPicker
* An easy way to use Photo Picker, You maybe export a video file to file path from a photo album, ti's adaptive iOS7 and iOS8 automatically(ALAsset and PHAsset), compatible with iPhone and iPad, landscape adaptation.
* 一款用法简单的可选择照片的相册,自动适配iOS7和iOS7,支持从相册中导出视频文件, 同事兼容iPhone、iPad，横屏适配.

## Contents
* Getting Started
* [System 【iOS7+】]

## Installation
* cocoapods导入：`pod 'WJPhotoPicker'` 
* 导入主头文件：`#import "WJPhotoGroupController.h"`

## Usage
Download zip and see demo for details.

eg.
In view controller

Initializec
    if (!_photoGroup) {
        _photoGroup = [[WJPhotoGroupController alloc] init];
        _photoGroup.mediaType = WJPhotoMediaTypeAll;
    }

Callback:
    __weak __typeof(&*self) ws = self;
    NSInteger maxCount = 9;
    self.photoGroup.maxCount = maxCount - self.images.count;
    self.photoGroup.completedCallback = ^(NSArray<WJPhotoAsset *> *seletedAssets) {
        // 这里返回当前选择的照片的Assets
        NSLog(@"seletedAssetsCount:%zd", seletedAssets.count);
        NSLog(@"seletedAssets:%@", seletedAssets);
    
        for (WJPhotoAsset *photoAsset in seletedAssets) {
            // 同步获取照片
            UIImage *originalImage = [ws.photoGroup synchronousGetImage:photoAsset thumb:NO];
            UIImage *thumbImage = [ws.photoGroup synchronousGetImage:photoAsset thumb:YES];
            NSLog(@"originalImage:%@, thumbImage:%@", originalImage, thumbImage);

            // 异步获取照片
            [ws.photoGroup asynchronousGetImage:photoAsset thumb:NO completeCb:^(UIImage *image) {
                NSLog(@"单独获取:originalImage:%@", image);
            }];

            [ws.photoGroup asynchronousGetImage:photoAsset thumb:YES completeCb:^(UIImage *image) {
                NSLog(@"单独获取:thumbImage:%@", image);
            }];

            [ws.photoGroup asynchronousGetImage:photoAsset completeCb:^(UIImage *originalImage, UIImage *thumbImage) {
                NSLog(@"一起获取:originalImage:%@,thumbImage:%@", originalImage, thumbImage);
            }];

            if (photoAsset.isVideo) {
                NSLog(@"\n\n\n:提取视频");
                NSString *doctumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
                NSString *filename = [NSString stringWithFormat:@"output-%@.mp4", [formater stringFromDate:[NSDate date]]];
                NSString *resultPath = [doctumentsPath stringByAppendingPathComponent:filename];

                NSLog(@"开始压缩");
                [ws.photoGroup exportVideoFileFromAsset:photoAsset filePath:resultPath completeCb:^(NSString *errStr) {
                    NSLog(@"resultPath:%@", resultPath);
                    NSLog(@"压缩完成");
                }];
            }
        }
    };

Show:
    UINavigationController *photoGroupNav = [[UINavigationController alloc] initWithRootViewController:self.photoGroup];
    [self presentViewController:photoGroupNav animated:YES completion:nil];


## License
WJPhotoBrowser is released under the MIT license. See LICENSE for details.
