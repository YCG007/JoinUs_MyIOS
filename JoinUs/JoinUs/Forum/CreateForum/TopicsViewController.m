//
//  TopicsViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/4/28.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "TopicsViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ForumModels.h"
#import "TopicItemTableViewCell.h"
#import "PostViewController.h"
#import "CreateTopicViewController.h"

@interface TopicsViewController ()
@property (weak, nonatomic) IBOutlet UIView *forumView;
@property (weak, nonatomic) IBOutlet UILabel *forumNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *forumIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *forumStatisticsLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteForumButton;
@property (weak, nonatomic) IBOutlet UILabel *forumDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *myPostsLabel;
@property (weak, nonatomic) IBOutlet UIButton *forumWatchButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *watchButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TopicsViewController {
    NSMutableArray<TopicItem*>* _listItems;
    BOOL _isLoggedInLastLoad;
    
    ForumInfo* _forumInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deleteForumButton.layer.cornerRadius = 3;
    self.forumWatchButton.layer.cornerRadius = 5;
    
    _listItems = [[NSMutableArray alloc] initWithCapacity:100];
    
    [self addRefreshViewAndLoadMoreView];
    [self loadWithLoadingView];
}

- (void)viewWillAppear:(BOOL)animated {
    if (_isLoggedInLastLoad != [[NetworkManager sharedManager] isLoggedIn]) {
        [self loadWithToastActivity];
    }
}

- (void)loadData {
    _isLoggedInLastLoad = [[NetworkManager sharedManager] isLoggedIn];
    NSString* url = [NSString stringWithFormat:@"forum/%@?offset=%d&limit=%d", self.forumId, self.loadingStatus == LoadingStatusLoadingMore ? (int)_listItems.count : 0, 10];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            TopicListLimited* topicList = [[TopicListLimited alloc] initWithData:data error:&error];
            if (error == nil) {
                
                self.forumNameLabel.text = topicList.forumInfo.name;
                if (topicList.forumInfo.icon != nil) {
                    [[NetworkManager sharedManager] getResizedImageWithName:topicList.forumInfo.icon dimension:160 completionHandler:^(long statusCode, NSData *data) {
                        if (statusCode == 200) {
                            self.forumIconImageView.image = [UIImage imageWithData:data];
                        } else {
                            self.forumIconImageView.image = [UIImage imageNamed:@"no_image"];
                        }
                    }];
                } else {
                    self.forumIconImageView.image = [UIImage imageNamed:@"no_photo"];
                }
                if (topicList.forumInfo.watchedByMe != nil) {
                    [self.forumWatchButton setTitle:@"取消关注" forState:UIControlStateNormal];
                    [self.forumWatchButton setBackgroundColor:[UIColor lightGrayColor]];
                    self.myPostsLabel.hidden = NO;
                    self.watchButtonWidthConstraint.constant = (self.view.frame.size.width - 192);
                } else {
                    [self.forumWatchButton setTitle:@"+关注" forState:UIControlStateNormal];
                    [self.forumWatchButton setBackgroundColor:[UIColor redColor]];
                    self.myPostsLabel.hidden = YES;
                    self.watchButtonWidthConstraint.constant = (self.view.frame.size.width - 120);

                }
                
                self.forumStatisticsLabel.text = [NSString stringWithFormat:@"关注:%d 帖子:%d", topicList.forumInfo.watch, topicList.forumInfo.posts];
                self.forumDescLabel.text = topicList.forumInfo.desc;
                
                // 让说明部分的label在有多行时把view给顶开
                CGFloat height = [self.forumView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                CGRect headerFrame = self.forumView.frame;
                headerFrame.size.height = height;
                self.forumView.frame = headerFrame;
                
                self.tableView.tableHeaderView = self.forumView;
                self.myPostsLabel.text = [NSString stringWithFormat:@"发帖:%d", topicList.forumInfo.watchedByMe.posts];
                
                if (topicList.limit > topicList.topicItems.count) {
                    self.noMoreData = YES;
                } else {
                    self.noMoreData = NO;
                }
                
                if (topicList.forumInfo.deleteable) {
                    self.deleteForumButton.hidden = NO;
                } else {
                    self.deleteForumButton.hidden = YES;
                }
                
                if (self.loadingStatus == LoadingStatusLoadingWithLoadingView
                    || self.loadingStatus == LoadingStatusLoadingWithRefreshView
                    || self.loadingStatus == LoadingStatusLoadingWithToastActivity) {
                    [_listItems removeAllObjects];
                }
                
                for (TopicItem* item in topicList.topicItems) {
                    [_listItems addObject:item];
                }
                
                //对tableView重新加载
                [self.tableView reloadData];
            } else {
                NSLog(@"JSON Error: %@", error);
            }
        } else {
            if (self.loadingStatus == LoadingStatusLoadingWithLoadingView) {
                [self showErrorViewWithMessage:errorMessage];
            } else {
                [self.view makeToast:errorMessage];
            }
        }
        
        [self removeLoadingViews];
    }];

}

- (IBAction)createTopicButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"CreateTopic" sender:self];
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteForumButtonPressed:(id)sender {
    
    NSString* url = [NSString stringWithFormat:@"forum/%@", self.forumId];
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] deleteDataWithUrl:url data:nil completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
    
}


- (IBAction)forumWatchButtonPressed:(id)sender {
    if ([[NetworkManager sharedManager] isLoggedIn]) {
        [self.view makeToastActivity:CSToastPositionCenter];
        
        if ([self.forumWatchButton.titleLabel.text isEqualToString:@"取消关注"]) {
            NSString* url = [NSString stringWithFormat:@"forum/%@/unwatch", self.forumId];
            [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
                [self.view hideToastActivity];
                if (statusCode == 200) {
                                    [self loadWithToastActivity];
                } else {
                    [self.view makeToast:errorMessage];
                }
            }];
            
        } else {
            NSString* url = [NSString stringWithFormat:@"forum/%@/watch", self.forumId];
            [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
                [self.view hideToastActivity];
                if (statusCode == 200) {
                                    [self loadWithToastActivity];
                } else {
                    [self.view makeToast:errorMessage];
                }
            }];
        }
        [self loadData];
        
    } else {
        [self performSegueWithIdentifier:@"PresentLoginAndRegister" sender:self];
    }
}

- (void)deleteTopicButtonPressed:(UIButton*)sender {
    long row = sender.tag;//取出行号
    NSString* topicId = [_listItems objectAtIndex:row].id;
    NSString* url = [NSString stringWithFormat:@"topic/%@", topicId];
    NSLog(@"%@", url);
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] deleteDataWithUrl:url data:nil completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            [self loadWithToastActivity];
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_listItems != nil) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_listItems != nil) {
        return _listItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    TopicItem* topic = _listItems[indexPath.row];
    NSLog(@"cell.tasks %@",cell.tasks);
    if (cell.tasks != nil && cell.tasks.count > 0) {
        for (NSURLSessionTask* task in cell.tasks) {
            if(task.state == NSURLSessionTaskStateRunning) {
                [task cancel];
            }
        }
    }
    
    if (cell == nil) {
        cell.tasks = [[NSMutableArray alloc] init];
    }
    
    cell.userPhotoImageView.layer.cornerRadius = cell.userPhotoImageView.frame.size.width / 2;
    
    if (topic.postedBy.photo != nil) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.postedBy.photo dimension:160 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.userPhotoImageView.image = [UIImage imageWithData:data];
            } else {
                cell.userPhotoImageView.image = [UIImage imageNamed:@"no_photo"];
            }
        }];
        [cell.tasks addObject:task];
    } else {
        cell.userPhotoImageView.image = [UIImage imageNamed:@"no_photo"];
    }
    
    cell.userNameLabel.text = topic.postedBy.name;
    if (topic.postedBy.gender.id == 2) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_male"];
    } else if (topic.postedBy.gender.id == 3) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_female"];
    } else {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_no_gender"];
    }
    cell.userLevelLabel.text = [NSString stringWithFormat:@" LV.%d", topic.postedBy.level];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    cell.topicPostDateLabel.text = [dateFormatter stringFromDate:topic.firstPostDate];
    
    cell.deleteTopicButton.tag = indexPath.row;
    [cell.deleteTopicButton addTarget:self action:@selector(deleteTopicButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (topic.deleteable) {
        cell.deleteTopicButton.hidden = NO;
    } else {
        cell.deleteTopicButton.hidden = YES;
    }
    
    cell.topicTitleLabel.text = topic.title;
    cell.topicStatisticsLabel.text = [NSString stringWithFormat:@"帖子:%d 浏览:%d", topic.posts, topic.views];
    cell.firstPostContentLabel.text = topic.firstPost.content;
    
    cell.firstPostImageView1.image = nil;
    cell.firstPostImageView2.image = nil;
    cell.firstPostImageView3.image = nil;
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 0) {
        cell.firstPostImageStackViewHeightConstraint.constant = (self.view.frame.size.width - 16 -4) / 3;
    } else {
        cell.firstPostImageStackViewHeightConstraint.constant = 0;
    }
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 0) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.firstPost.images[0] dimension:200 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.firstPostImageView1.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
    }
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 1) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.firstPost.images[1] dimension:200 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.firstPostImageView2.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
    }
    
    if (topic.firstPost.images != nil && topic.firstPost.images.count > 2) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:topic.firstPost.images[2] dimension:200 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.firstPostImageView3.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
    }

    
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
//{
//    cell.backgroundColor = [UIColor redColor];//cell背景色
////    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0 green:228.0 blue:196.0 alpha:0.5];
//
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"PushPost" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushPost"]) {
        PostViewController* postViewController = segue.destinationViewController;
        postViewController.topicId = _listItems[self.tableView.indexPathForSelectedRow.row].id;
    }
    if([segue.identifier isEqualToString:@"CreateTopic"]) {
        CreateTopicViewController* createTopicViewController = segue.destinationViewController;
        createTopicViewController.forumId = self.forumId;//_listItems[self.tableView.indexPathForSelectedRow.row].id;

    }
}

@end