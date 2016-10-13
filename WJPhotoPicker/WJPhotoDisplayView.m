//
//  WJPhotoDisplayView.m
//  Example
//
//  Created by Nius on 2016/10/13.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJPhotoDisplayView.h"

@interface WJPhotoDisplayView()<
UIScrollViewDelegate
>
@property (nonatomic, weak) UIScrollView *zoomScrollView;

@end
static void *WJPhotoDisplayViewObserverImageViewKey = &WJPhotoDisplayViewObserverImageViewKey;
@implementation WJPhotoDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commitInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    self.doubleTapZoom = YES;
    
    UIScrollView *zoomScrollView = [[UIScrollView alloc] init];
    zoomScrollView.delegate = self;
    zoomScrollView.showsHorizontalScrollIndicator = NO;
    zoomScrollView.showsVerticalScrollIndicator = NO;
    zoomScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    zoomScrollView.backgroundColor = [UIColor clearColor];
    zoomScrollView.frame = self.bounds;
    zoomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //    zoomScrollView.alwaysBounceVertical = YES;
    [self addSubview:zoomScrollView];
    zoomScrollView.maximumZoomScale = 3;
    zoomScrollView.minimumZoomScale = 1;
    
    // Gesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [zoomScrollView addGestureRecognizer:singleTap];
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [zoomScrollView addGestureRecognizer:doubleTap];
    self.zoomScrollView = zoomScrollView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = zoomScrollView.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [zoomScrollView addSubview:imageView];
    [imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:WJPhotoDisplayViewObserverImageViewKey];
    self.imageView = imageView;
}

- (void)dealloc {
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(__unused NSDictionary *)change
                       context:(void *)context {
    if (context != WJPhotoDisplayViewObserverImageViewKey) {
        return;
    }
    
    CGSize  boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize  imageSize = self.imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    // In cass crash
    if (imageWidth == 0) imageWidth = 40.;
    if (imageHeight == 0) imageHeight = 40.;
    
    // The min scale / max scale
    CGFloat minScale = boundsWidth / imageWidth;
    if (minScale > 1.0) minScale = 1.0;
    CGFloat maxScale = 3;
    
    self.zoomScrollView.maximumZoomScale = maxScale;
    self.zoomScrollView.minimumZoomScale = minScale;
    self.zoomScrollView.zoomScale = minScale;
    
    CGRect imageRect = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    self.zoomScrollView.contentSize = CGSizeMake(boundsWidth, imageRect.size.height);
    
    // y值
    if (imageRect.size.height < boundsHeight) {
        imageRect.origin.y = floor((boundsHeight - imageRect.size.height) / 2.0);
    } else {
        imageRect.origin.y = 0;
    }
    
    self.imageView.frame = imageRect;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - LayoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // adjust image center
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect imageFrame = self.imageView.frame;
    
    // Horizontally
    if (imageFrame.size.width < boundsSize.width) {
        imageFrame.origin.x = floorf((boundsSize.width - imageFrame.size.width) / 2.0);
    } else {
        imageFrame.origin.x = 0;
    }
    
    // Vertically
    if (imageFrame.size.height < boundsSize.height) {
        imageFrame.origin.y = floorf((boundsSize.height - imageFrame.size.height) / 2.0);
    } else {
        imageFrame.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(self.imageView.frame, imageFrame))
        self.imageView.frame = imageFrame;
}

#pragma mark - Gesture Action
- (void)handleDoubleTap:(UITapGestureRecognizer *)gsr {
    if (!self.doubleTapZoom) {
        return;
    }
    
    if (self.zoomScrollView.zoomScale != self.zoomScrollView.minimumZoomScale) {
        [self.zoomScrollView setZoomScale:self.zoomScrollView.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale = (self.zoomScrollView.maximumZoomScale + self.zoomScrollView.minimumZoomScale) / 2;
        CGFloat xSize = self.bounds.size.width / newZoomScale;
        CGFloat ySize = self.bounds.size.height / newZoomScale;
        CGPoint touchPoint = [gsr locationInView:self.imageView];
        [self.zoomScrollView zoomToRect:CGRectMake(touchPoint.x - xSize / 2, touchPoint.y - ySize / 2, xSize, ySize) animated:YES];
    }
    !self.doubleTapCb?:self.doubleTapCb(self);
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gsr {
    !self.singleTapCb?:self.singleTapCb(self);
}


@end
