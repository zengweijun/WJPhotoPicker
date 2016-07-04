//
//  WJVideoDisplayController.m
//  Example
//
//  Created by 森巴iOS开发部 on 16/6/22.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJVideoDisplayController.h"
#import "WJPhotoGridController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"

@interface WJVideoDisplayController ()

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, weak) UIToolbar *toolbar;

@property (nonatomic, weak) UIButton *videoPlayButton;
@property (nonatomic, weak) UIImageView *tipsImageView;

@end

@implementation WJVideoDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"视频预览";
    
    _moviePlayer = [[MPMoviePlayerController alloc] init];
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    _moviePlayer.view.frame = self.view.bounds;
    [self.view addSubview:_moviePlayer.view];
    _moviePlayer.shouldAutoplay = NO;
    _moviePlayer.initialPlaybackTime = -0.5;
    
    UIView *moviePlayerView = _moviePlayer.view;
    moviePlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *moviePlayerViews = NSDictionaryOfVariableBindings(moviePlayerView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[moviePlayerView]-0-|" options:0 metrics:nil views:moviePlayerViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[moviePlayerView]-0-|" options:0 metrics:nil views:moviePlayerViews]];
    
    UIImageView *tipsImageView = [[UIImageView alloc] init];
    tipsImageView.contentMode = UIViewContentModeScaleAspectFit;
    [moviePlayerView addSubview:tipsImageView];
    self.tipsImageView = tipsImageView;
    __weak __typeof(&*self) wself = self;
    [self.gridController.groupController asynchronousGetImage:_photoAsset thumb:NO completeCb:^(UIImage *image) {
        __strong __typeof(&*wself) sself = wself;
        sself.tipsImageView.image = image;
    }];
    tipsImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *tipsImageViewViews = NSDictionaryOfVariableBindings(tipsImageView);
    [moviePlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tipsImageView]-0-|" options:0 metrics:nil views:tipsImageViewViews]];
    [moviePlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tipsImageView]-0-|" options:0 metrics:nil views:tipsImageViewViews]];
    
    UIButton *videoPlayButton = [[UIButton alloc] init];
    [moviePlayerView addSubview:videoPlayButton];
    [videoPlayButton setImage:[UIImage imageNamed:@"PlayButtonOverlayLarge"] forState:UIControlStateNormal];
    [_moviePlayer.view addSubview:videoPlayButton];
    [videoPlayButton addTarget:self action:@selector(playOrStop) forControlEvents:UIControlEventTouchDown];
    videoPlayButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *videoPlayButtonViews = NSDictionaryOfVariableBindings(videoPlayButton);
    [moviePlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[videoPlayButton]-0-|" options:0 metrics:nil views:videoPlayButtonViews]];
    [moviePlayerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[videoPlayButton]-0-|" options:0 metrics:nil views:videoPlayButtonViews]];
    self.videoPlayButton = videoPlayButton;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
    
    UIBarButtonItem *completeItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(completeItemClicked)];
     UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:@[flexible, flexible, completeItem]];
    
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *toolbarViews = NSDictionaryOfVariableBindings(toolbar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolbar]-0-|" options:0 metrics:nil views:toolbarViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbar(44)]-0-|" options:0 metrics:nil views:toolbarViews]];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClicked)];
    self.navigationItem.rightBarButtonItem = cancelBtn;
    
    
    // Movie Player Notifications
    // 当回放状态改变时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

- (void)completeItemClicked {
    if (self.gridController.groupController.mediaType == WJPhotoMediaTypeVideo) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"视频处理中...";
        __weak __typeof(&*hud) whud = hud;
        __weak __typeof(&*self) wself = self;
        [self.gridController.groupController exportVideoFileFromAsset:self.photoAsset filePath:self.gridController.filePath presetName:self.gridController.presetName?self.gridController.presetName:AVAssetExportPresetHighestQuality completeCb:^(NSString *errStr) {
            __strong __typeof(&*whud) shud = whud;
            __strong __typeof(&*wself) sself = wself;
            [shud hide:YES];
            
            if (sself.gridController.groupController.fetchVideoCallback)
                sself.gridController.groupController.fetchVideoCallback(sself.gridController.groupController, sself.photoAsset, sself.gridController.filePath, errStr?[NSError errorWithDomain:errStr code:0 userInfo:nil]:nil);
            
            [sself completeCallback];
        }];
    } else  {
        [self completeCallback];
    }
}

- (void)completeCallback {
    [self.gridController.seletedAssets removeAllObjects];
    if (self.photoAsset) [self.gridController.seletedAssets addObject:self.photoAsset];
    [[NSNotificationCenter defaultCenter] postNotificationName:WJPhotoPickerDoneButtonClicked object:nil];
    [self cancelBtnClicked];
}

- (void)playbackStateDidChange {
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            [self.videoPlayButton setImage:nil forState:UIControlStateNormal];
            if (self.tipsImageView) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.07 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.tipsImageView removeFromSuperview];
                });
            }
            [self.navigationController setNavigationBarHidden:YES];
            [self.toolbar setHidden:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            break;
        case MPMoviePlaybackStatePaused:
            [self.videoPlayButton setImage:[UIImage imageNamed:@"PlayButtonOverlayLarge"] forState:UIControlStateNormal];
            [self.navigationController setNavigationBarHidden:NO];
            [self.toolbar setHidden:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            break;
        default:
            break;
    }
}

- (void)cancelBtnClicked {[self dismissViewControllerAnimated:YES completion:NULL];}

- (void)playOrStop {
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.moviePlayer pause];
    } else if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused ||
               self.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
        [self toPlay];
    }
}

- (void)toPlay {
    if (self.moviePlayer.contentURL) {
        [_moviePlayer play];
    } else {
        __weak __typeof(&*self) wself = self;
        [self.gridController.groupController getVideoURLFromAsset:self.photoAsset completeCb:^(NSURL *videURL) {
            __strong __typeof(&*wself) sself = wself;
            [sself.moviePlayer setContentURL:videURL];
            [sself.moviePlayer prepareToPlay];
            [sself.moviePlayer play];
        }];
    }
}

- (void)dealloc {
    self.moviePlayer.contentURL = nil;
    self.moviePlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = self.barTintColor;
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [UIColor blackColor],NSForegroundColorAttributeName,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attrs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.barTintColor = self.navigationController.navigationBar.barTintColor;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.toolbar.barTintColor = self.navigationController.navigationBar.barTintColor;
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attrs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
