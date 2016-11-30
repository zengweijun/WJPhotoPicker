//
//  WJAssetsController.m
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhotoGridController.h"
#import "WJPhotoGroup.h"
#import "WJPhotoAsset.h"
#import "WJPhotoGridCell.h"
#import "WJPhotoDisplayController.h"
#import "WJPhotoDisplayToolbar.h"
#import "WJVideoDisplayController.h"

@interface WJPhotoGridController ()<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) WJPhotoDisplayToolbar   *toolBar;

@property (strong, nonatomic) NSMutableArray *thumbs;

@end

@implementation WJPhotoGridController
- (instancetype)init {
    if (self = [super init]) {
        _mediaType = WJPhotoMediaTypeAll;
        _seletedAssets = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Add nav bar
    [self addNavBarCancelButton];
    
    // Setup collection view
    [self createCollectionView];
    
    // Add tool bar
    [self setupToolBar];
    
    // Prepare data
    // [self prepareData];
    
    // Super
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    WJLog(@"%s", __func__);
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    WJLog(@"%s", __func__);
}

- (void) addNavBarCancelButton{
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClicked)];
    self.navigationItem.rightBarButtonItem = cancelBtn;
}

#pragma mark -初始化底部ToolBar
- (void) setupToolBar{
    WJPhotoDisplayToolbar *toolBar = [[WJPhotoDisplayToolbar alloc] initWithSeletedAssets:self.seletedAssets callback:NULL];
    [self.view addSubview:toolBar];
    toolBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(toolBar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolBar]-0-|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar(44)]-0-|" options:0 metrics:0 views:views]];
    self.toolBar = toolBar;
}

- (void) cancelBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collection view
- (void) createCollectionView {
    
    // Setup collection view
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumInteritemSpacing = PADDING;
    flow.minimumLineSpacing = PADDING;
    CGFloat itemWH = floor((self.view.bounds.size.width - 5 * PADDING) / 4);
    flow.itemSize = CGSizeMake(itemWH, itemWH);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.alwaysBounceVertical = YES;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|" options:0 metrics:nil views:views]];
    [collectionView registerClass:[WJPhotoGridCell class] forCellWithReuseIdentifier:@"WJPhotoGridCell"];
}

#pragma mark - Load data
- (void)setGroup:(WJPhotoGroup *)group {
    _group = group;
    
    // Clear selected buttonselected status
    NSArray *visibleIndexPaths = [_collectionView indexPathsForVisibleItems];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        WJPhotoGridCell *cell = (WJPhotoGridCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        cell.selectedButton.selected = NO;
    }
    
    // Clear selectedAssets
    if (_seletedAssets == nil) {
        _seletedAssets = [NSMutableArray array];
    } else {
        [_seletedAssets removeAllObjects];
    }
    
    [self.toolBar update];
    
    // Prepare data
    [self prepareData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)prepareData {
    // Initialise
    NSMutableArray *thumbs = [NSMutableArray array];
#if iOS8
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self.group.assets options:options];
        [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
            WJPhotoAsset *photoAsset = [[WJPhotoAsset alloc] init];
            photoAsset.asset = obj;
            switch (_mediaType) {
                case WJPhotoMediaTypePhoto:
                    if (obj.mediaType == PHAssetMediaTypeImage)
                        [thumbs addObject:photoAsset];
                    break;
                case WJPhotoMediaTypeVideo:
                    if (obj.mediaType == PHAssetMediaTypeVideo)
                        [thumbs addObject:photoAsset];
                    break;
                case WJPhotoMediaTypeAll:
                    [thumbs addObject:photoAsset];
                    break;
                default:
                    break;
            }
        }];
        _thumbs = thumbs;
        [self reloadData];
    });
    
#else
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.group.assets enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                if ([assetType isEqualToString:ALAssetTypePhoto] || [assetType isEqualToString:ALAssetTypeVideo]) {
                    WJPhotoAsset *photoAsset = [[WJPhotoAsset alloc] init];
                    photoAsset.asset = result;
                    @synchronized(thumbs) {
                        switch (_mediaType) {
                            case WJPhotoMediaTypePhoto:
                                if ([assetType isEqualToString:ALAssetTypePhoto])
                                    [thumbs addObject:photoAsset];
                                break;
                            case WJPhotoMediaTypeVideo:
                                if ([assetType isEqualToString:ALAssetTypeVideo]) {
                                    photoAsset.video = YES;
                                    [thumbs addObject:photoAsset];
                                }
                                break;
                            case WJPhotoMediaTypeAll: {
                                if ([assetType isEqualToString:ALAssetTypeVideo]) {
                                    photoAsset.video = YES;
                                } else {
                                    photoAsset.video = NO;
                                }
                                [thumbs addObject:photoAsset];
                            };
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }];
        _thumbs = [NSMutableArray arrayWithArray:[[thumbs reverseObjectEnumerator] allObjects]];
        [self reloadData];
    });
    
#endif
}

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self isViewLoaded]) {
            return;
        }
        if (_thumbs.count == 0) {
            [self showNotAssets];
        } else {
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_thumbs.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
    });
}

- (void)showNotAssets {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该相册没有资源" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - collectino view datasource / delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WJPhotoAsset *photoAsset = self.thumbs[indexPath.item];
    WJPhotoGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WJPhotoGridCell" forIndexPath:indexPath];
    cell.photoAsset = photoAsset;
    cell.selectionMode = _selectionMode;
    __weak __typeof(&*cell) wcell = cell;
    [self.groupController asynchronousGetImage:photoAsset thumb:YES completeCb:^(UIImage *image) {
        __weak __typeof(&*wcell) scell = wcell;
        [scell displayImage:image];
    }];
    cell.gridController = self;
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(PADDING, PADDING, PADDING + self.toolBar.bounds.size.height, PADDING);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    WJPhotoAsset *photoAsset = _thumbs[indexPath.item];
    if (photoAsset.isVideo) {
        WJVideoDisplayController *videoDisplayViewController = [[WJVideoDisplayController alloc] init];
        videoDisplayViewController.photoAsset = photoAsset;
        videoDisplayViewController.gridController = self;
        [self.navigationController pushViewController:videoDisplayViewController animated:YES];
        return;
    }
    WJPhotoDisplayController *photoDisplayViewController = [[WJPhotoDisplayController alloc] init];
    photoDisplayViewController.index = indexPath.item;
    photoDisplayViewController.thumbs = self.thumbs;
    photoDisplayViewController.gridViewController = self;
    __weak __typeof(&*self) wself = self;
    photoDisplayViewController.popCompleted = ^ {
        __strong __typeof(&*wself) sself = wself;
        [sself.collectionView reloadData];
    };
    [self.navigationController pushViewController:photoDisplayViewController animated:YES];
}


#pragma mark - Selection Button Pressed
- (void)selectionButtonPressed:(UIButton *)seletedButton photoAsset:(WJPhotoAsset *)photoAsset {
#if iOS8
    PHAsset *asset = photoAsset.asset;
    if (![self isPhotoInLocalAblum:asset]) {
        UIAlertAction *acion = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:NULL];
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"该照片原件存在iCloud，请前往“照片”应用中同步到本地后，再尝试发送" preferredStyle:UIAlertControllerStyleAlert];
        [alertVc addAction:acion];
        [self presentViewController:alertVc animated:YES completion:NULL];
        return;
    }
#endif
    
    if (!seletedButton.isSelected && self.seletedAssets.count >= self.maxCount) {
        NSString *message = [NSString stringWithFormat:@"你最多只能选择%zd张照片", self.maxCount];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    photoAsset.selected = !photoAsset.selected;
    seletedButton.selected = photoAsset.selected;
    
    if (seletedButton.isSelected) {
        if (![self.seletedAssets containsObject:photoAsset]) [self.seletedAssets addObject:photoAsset];
    } else {
        if ([self.seletedAssets containsObject:photoAsset]) [self.seletedAssets removeObject:photoAsset];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WJPhotoGridCellSeletedButtonDidChage object:nil];
}

- (BOOL)isPhotoInLocalAblum:(PHAsset *)asset {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    __block BOOL isInLocalAblum = YES;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
    }];
    return isInLocalAblum;
}

@end
