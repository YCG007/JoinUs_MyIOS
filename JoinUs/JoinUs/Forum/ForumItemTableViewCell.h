//
//  ForumItemTableViewCell.h
//  JoinUs
//
//  Created by 杨春贵 on 16/4/23.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForumItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *statisticsLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;


@property (nonatomic) NSURLSessionDataTask* task;
@end
