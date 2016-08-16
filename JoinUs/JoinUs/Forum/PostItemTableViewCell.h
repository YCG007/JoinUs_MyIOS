//
//  PostItemTableViewCell.h
//  JoinUs
//
//  Created by 杨春贵 on 16/5/12.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userGenderImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicPostDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *deletePostButton;
@property (weak, nonatomic) IBOutlet UILabel *nextPostContentLabel;
@property (weak, nonatomic) IBOutlet UIStackView *imageStackView;

@property (nonatomic) NSMutableArray<NSURLSessionDataTask*>* tasks;

@end
