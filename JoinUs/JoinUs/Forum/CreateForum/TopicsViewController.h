//
//  TopicsViewController.h
//  JoinUs
//
//  Created by 杨春贵 on 16/4/28.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "BaseListViewController.h"

@interface TopicsViewController : BaseListViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSString* forumId;

@end
