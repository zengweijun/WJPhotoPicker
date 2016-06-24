# WJPhotoPicker
* An easy way to use Photo Picker, You maybe export a video file to file path from a photo album, ti's adaptive iOS7 and iOS8 automatically(ALAsset and PHAsset), compatible with iPhone and iPad, landscape adaptation.
* 一款用法简单的可选择照片的相册,自动适配iOS7和iOS7,支持从相册中导出视频文件, 同事兼容iPhone、iPad，横屏适配.

## Contents
* Getting Started
* [System 【iOS7+】]

## Installation
* Podfile add：`pod 'WJPhotoPicker'` 
* 导入主头文件：`#import "WJPhotoPickerController.h"`

## Usage
Download zip and see demo for details.

#### Example (synchronous and asynchronous get image or videos)
```objective-c

    // Synchronous get image
    UIImage *originalImage = [picker synchronousGetImage:photoAsset thumb:NO];
    UIImage *thumbImage = [picker synchronousGetImage:photoAsset thumb:YES];
    NSLog(@"originalImage:%@, thumbImage:%@", originalImage, thumbImage);

    // Asynchronous get image
    [picker asynchronousGetImage:photoAsset thumb:NO completeCb:^(UIImage *image) {
        NSLog(@"originalImage:%@", image);
    }];
    [picker asynchronousGetImage:photoAsset thumb:YES completeCb:^(UIImage *image) {
        NSLog(@"thumbImage:%@", image);
    }];
    [picker asynchronousGetImage:photoAsset completeCb:^(UIImage *originalImage, UIImage *thumbImage) {
        NSLog(@"originalImage:%@,thumbImage:%@", originalImage, thumbImage);
    }];


    // Asynchronous get image
    if (photoAsset.isVideo) {
        NSString *doctumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *filename = [NSString stringWithFormat:@"output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        NSString *resultPath = [doctumentsPath stringByAppendingPathComponent:filename];

        NSLog(@"----start----exportVideoFile");
        [picker exportVideoFileFromAsset:photoAsset filePath:resultPath completeCb:^(NSString *errStr) {
            NSLog(@"resultPath:%@", resultPath);
            NSLog(@"----end----exportVideoFile");
        }];
    }

```

## License
WJPhotoBrowser is released under the MIT license. See LICENSE for details.
