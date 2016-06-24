//
//  ViewController.m
//  Example
//
//  Created by 曾维俊 on 16/5/13.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "ViewController.h"
#import "WJPhotoPickerController.h"

@interface ViewController ()
@property (strong, nonatomic) WJPhotoPickerController *photoPicker;

@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *assets;

- (IBAction)openAlbum:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
}

- (IBAction)openAlbum:(id)sender {
    
    if (!_photoPicker) _photoPicker = [[WJPhotoPickerController alloc] initWithCompletedCallback:^(WJPhotoPickerController *picker, NSArray<WJPhotoAsset *> *seletedAssets) {
        
        NSLog(@"seletedAssetsCount:%zd", seletedAssets.count);
        NSLog(@"seletedAssets:%@", seletedAssets);
        
        for (WJPhotoAsset *photoAsset in seletedAssets) {
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
        }
    }];
    
    
    NSInteger maxCount = 9;
    _photoPicker.mediaType = WJPhotoMediaTypeAll;
    _photoPicker.maxCount = maxCount - self.images.count;
    
    UINavigationController *photoGroupNav = [[UINavigationController alloc] initWithRootViewController:self.photoPicker];
    [self presentViewController:photoGroupNav animated:YES completion:nil];
}

@end
