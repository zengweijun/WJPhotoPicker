//
//  ViewController.m
//  Example
//
//  Created by 曾维俊 on 16/5/13.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "ViewController.h"
#import "WJPhotoGroupController.h"

@interface ViewController ()
@property (strong, nonatomic) WJPhotoGroupController *photoGroup;

@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *assets;

- (IBAction)openAlbum:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
}

- (WJPhotoGroupController *)photoGroup {
    if (!_photoGroup) {
        _photoGroup = [[WJPhotoGroupController alloc] init];
        _photoGroup.mediaType = WJPhotoMediaTypeAll;
    }
    return _photoGroup;
}

- (IBAction)openAlbum:(id)sender {
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
    
    
    UINavigationController *photoGroupNav = [[UINavigationController alloc] initWithRootViewController:self.photoGroup];
    [self presentViewController:photoGroupNav animated:YES completion:nil];
}

@end
