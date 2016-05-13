//
//  WJPhotoGridCell.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 15/12/30.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhotoGridCell.h"
#import "WJPhotoCommon.h"
#import "UIImage+WJPhoto.h"
#import "DACircularProgressView.h"
#import "WJPhotoAsset.h"
#import "WJPhotoGridController.h"
#import <objc/runtime.h>

static char WJPhotoAssetKey;
#define VIDEO_INDICATOR_PADDING 10

@interface WJPhotoGridCell() {
    UIImageView *_imageView;
    UIImageView *_videoIndicator;
    UIImageView *_loadingError;
    DACircularProgressView *_loadingIndicator;
}

@end

@implementation WJPhotoGridCell

#pragma mark - Init
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commitInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    
    // Grey background
    self.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.];
    
    // Image
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = self.bounds;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
    [self addSubview:_imageView];
    
    
    // Video Image
    UIImage *videoIndicatorImage = [UIImage imageForResourcePath:@"WJPhotoAssets.bundle/VideoOverlay"
                                                          ofType:@"png"
                                                        inBundle:[NSBundle bundleForClass:[self class]]];
    _videoIndicator = [[UIImageView alloc] init];
    _videoIndicator.frame = CGRectMake(self.bounds.size.width - videoIndicatorImage.size.width - VIDEO_INDICATOR_PADDING, self.bounds.size.height - videoIndicatorImage.size.height - VIDEO_INDICATOR_PADDING, videoIndicatorImage.size.width, videoIndicatorImage.size.height);
    _videoIndicator.image = videoIndicatorImage;
    _videoIndicator.autoresizesSubviews = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    _videoIndicator.hidden = NO;
    [self addSubview:_videoIndicator];
    
    // Selection Button
    UIButton *selectedButton = [[UIButton alloc] init];
    [self setSelectedButton:selectedButton];
    _selectedButton.contentMode = UIViewContentModeTopRight;
    _selectedButton.adjustsImageWhenHighlighted = NO;
    [_selectedButton setImage:[UIImage imageForResourcePath:@"WJPhotoAssets.bundle/ImageSelectedSmallOff" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
    [_selectedButton setImage:[UIImage imageForResourcePath:@"WJPhotoAssets.bundle/ImageSelectedSmallOn" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateSelected];
    [_selectedButton addTarget:self action:@selector(selectionButtonPressed) forControlEvents:UIControlEventTouchDown];
    _selectedButton.frame = CGRectMake(0, 0, 44, 44);
    _selectedButton.hidden = YES;
    [self addSubview:_selectedButton];
    
    // Loading indicator
    _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 40.0f)];
    _loadingIndicator.userInteractionEnabled = NO;
    _loadingIndicator.thicknessRatio = 0.1;
    _loadingIndicator.roundedCorners = NO;
    [self addSubview:_loadingIndicator];
    
    // Listen for photo loading notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setProgressFromNotification:)
                                                 name:WJPHOTO_LOADING_PROGRESS_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                 name:WJPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View
- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2), _loadingIndicator.frame.size.width,
                                         _loadingIndicator.frame.size.height);
    _selectedButton.frame = CGRectMake(self.bounds.size.width - _selectedButton.frame.size.width - 0,
                                       0, _selectedButton.frame.size.width, _selectedButton.frame.size.height);
}

#pragma mark - Cell reuse
- (void)prepareForReuse {
    _photoAsset = nil;
    _imageView.image = nil;
    _loadingIndicator.progress = 0;
    _selectedButton.hidden = YES;
    [self hideImageFailure];
    [super prepareForReuse];
}

#pragma mark - Image handling

- (void)setPhotoAsset:(WJPhotoAsset *)photoAsset {
    _photoAsset = photoAsset;
    _selectedButton.selected = photoAsset.selected;
    
    if ([photoAsset respondsToSelector:@selector(isVideo)]) {
        _videoIndicator.hidden = !photoAsset.isVideo;
    } else {
        _videoIndicator.hidden = YES;
    }
    if (_photoAsset) {
        if ([_photoAsset underlyingImage]) {
            [self hideLoadingIndictor];
        } else {
            [self showLoadingIndictor];
        }
    } else {
        [self showImageFailure];
    }
}

- (void)displayImage {
    _imageView.image = [_photoAsset underlyingImage];
    [self hideImageFailure];
}

- (void)setSelectionMode:(BOOL)selectionMode {
    _selectionMode = selectionMode;
    _selectedButton.hidden = !selectionMode;
}

#pragma mark - Indictors
- (void)showLoadingIndictor {
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;
}

- (void)hideLoadingIndictor {
    _loadingIndicator.hidden = YES;
}

- (void)showImageFailure {
    // Only show if image is not empty
    if (![_photoAsset respondsToSelector:@selector(emptyImage)] || !_photoAsset.emptyImage) {
        if (!_loadingError) {
            _loadingError = [[UIImageView alloc] init];
            _loadingError.image = [UIImage imageForResourcePath:@"WJPhotoAssets.bundle/ImageError" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
            _loadingError.userInteractionEnabled = NO;
            [_loadingError sizeToFit];
            [self addSubview:_loadingError];
        }
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2.),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.width);
    }
    [self hideLoadingIndictor];
    _imageView.image = nil;
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 0.6;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _imageView.alpha = 1;
    [super touchesCancelled:touches withEvent:event];
}


#pragma mark - Notification
- (void)setProgressFromNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = [notification object];
        id <WJPhoto> photo = [dict objectForKey:@"photo"];
        if (photo == _photoAsset) {
            float progress = [[dict objectForKey:@"progress"] floatValue];
            _loadingIndicator.progress = MAX(MIN(1, progress), 0);
        }
    });
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <WJPhoto> photo = [notification object];
    if (photo == _photoAsset) {
        if ([photo underlyingImage]) {
            [self displayImage];
        } else {
            [self showImageFailure];
        }
        [self hideLoadingIndictor];
    }
}

#pragma mark - Action
- (void)selectionButtonPressed {
    if (!_selectedButton.isSelected && _gridController.selectedPhotos.count >= _gridController.maxCount) {
        NSString *message = [NSString stringWithFormat:@"你最多只能选择%zd张照片", _gridController.maxCount];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    _photoAsset.selected = !_photoAsset.selected;
    _selectedButton.selected = _photoAsset.selected;
    id<WJPhoto> bigPhoto = [self bigPhoto];
    if (_selectedButton.selected) {
        if (![_gridController.selectedPhotos containsObject:bigPhoto]) {
            [_gridController.selectedPhotos addObject:bigPhoto];
            [bigPhoto loadUnderlyingImageAndNotify];
        }
    } else {
        // id<WJPhoto> bigPhoto = [self bigPhoto]; 该方法会创建一个新的photo
        id<WJPhoto> bigPhoto = nil;
        for (id<WJPhoto> photo in _gridController.selectedPhotos) {
            WJPhotoAsset *pa = objc_getAssociatedObject(photo, &WJPhotoAssetKey);
            if ([pa isEqual:_photoAsset]) {
                bigPhoto = photo;
                break;
            }
        }
        if (bigPhoto) [_gridController.selectedPhotos removeObject:bigPhoto];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WJPhotoGridCellSeletedButtonDidChage object:nil];
}

- (id<WJPhoto>)bigPhoto {
    id<WJPhoto> photo = nil;
    WJPhotoAsset *photoAsset = self.photoAsset;
    if (photoAsset.aAsset) {
        photo = [WJPhoto photoWithURL:photoAsset.aAsset.defaultRepresentation.url];
    } else if (self.photoAsset.pAsset) {
        photo = [WJPhoto photoWithAsset:photoAsset.pAsset targetSize:imageTargetSize()];
    }
    objc_setAssociatedObject(photo, &WJPhotoAssetKey, photoAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return photo;
}

@end
