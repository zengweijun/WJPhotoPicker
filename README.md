# WJPhotoPicker
* An easy way to use Photo Picker
* 一款用法简单的可选择照片的相册

## Contents
* Getting Started
* [System 【iOS7+】]

## <a id="如何使用WJPhotoPicker"></a>如何使用WJPhotoBrowser
* cocoapods导入：`pod 'WJPhotoPicker'` 
* 手动导入：
* 将`WJPhotoPicker`文件夹中的所有文件拽入项目中
* 导入主头文件：`#import "WJPhotoGroupController.h"`


Example:(Please See The Demo)
Initialize:
    _photoGroup = [[WJPhotoGroupController alloc] init];
    _photoGroup.mediaType = WJPhotoMediaTypePhoto;

Select Photos:
- (IBAction)openAlbum:(id)sender {
    NSInteger maxCount = 9;
    self.photoGroup.maxCount = maxCount - self.photos.count;
    self.photoGroup.doneCallback = ^(NSArray *seletedPhotos) {

    // 这里返回当前选择的照片
    NSLog(@"seletedPhotos:%@", seletedPhotos);

    // 添加到self.photos
    };
    UINavigationController *photoGroupNav = [[UINavigationController alloc] initWithRootViewController:_photoGroup];
    [self presentViewController:photoGroupNav animated:YES completion:nil];
}

