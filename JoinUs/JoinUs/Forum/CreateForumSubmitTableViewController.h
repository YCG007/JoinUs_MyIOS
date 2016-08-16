//
//  CreateForumSubmitTableViewController.h
//  JoinUs
//
//  Created by 杨春贵 on 16/4/23.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumModels.h"

@interface CreateForumSubmitTableViewController : UITableViewController
@property (nonatomic) ForumAdd* forumAdd;
@property (nonatomic) NSArray<Category>* categories;

@end
