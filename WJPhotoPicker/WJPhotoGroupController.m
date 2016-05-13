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
    if (self.doneCallback) {
        self.doneCallback(self.gridVc.selectedPhotos);
    }
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
