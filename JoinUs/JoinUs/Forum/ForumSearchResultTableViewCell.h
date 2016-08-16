//
//  ForumSearchResultTableViewCell.h
//  JoinUs
//
//  Created by 杨春贵 on 16/5/14.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForumSearchResultTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *forumNameLabel;
@property (nonatomic) NSURLSessionDataTask* task;

@end
