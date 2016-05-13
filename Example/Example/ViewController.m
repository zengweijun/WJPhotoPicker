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
    self.photoGroup.doneCallback = ^(NSArray *seletedPhotos) {
       
        // 这里返回当前选择的照片
        NSLog(@"seletedPhotos:%@", seletedPhotos);
        
        // 添加到self.photos
    };
    UINavigationController *photoGroupNav = [[UINavigationController alloc] initWithRootViewController:self.photoGroup];
    [self presentViewController:photoGroupNav animated:YES completion:nil];
}




@end
