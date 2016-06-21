//
//  WJPhotoGroupController.m
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhotoGroupController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "WJPhotoGridController.h"
#import "WJPhotoGroup.h"
#import "WJPhotoGroupCell.h"

@interface WJPhotoGroupController ()<UITableViewDataSource,UITableViewDelegate> {
    BOOL unInit;
}

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSMutableArray  *groups;

@property (strong, nonatomic) WJPhotoGridController *gridVc;
@end

@implementation WJPhotoGroupController

- (instancetype)init {
    if (self = [super init]) {
        _mediaType = WJPhotoMediaTypeAll;
        _selectionMode = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneBtnCallback) name:WJPhotoPickerDoneButtonClicked object:nil];
        [self loadAssets];
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
    if (self.completedCallback) self.completedCallback(self.gridVc.seletedAssets);
    if (self.doneCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *images = [NSMutableArray array];
            for (WJPhotoAsset *photoAsset in self.gridVc.seletedAssets) {
                UIImage *image = [self synchronousGetImage:photoAsset thumb:NO];
                if (image) [images addObject:image];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.doneCallback(images);
            });
        });
    }
}

- (UIImage *)synchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb {
    if (photoAsset.aAsset) return [UIImage imageWithCGImage:thumb?photoAsset.aAsset.thumbnail:photoAsset.aAsset.defaultRepresentation.fullScreenImage];
    
    if (photoAsset.pAsset) {
        PHImageManager *imgMgr = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [self optionsSynchronous:YES];
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {};
        __block UIImage *image = nil;
        [imgMgr requestImageForAsset:photoAsset.pAsset targetSize:thumb?thumbTargetSize(2):imageTargetSize() contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            image = result;
        }];
        return image;
    }
    return nil;
}

- (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset thumb:(BOOL)thumb completeCb:(void(^)(UIImage *image))completeCb {
    if (photoAsset.aAsset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                if (thumb) {
                    UIImage *image = [UIImage imageWithCGImage:photoAsset.aAsset.thumbnail];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completeCb) completeCb(image);
                    });
                } else {
                    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                    [assetsLibrary assetForURL:photoAsset.aAsset.defaultRepresentation.url resultBlock:^(ALAsset *asset) {
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
    } else if (photoAsset.pAsset) {
        PHImageManager *imgMgr = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [self optionsSynchronous:NO];
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {};
        [imgMgr requestImageForAsset:photoAsset.pAsset targetSize:thumb?thumbTargetSize(2):imageTargetSize() contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            // there is not error status
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completeCb) completeCb(result);
            });
        }];
    }
}

- (void)asynchronousGetImage:(WJPhotoAsset *)photoAsset completeCb:(void(^)(UIImage *originalImage, UIImage *thumbImage))completeCb {
    if (photoAsset.aAsset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                UIImage *tImage = [UIImage imageWithCGImage:photoAsset.aAsset.thumbnail];
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                [assetsLibrary assetForURL:photoAsset.aAsset.defaultRepresentation.url resultBlock:^(ALAsset *asset) {
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    UIImage *oImage = [UIImage imageWithCGImage:iref];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completeCb) completeCb(oImage, tImage);
                    });
                } failureBlock:^(NSError *error) {
                    if (completeCb) completeCb(nil, nil);
                }];
            }
        });
    } else if (photoAsset.pAsset) {
        PHImageManager *imgMgr = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [self optionsSynchronous:YES];
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {};
        __block UIImage *tImage = nil;
        [imgMgr requestImageForAsset:photoAsset.pAsset targetSize:thumbTargetSize(2) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            tImage = result;
        }];
        
        options.synchronous = NO;
        [imgMgr requestImageForAsset:photoAsset.pAsset targetSize:imageTargetSize() contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (completeCb) completeCb(result, tImage);
        }];
    }
}

- (PHImageRequestOptions *)optionsSynchronous:(BOOL)synchronous {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = synchronous;
    return options;
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
    if (NSClassFromString(iOS8_PHAsset)) {
        
        /*
        // Target size
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat scale = screen.scale;
        // Sizing is very rough... more thought required in a real implementation
        CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
        CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
        CGSize thumbTargetSize = CGSizeMake(imageSize / 4.0 * scale, imageSize / 4.0 * scale);
        */
        
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Load albums and asset
            // Get albums
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum  subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL *stop) {
                WJPhotoGroup *wGroup = [WJPhotoGroup photoGroupAssetCollection:obj];
                if (wGroup) {
                    [groups addObject:wGroup];
                }
            }];
            _groups = groups;
            dispatch_async(dispatch_get_main_queue(), ^{
               [self.tableView reloadData];
               [self toPhotoGridVc:0 animation:NO];
            });
        });
    } else {
        // Assets Library iOS < 8
        _library = [ALAssetsLibrary new];
        // Run in backgroud as it takes a while
        // to get all assets from library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group != nil) {
                    @synchronized(groups) {
                        WJPhotoGroup *wGroup = [WJPhotoGroup photoGroupWithAssetsGroup:group];
                        if (wGroup) {
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
    }
}


#pragma mark - table view datasource / delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WJPhotoGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WJPhotoGroupCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    WJPhotoGroup *group = _groups[indexPath.row];
    cell.group = group;
    UIImage *img = [WJPhotoGroup imageForPhoto:group];
    if (img) {
        [cell displayImage];
    } else {
        [group loadUnderlyingImageAndNotify];
    }
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

- (void) cancelBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) toPhotoGridVc:(NSInteger)rows animation:(BOOL)animation {
    NSInteger value = self.groups.count-1;
    if ((value < 0) || (value < rows)) return;
    WJPhotoGroup *group = self.groups[rows];
    if (_gridVc == nil) _gridVc = [[WJPhotoGridController alloc] init];
    _gridVc.group = group;
    _gridVc.maxCount = self.maxCount;
    _gridVc.title = group.caption;
    _gridVc.selectionMode = _selectionMode;
    [self.navigationController pushViewController:_gridVc animated:animation];
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
