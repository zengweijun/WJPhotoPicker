//
//  WJPhotoGroupCell.m
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJPhotoGroupCell.h"
#import "WJPhotoGroup.h"

@interface WJPhotoGroupCell()
@property (weak, nonatomic) UIImageView *groupImageView;
@property (weak, nonatomic) UILabel *groupNameLabel;
@property (weak, nonatomic) UILabel *groupPicCountLabel;

@end

@implementation WJPhotoGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    self.clipsToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                 name:WJPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImageView *)groupImageView{
    if (!_groupImageView) {
        UIImageView *groupImageView = [[UIImageView alloc] init];
        groupImageView.frame = CGRectMake(15, 15, 70, 70);
        groupImageView.contentMode = UIViewContentModeScaleAspectFill;
        groupImageView.clipsToBounds = YES;
        [self.contentView addSubview:_groupImageView = groupImageView];
    }
    return _groupImageView;
}

- (UILabel *)groupNameLabel{
    if (!_groupNameLabel) {
        UILabel *groupNameLabel = [[UILabel alloc] init];
        groupNameLabel.frame = CGRectMake(95, 20, self.frame.size.width - 100, 20);
        [self.contentView addSubview:_groupNameLabel = groupNameLabel];
    }
    return _groupNameLabel;
}

- (UILabel *)groupPicCountLabel{
    if (!_groupPicCountLabel) {
        UILabel *groupPicCountLabel = [[UILabel alloc] init];
        groupPicCountLabel.font = [UIFont systemFontOfSize:13];
        groupPicCountLabel.textColor = [UIColor lightGrayColor];
        groupPicCountLabel.frame = CGRectMake(95, 50, self.frame.size.width - 100, 20);
        [self.contentView addSubview:_groupPicCountLabel = groupPicCountLabel];
    }
    return _groupPicCountLabel;
}

- (void)setGroup:(WJPhotoGroup *)group{
    _group = group;
    
    self.groupNameLabel.text = group.caption;
    self.groupPicCountLabel.text = [NSString stringWithFormat:@"(%ld)",(long)group.count];
}

- (void)displayImage {
    self.groupImageView.image = [_group underlyingImage];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Notifications

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id<WJPhoto> group = [notification object];
    if (group == _group) {
        if ([group underlyingImage]) {
            // Successful load
            [self displayImage];
        } else {
            // Failed to load
            // code here show image load failure status
        }
        // code here hide loading indicator
    }
}


@end
