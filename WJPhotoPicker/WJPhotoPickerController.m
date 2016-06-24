//
//  WJPhotoPickerController.m
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhotoPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "WJPhotoGridController.h"
#import "WJPhotoGroup.h"
#import "WJPhotoGroupCell.h"
#import <AVFoundation/AVFoundation.h>

@interface WJPhotoPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    BOOL unInit;
}


#if NOT_iOS8
@property (strong, nonatomic) ALAssetsLibrary *library;
#endif

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray  *groups;
@property (strong, nonatomic) WJPhotoGridController *gridVc;

@end

@implementation WJPhotoPickerController

- (instancetype)init {
    if (self = [super init]) {
        _mediaType = WJPhotoMediaTypeAll;
        _selectionMode = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneBtnCallback) name:WJPhotoPickerDoneButtonClicked object:nil];
        [self loadAssets];
    }
    return self;
}

- (instancetype)initWithCompletedCallback:(CompletedCallback)completedCallback {
    if (self = [self init]) {
        self.completedCallback = completedCallback;
    }
    return self;
}

- (void)viewDidLoad {
    // Add Nav
    [self setNavBarItem];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Setup table view
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.rowHeight = 100;
    [tableView registerClass:[WJPhotoGroupCell class] forCellReuseIdentifier:@"WJPhotoGroupCell"];
    
    // AutoLayout.
    NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:views]];
    
    // Super
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    WJLog(@"%s", __func__);
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    WJLog(@"%s", __func__);
}

- (void)doneBtnCallback {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.completedCallback) self.completedCallback(self, self.gridVc.seletedAssets);
}

#pragma mark - Load data
- (void)setMaxCount:(NSInteger)maxCount {
    _maxCount = maxCount;
    if (!unInit) {
        unInit = YES;
    } else {
        [self performLoadAssets];
    }
}

// Load assets from photos library or assets library
- (void)loadAssets {
    if (NSClassFromString(iOS8_PHAsset)) {
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        } else {
            // Prompt open photo album access permissions
        }
    } else {
        // Assets library
        [self performLoadAssets];
    }
}

- (void)performLoadAssets {
    
    // Initialise
    __block NSMutableArray *groups = [NSMutableArray array];
    
    // Load
#if iOS8
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Load albums and asset
        // Get albums
        
        //Get max count group
        __block NSUInteger maxCount = 0;
        __block WJPhotoGroup *maxCountsGroup = nil;
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum  subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL *stop) {
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
            PHAsset *asset = result.firstObject;
            switch (_mediaType) {
                case WJPhotoMediaTypePhoto:
                    if (asset.mediaType != PHAssetMediaTypeImage) result = nil;
                    break;
                case WJPhotoMediaTypeVideo:
                    if (asset.mediaType != PHAssetMediaTypeVideo) result = nil;
                    break;
                case WJPhotoMediaTypeAll:
                    break;
            }
            
            if (result && result.count) {
                WJPhotoGroup *wGroup = [[WJPhotoGroup alloc] init];
                wGroup.caption = obj.localizedTitle;
                wGroup.count = result.count;
                wGroup.assets = obj;
                [groups addObject:wGroup];
                if (result.count > maxCount) {
                    maxCount = result.count;
                    maxCountsGroup = wGroup;
                }
            }
        }];
        
        if (maxCountsGroup) {
            [groups removeObject:maxCountsGroup];
            [groups insertObject:maxCountsGroup atIndex:0];
        }
        
        _groups = groups;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self toPhotoGridVc:0 animation:NO];
        });
    });
    
#else
    _library = [ALAssetsLibrary new];
    // Run in backgroud as it takes a while
    // to get all assets from library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            switch (_mediaType) {
                case WJPhotoMediaTypePhoto:[group setAssetsFilter:[ALAssetsFilter allPhotos]];break;
                case WJPhotoMediaTypeVideo:[group setAssetsFilter:[ALAssetsFilter allVideos]];break;
                case WJPhotoMediaTypeAll:[group setAssetsFilter:[ALAssetsFilter allAssets]];break;
            }
            if (group != nil) {
                @synchronized(groups) {
                    if (group.numberOfAssets) {
                        WJPhotoGroup *wGroup = [[WJPhotoGroup alloc] init];
                        wGroup.caption = [group valueForProperty:ALAssetsGroupPropertyName];
                        wGroup.count = group.numberOfAssets;
                        wGroup.assets = group;
                        [groups addObject:wGroup];
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _groups = [NSMutableArray arrayWithArray:[[groups reverseObjectEnumerator] allObjects]];
                    [self.tableView reloadData];
                    [self toPhotoGridVc:0 animation:NO];
                });
            }
        };
        [_library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {
            WJLog(@"get assets from library error:%@", error);
        }];
        
        /*
         Enumerator two steps
         First ..
         NSUInteger type = ALAssetsGroupSavedPhotos;
         [_library enumerateGroupsWithTypes:type usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {
         WJLog(@"get assets from library error:%@", error);
         }]
         
         Then ..
         NSUInteger type =
         ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
         ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
         
         [_library enumerateGroupsWithTypes:type usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {
         WJLog(@"get assets from library error:%@", error);
         }]
         */
        
        //            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
#endif
    
}


#pragma mark - table view datasource / delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WJPhotoGroup *group = _groups[indexPath.row];
    WJPhotoGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WJPhotoGroupCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.clipsToBounds = YES;
    cell.groupNameLabel.text = group.caption;
    cell.groupPicCountLabel.text = [NSString stringWithFormat:@"(%ld)",(long)group.count];
    
#if iOS8
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:group.assets options:nil];
    PHAsset *asset = result.lastObject;
    cell.groupImageView.image = [self imageWithPHAsset:asset thumb:YES];
#else
    cell.groupImageView.image = [UIImage imageWithCGImage:group.assets.posterImage];
#endif
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self toPhotoGridVc:indexPath.row animation:YES];
}


#pragma mark - nav button
- (void) setNavBarItem {
    // Set view controller title
    [self setTitle:@"相簿"];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClicked)];
    self.navigationItem.rightBarButtonItem = cancelBtn;
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{
//                                                                      NSForegroundColorAttributeName:
//                                                                          [UIColor greenColor]}];
    [self.navigationController.navigationBar setTintColor:WJPhotoPickerDoneColor];
}

- (void) cancelBtnClicked {[self dismissViewControllerAnimated:YES completion:nil];}

- (void) toPhotoGridVc:(NSInteger)rows animation:(BOOL)animation {
    NSInteger value = self.groups.count-1;
    if ((value < 0) || (value < rows)) return;
    WJPhotoGroup *group = self.groups[rows];
    if (_gridVc == nil) _gridVc = [[WJPhotoGridController alloc] init];
    _gridVc.group = group;
    _gridVc.maxCount = self.maxCount;
    _gridVc.title = group.caption;
    _gridVc.selectionMode = _selectionMode;
    _gridVc.groupController = self;
    _gridVc.mediaType = self.mediaType;
    [self.navigationController pushViewController:_gridVc animated:animation];
}


#pragma mark - Helper -------------------------------
- (UIImage *)synchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb {
#if iOS8
    return [self imageWithPHAsset:photoAsset.asset thumb:thumb];
#else
    return [self imageWithALAsset:photoAsset.asset thumb:thumb];
#endif
}

- (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb completeCb:(void(^)(UIImage *image))completeCb {
#if iOS8
    [self asyncImageWithPHAsset:photoAsset.asset thumb:thumb completeCb:completeCb];
#else
    [self asyncImageWithALAsset:photoAsset.asset thumb:thumb completeCb:completeCb];
#endif
}

- (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset completeCb:(void(^)(UIImage *originalImage, UIImage *thumbImage))completeCb {
#if iOS8
    __weak __typeof(&*self) wself = self;
    [self asyncImageWithPHAsset:photoAsset.asset thumb:YES completeCb:^(UIImage *tImage) {
        __strong __typeof(&*wself) sself = wself;
        [sself asyncImageWithPHAsset:photoAsset.asset thumb:NO completeCb:^(UIImage *oImage) {
            if (completeCb) completeCb(oImage, tImage);
        }];
    }];
#else
    __weak __typeof(&*self) wself = self;
    [self asyncImageWithALAsset:photoAsset.asset thumb:YES completeCb:^(UIImage *tImage) {
        __strong __typeof(&*wself) sself = wself;
        [sself asyncImageWithALAsset:photoAsset.asset thumb:NO completeCb:^(UIImage *oImage) {
            if (completeCb) completeCb(oImage, tImage);
        }];
    }];
#endif
}

- (void)getVideoURLFromAsset:(WJPhotoAsset *)asset completeCb:(void (^)(NSURL *videURL))completeCb {
#if iOS8
    [self getVideoURLFromPHAsset:asset.asset completeCb:completeCb];
#else
    [self getVideoURLFromALAsset:asset.asset completeCb:completeCb];
#endif
}

- (void)exportVideoFileFromAsset:(WJPhotoAsset *)asset filePath:(NSString *)filePath completeCb:(void (^)(NSString *errStr))completeCb {
#if iOS8
    [self exportVideoFileFromPHAsset:asset.asset filePath:filePath completeCb:completeCb];
#else
    [self exportVideoFileFromALAsset:asset.asset filePath:filePath completeCb:completeCb];
#endif
}

- (void)exportVideoFileFromAsset:(WJPhotoAsset *)asset filePath:(NSString *)filePath presetName:(NSString *)presetName completeCb:(void (^)(NSString *errStr))completeCb {
#if iOS8
    [self exportVideoFileFromPHAsset:asset.asset filePath:filePath presetName:presetName completeCb:completeCb];
#else
    [self exportVideoFileFromALAsset:asset.asset filePath:filePath presetName:presetName completeCb:completeCb];
#endif
}

#if iOS8
- (PHImageRequestOptions *)optionsSynchronous:(BOOL)synchronous {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.synchronous = synchronous;
    return options;
}

- (UIImage *)imageWithPHAsset:(PHAsset *)asset thumb:(BOOL)thumb {
    PHImageManager *imgMgr = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [self optionsSynchronous:YES];
    options.networkAccessAllowed = NO;
    __block UIImage *image = nil;
    [imgMgr requestImageForAsset:asset targetSize:thumb?thumbTargetSize(4):imageTargetSize() contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        image = result;
    }];
    return image;
}



- (void)asyncImageWithPHAsset:(PHAsset *)asset thumb:(BOOL)thumb completeCb:(void(^)(UIImage *image))completeCb {
    PHImageManager *imgMgr = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [self optionsSynchronous:NO];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    };
    [imgMgr requestImageForAsset:asset targetSize:thumb?thumbTargetSize(4):imageTargetSize() contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeCb) completeCb(result);
        });
    }];
}

- (void)getVideoURLFromPHAsset:(PHAsset *)asset completeCb:(void (^)(NSURL *videURL))completeCb {
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.networkAccessAllowed = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *assetd, AVAudioMix *audioMix, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([assetd isKindOfClass:[AVURLAsset class]]) {
                    if (completeCb) completeCb(((AVURLAsset *)assetd).URL);
                } else {
                    if (completeCb) completeCb(nil);
                }
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeCb) completeCb(nil);
        });
    }
}

- (void)exportVideoFileFromPHAsset:(PHAsset *)asset filePath:(NSString *)filePath presetName:(NSString *)presetName completeCb:(void (^)(NSString *errStr))completeCb {
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.networkAccessAllowed = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        __weak __typeof(&*self) wself = self;
        [[PHImageManager defaultManager] requestExportSessionForVideo:asset options:options exportPreset:presetName resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
            __strong __typeof(&*wself) sself = wself;
            [sself export:exportSession filePath:filePath completeCb:completeCb];
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeCb) completeCb(nil);
        });
    }
}

- (void)exportVideoFileFromPHAsset:(PHAsset *)asset filePath:(NSString *)filePath completeCb:(void (^)(NSString *errStr))completeCb {
    [self exportVideoFileFromPHAsset:asset filePath:filePath presetName:AVAssetExportPresetHighestQuality completeCb:completeCb];
}


#else

- (UIImage *)imageWithALAsset:(ALAsset *)asset thumb:(BOOL)thumb {
    return [UIImage imageWithCGImage:thumb?asset.thumbnail:asset.defaultRepresentation.fullScreenImage];
}

- (void)asyncImageWithALAsset:(ALAsset *)asset thumb:(BOOL)thumb completeCb:(void(^)(UIImage *image))completeCb {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            if (thumb) {
                UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completeCb) completeCb(image);
                });
            } else {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                [assetsLibrary assetForURL:asset.defaultRepresentation.url resultBlock:^(ALAsset *asset) {
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completeCb) completeCb(image);
                    });
                } failureBlock:^(NSError *error) {
                }];
            }
        }
    });
}

- (void)getVideoURLFromALAsset:(ALAsset *)asset completeCb:(void (^)(NSURL *videURL))completeCb {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeCb) completeCb(representation.url);
        });
    });
}

- (void)exportVideoFileFromALAsset:(ALAsset *)asset filePath:(NSString *)filePath presetName:(NSString *)presetName completeCb:(void (^)(NSString *errStr))completeCb {
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    AVAsset *avAsset = [AVAsset assetWithURL:representation.url];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:avAsset presetName:presetName];
    [self export:exportSession filePath:filePath completeCb:completeCb];
    
    /**
     ALAssetRepresentation *rep = [asset defaultRepresentation];
     const char *cvideoPath = [filePath UTF8String];
     FILE *file = fopen(cvideoPath, "a+");
     if (file) {
     const int bufferSize = 11024 * 1024;
     // 初始化一个1M的buffer
     Byte *buffer = (Byte*)malloc(bufferSize);
     NSUInteger read = 0, offset = 0, written = 0;
     NSError* err = nil;
     if (rep.size != 0)
     {
     do {
     read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
     written = fwrite(buffer, sizeof(char), read, file);
     offset += read;
     } while (read != 0 && !err);//没到结尾，没出错，ok继续
     }
     // 释放缓冲区，关闭文件
     free(buffer);
     buffer = NULL;
     fclose(file);
     file = NULL;
     
     // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
     dispatch_async(dispatch_get_main_queue(), ^{
     if (completeCb) completeCb(nil);
     });
     } */
}

- (void)exportVideoFileFromALAsset:(ALAsset *)asset filePath:(NSString *)filePath completeCb:(void (^)(NSString *errStr))completeCb {
    [self exportVideoFileFromALAsset:asset filePath:filePath presetName:AVAssetExportPresetHighestQuality completeCb:completeCb];
}

#endif

- (void)export:(AVAssetExportSession *)exportSession filePath:(NSString *)filePath completeCb:(void (^)(NSString *errStr))completeCb {
    exportSession.outputURL = [NSURL fileURLWithPath:filePath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown:
                    if (completeCb) completeCb(@"AVAssetExportSessionStatusUnknown");
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                    break;
                    
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                    break;
                    
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting");
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                    if (completeCb) completeCb(nil);
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    break;
                    
                case AVAssetExportSessionStatusFailed:
                    if (completeCb) completeCb(@"AVAssetExportSessionStatusFailed");
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    if (completeCb) completeCb(@"AVAssetExportSessionStatusCancelled");
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    break;
            }
        });
    }];
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self performLayout];
}

- (void)performLayout {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    self.tableView.contentInset = UIEdgeInsetsMake(navBar.frame.origin.y + navBar.frame.size.height + 0, 0, 0, 0);
}


@end
