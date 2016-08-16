//
//  TopicItemTableViewCell.h
//  JoinUs
//
//  Created by 杨春贵 on 16/4/28.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userGenderImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicPostDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteTopicButton;
@property (weak, nonatomic) IBOutlet UILabel *topicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicStatisticsLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstPostContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstPostImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *firstPostImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *firstPostImageView3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstPostImageStackViewHeightConstraint;

@property (nonatomic) NSMutableArray<NSURLSessionDataTask*>* tasks;

@end
