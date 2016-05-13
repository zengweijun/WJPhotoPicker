//
//  WJPhotoGroupCell.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/18.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WJPhotoGroup;
@interface WJPhotoGroupCell : UITableViewCell

@property (strong, nonatomic) WJPhotoGroup *group;

- (void)displayImage;

@end
