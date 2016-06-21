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

@interface WJPhotoGridController ()<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIView          *toolBar;
@property (weak, nonatomic) UIButton        *sendBtn;

@property (strong, nonatomic) NSMutableArray *thumbs;

@end

@implementation WJPhotoGridController
- (instancetype)init {
    if (self = [super init]) {
        _mediaType = WJPhotoMediaTypeAll;
        _seletedAssets = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToolBar) name:WJPhotoGridCellSeletedButtonDidChage object:nil];
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
    UIView *toolBar = [[UIView alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    toolBar.backgroundColor = [UIColor colorWithWhite:1. alpha:0.99];
    [self.view addSubview:toolBar];
    NSDictionary *views = NSDictionaryOfVariableBindings(toolBar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolBar]-0-|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar(44)]-0-|" options:0 metrics:0 views:views]];
    self.toolBar = toolBar;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.alpha = 0.5;
    [toolBar addSubview:lineView];
    lineView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *lineViews = NSDictionaryOfVariableBindings(lineView);
    [toolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lineView]-0-|" options:0 metrics:nil views:lineViews]];
    [toolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lineView(0.5)]" options:0 metrics:nil views:lineViews]];
    
    // send button
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitleColor:WJPhotoPickerDoneColor forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    rightBtn.enabled = YES;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    NSString *title = [NSString stringWithFormat:@"完成(%d)",0];
    [rightBtn setTitle:title forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(sendBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.enabled = NO;
    [toolBar addSubview:rightBtn];
    self.sendBtn = rightBtn;
    // rightBtn.frame = CGRectMake(0, 0, 60, 45);
    rightBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *rightBtnViews = NSDictionaryOfVariableBindings(rightBtn);
    [self.toolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightBtn(60)]-10-|" options:0 metrics:nil views:rightBtnViews]];
    [self.toolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightBtn]-0-|" options:0 metrics:nil views:rightBtnViews]];
}

- (void) sendBtnTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:WJPhotoPickerDoneButtonClicked object:nil];
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
    
    [self updateToolBar];
    
    // Prepare data
    [self prepareData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)prepareData {
    // Initialise
    NSMutableArray *thumbs = [NSMutableArray array];
    if (self.group.assetCollection) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self.group.assetCollection options:options];
            [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
                WJPhotoAsset *photoAsset = [WJPhotoAsset photoWithAsset:obj targetSize:thumbTargetSize(COLUMNS)];
                photoAsset.pAsset = obj;
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
    } else if (self.group.assetsGroup) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.group.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto] || [assetType isEqualToString:ALAssetTypeVideo]) {
                        WJPhotoAsset *photoAsset = [WJPhotoAsset photoWithImage:[UIImage imageWithCGImage:result.thumbnail]];
                        photoAsset.aAsset = result;
                        @synchronized(thumbs) {
                            switch (_mediaType) {
                                case WJPhotoMediaTypePhoto:
                                    if ([assetType isEqualToString:ALAssetTypePhoto])
                                        [thumbs addObject:photoAsset];
                                    break;
                                case WJPhotoMediaTypeVideo:
                                    if ([assetType isEqualToString:ALAssetTypeVideo]) {
                                        photoAsset.isVideo = YES;
                                        [thumbs addObject:photoAsset];
                                    }
                                    break;
                                case WJPhotoMediaTypeAll: {
                                    if ([assetType isEqualToString:ALAssetTypeVideo]) {
                                        photoAsset.isVideo = YES;
                                    } else {
                                        photoAsset.isVideo = NO;
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
    }
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
    WJPhotoGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WJPhotoGridCell" forIndexPath:indexPath];
    WJPhotoAsset *photoAsset = _thumbs[indexPath.item];
    cell.photoAsset = photoAsset;
    cell.selectionMode = _selectionMode;
    UIImage *img = [WJPhotoAsset imageForPhoto:photoAsset];
    if (img) {
        [cell displayImage];
    } else {
        [photoAsset loadUnderlyingImageAndNotify];
    }
    cell.gridController = self;
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(PADDING, PADDING, PADDING + self.toolBar.bounds.size.height, PADDING);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    WJPhotoGridCell *cell = (WJPhotoGridCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell selectionButtonPressed];
//    [self showPhotoBrowser:indexPath.item sender:cell];
}

#pragma mark - Notification
- (void)updateToolBar {
    NSString *title = [NSString stringWithFormat:@"完成(%zd)", _seletedAssets.count];
    [self.sendBtn setTitle:title forState:UIControlStateNormal];
    if (_seletedAssets.count) {
        self.sendBtn.enabled = YES;
    } else {
        self.sendBtn.enabled = NO;
    }
}

#pragma mark - WJPhotoBrowserDelegate
- (void)showPhotoBrowser:(NSUInteger)currentIndex sender:(UIView *)view {
    WJPhotoAsset *photoAsset = self.thumbs[currentIndex];
    id<WJPhoto> photo = nil;
    if (photoAsset.aAsset) {
        photo = [WJPhoto photoWithURL:photoAsset.aAsset.defaultRepresentation.url];
    } else if (photoAsset.pAsset) {
        photo = [WJPhoto photoWithAsset:photoAsset.pAsset targetSize:imageTargetSize()];
    }
}

@end
