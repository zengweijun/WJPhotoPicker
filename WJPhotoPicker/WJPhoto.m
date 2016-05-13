//
//  WJPhoto.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 15/12/28.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhoto.h"
#import "SDWebImageOperation.h"
#import "SDWebImageManager.h"
#import "WJPhotoCommon.h"

@interface WJPhoto() {
    BOOL                    _loadingInProgress;
    id<SDWebImageOperation> _webImageOperation;
    PHImageRequestID        _assetRequestID;
}

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL   *photoURL;
@property (strong, nonatomic) PHAsset *asset;
@property (assign, nonatomic) CGSize  assetTargetSize;

- (void)imageLoadingComplete;

@end

@implementation WJPhoto
// synth property from protocol
@synthesize underlyingImage = _underlyingImage;

#pragma mark - Class Methods

+ (instancetype)photoWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

+ (instancetype)photoWithURL:(NSURL *)url{
    return [[self alloc] initWithURL:url];
}

+ (instancetype)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize{
    return [[self alloc] initWithAsset:asset targetSize:targetSize];
}

+ (instancetype)videoWithURL:(NSURL *)url{
    return [[self alloc] initWithVideoURL:url];
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        self.emptyImage = YES;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.image = image;
        _underlyingImage = image;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.photoURL = url;
    }
    return self;
}

- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    if (self = [super init]) {
        self.asset = asset;
        self.assetTargetSize = targetSize;
        self.isVideo = asset.mediaType == PHAssetMediaTypeVideo;
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)url {
    if (self = [super init]) {
        self.videoURL = url;
    }
    return self;
}

#pragma mark - Video

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    self.isVideo = YES;
}

- (void)getVideoURL:(void (^)(NSURL *))completion {
    if (completion == nil) return;
    if (_videoURL) {
        completion(_videoURL);
    } else if (_asset && _asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                completion(((AVURLAsset *)asset).URL);
            } else{
                completion(nil);
            }
        }];
    } else {
        completion(nil);
    }
}

#pragma mark - WJPhoto Protocol Methods
- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// Set the underlying image
- (void)performLoadUnderlyingImageAndNotify {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage
        self.underlyingImage = _image;
        [self imageLoadingComplete];
    } else if (_photoURL) {
        
        // Check what type of url it is
        if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
            // asset's URL for earlier iOS 8.0 (<iOS 8.0) Library
            // Load from assets library
            [self _performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL:_photoURL];
        } else if ([_photoURL isFileReferenceURL]) {
            // File URL for local image's file
            // Load from local file async
            [self _performLoadUnderlyingImageAndNotifyWithLocalFileURL:_photoURL];
        } else {
            // Web URL
            // Load async from web (using SDWebImage)
            [self _performLoadUnderlyingImageAndNotifyWithWebURL:_photoURL];
        }
    } else if (_asset) {
        
        // asset for Photos (systemVersion>=iOS8.0)
        [self _performLoadUnderlyingImageAndNotifyWithAsset:_asset targetSize:_assetTargetSize];
    } else {
        
        // Image is empty
        [self imageLoadingComplete];
    }
}

// Load from assets library async
- (void)_performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                [assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    if (iref) self.underlyingImage = [UIImage imageWithCGImage:iref];
                    [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                } failureBlock:^(NSError *error) {
                    self.underlyingImage = nil;
                    WJLog(@"Photo from asset library error: %@",error);
                    [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                }];
            }
            @catch (NSException *exception) {
                WJLog(@"Photo from asset library error: %@", exception);
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }
            @finally {
            }
        }
    });
}

// Load from local file
- (void)_performLoadUnderlyingImageAndNotifyWithLocalFileURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                self.underlyingImage = [UIImage imageWithContentsOfFile:url.path];
                if (!_underlyingImage) WJLog(@"Error loading photo from path: %@", url.path);
            }
            @finally {
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }
        }
    });
}

// Load from web
- (void)_performLoadUnderlyingImageAndNotifyWithWebURL:(NSURL *)url {
    __weak typeof(self) wself = self;
    @try {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (expectedSize > 0) {
                float progress = receivedSize / (float)expectedSize;
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:progress], @"progress",
                                      wself, @"photo", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:WJPHOTO_LOADING_PROGRESS_NOTIFICATION object:dict];
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (error) WJLog(@"SDWebImage failed to download image: %@", error);
            _webImageOperation = nil;
            wself.underlyingImage = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself imageLoadingComplete];
            });
        }];
    }
    @catch (NSException *exception) {
        WJLog(@"Error loading photo from web: %@", exception);
        _webImageOperation = nil;
        [wself imageLoadingComplete];
    }
}

// Load from photos library
- (void)_performLoadUnderlyingImageAndNotifyWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    PHImageManager *imgMgr = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble: progress], @"progress",
                              self, @"photo", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:WJPHOTO_LOADING_PROGRESS_NOTIFICATION object:dict];
    };
    _assetRequestID = [imgMgr requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // there is not error status
        dispatch_async(dispatch_get_main_queue(), ^{
            self.underlyingImage = result;
            [self imageLoadingComplete];
        });
    }];
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    self.underlyingImage = nil;
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:WJPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (void)cancelAnyLoading {
    if (_webImageOperation != nil) {
        [_webImageOperation cancel];
        _loadingInProgress = NO;
    } else if (_assetRequestID != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_assetRequestID];
        _assetRequestID = PHInvalidImageRequestID;
    }
}

#pragma mark - Helper
+ (UIImage *)imageForPhoto:(id<WJPhoto>)photo {
    if (photo) {
        // Get image or obtain in background
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
        }
    }
    return nil;
}

@end
