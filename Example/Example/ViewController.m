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

@property (strong, nonatomic) NSMutableArray *photos;
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
        _photoGroup.mediaType = WJPhotoMediaTypePhoto;
    }
    return _photoGroup;
}

- (IBAction)openAlbum:(id)sender {
    //__weak __typeof(&*self) ws = self;
    NSInteger maxCount = 9;
    self.photoGroup.maxCount = maxCount - self.photos.count;
    self.photoGroup.doneCallback = ^(NSArray<UIImage *> *seletedImages) {
       
        // 这里返回当前选择的照片
        NSLog(@"seletedPhotosCount:%zd", seletedImages.count);
        NSLog(@"seletedPhotos:%@", seletedImages);
        
    };
    
    
    __weak __typeof__(&*self) ws = self;
    self.photoGroup.completedCallback = ^(NSArray<WJPhotoAsset *> *seletedAssets) {
        
        // 这里返回当前选择的照片的Assets
        NSLog(@"seletedAssetsCount:%zd", seletedAssets.count);
        NSLog(@"seletedAssets:%@", seletedAssets);
        
        for (WJPhotoAsset *photoAsset in seletedAssets) {
            // sync
            UIImage *originalImage = [ws.photoGroup synchronousGetImage:photoAsset thumb:NO];
            UIImage *thumbImage = [ws.photoGroup synchronousGetImage:photoAsset thumb:YES];
            NSLog(@"originalImage:%@, thumbImage:%@", originalImage, thumbImage);
            
            // async
            [ws.photoGroup asynchronousGetImage:photoAsset thumb:NO completeCb:^(UIImage *image) {
                NSLog(@"单独获取:originalImage:%@", image);
            }];
            [ws.photoGroup asynchronousGetImage:photoAsset thumb:YES completeCb:^(UIImage *image) {
                NSLog(@"单独获取:thumbImage:%@", image);
            }];
            [ws.photoGroup asynchronousGetImage:photoAsset completeCb:^(UIImage *originalImage, UIImage *thumbImage) {
                NSLog(@"一起获取:originalImage:%@,thumbImage:%@", originalImage, thumbImage);
            }];
        }
        
    };
    
    
    UINavigationController *photoGroupNav = [[UINavigationController alloc] initWithRootViewController:self.photoGroup];
    [self presentViewController:photoGroupNav animated:YES completion:nil];
}




@end
