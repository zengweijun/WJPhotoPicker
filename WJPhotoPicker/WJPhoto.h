//
//  WJPhoto.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 15/12/28.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJPhotoProtocol.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to WJPhotoProtocol
@interface WJPhoto : NSObject<WJPhoto> 

// Protperties
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSURL *videoURL;
@property (assign, nonatomic) BOOL emptyImage;
@property (assign, nonatomic) BOOL isVideo;

// Init method for static
+ (instancetype)photoWithImage:(UIImage *)image;
+ (instancetype)photoWithURL:(NSURL *)url;
+ (instancetype)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (instancetype)videoWithURL:(NSURL *)url; // Initialise video with no poster image

// Init method for dynamic
- (instancetype)init;
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
- (instancetype)initWithVideoURL:(NSURL *)url;

// Helper
+ (UIImage *)imageForPhoto:(id<WJPhoto>)photo;

@end
