//
//  WatchingForumViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/4/28.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "WatchingForumViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ForumModels.h"
#import "ForumItemTableViewCell.h"
#import "TopicsViewController.h"

@interface WatchingForumViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WatchingForumViewController {
    NSMutableArray<ForumItem*>* _listItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _listItems = [[NSMutableArray alloc] initWithCapacity:100];
    
    [self addRefreshViewAndLoadMoreView];
    
    if ([[NetworkManager sharedManager] isLoggedIn]) {
        [self loadWithLoadingView];
    } else {
        [self showLoginView];
    }
}

- (void)presentLoginTapped {
    [self.parentViewController performSegueWithIdentifier:@"PresentLoginAndRegister" sender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([[NetworkManager sharedManager] isLoggedIn] && self.loginView != nil) {
        [self removeLoginView];
        [self loadWithLoadingView];
    }
    
    if (![[NetworkManager sharedManager] isLoggedIn] && self.loginView == nil)
    {
        [self showLoginView];
    }
}

- (void)loadData {
    NSString* url = [NSString stringWithFormat:@"forum/watching?offset=%d&limit=%d", self.loadingStatus == LoadingStatusLoadingMore ? (int)_listItems.count : 0, 10];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            ForumListLimited* forumList = [[ForumListLimited alloc] initWithData:data error:&error];
            if (error == nil) {
                if (forumList.limit > forumList.forumItems.count) {
                    self.noMoreData = YES;
                } else {
                    self.noMoreData = NO;
                }
                
                if (self.loadingStatus == LoadingStatusLoadingWithLoadingView
                    || self.loadingStatus == LoadingStatusLoadingWithRefreshView
                    || self.loadingStatus == LoadingStatusLoadingWithToastActivity) {
                    [_listItems removeAllObjects];
                }
                
                for (ForumItem* item in forumList.forumItems) {
                    [_listItems addObject:item];
                }
                
                [self.tableView reloadData];
            } else {
                NSLog(@"JSON Error: %@", error);
            }
        } else {
            if (statusCode == 401) {
                [self showLoginView];
            } else if (self.loadingStatus == LoadingStatusLoadingWithLoadingView) {
                [self showErrorViewWithMessage:errorMessage];
            } else {
                [self.view makeToast:errorMessage];
            }
        }
        
        [self removeLoadingViews];
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_listItems != nil) {
        return _listItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ForumItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    ForumItem* item = _listItems[indexPath.row];
    if (cell.task != nil && cell.task.state == NSURLSessionTaskStateRunning) {
        [cell.task cancel];
    }
    
    if (item.icon != nil) {
        cell.task = [[NetworkManager sharedManager] getResizedImageWithName:item.icon dimension:120 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.logoImageView.image = [UIImage imageWithData:data];
            } else {
                cell.logoImageView.image = [UIImage imageNamed:@"no_photo"];
            }
        }];
    } else {
        cell.logoImageView.image = [UIImage imageNamed:@"no_photo"];
    }
    cell.nameLabel.text = item.name;
    cell.statisticsLabel.text = [NSString stringWithFormat:@"关注:%d 帖子:%d", item.watch, item.posts];
    cell.descLabel.text = item.desc;
    
    
    return cell;
}

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
    [self performSegueWithIdentifier:@"PresentForumTopics" sender:self];

//    TopicsViewController* topicsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Topics"];
//    topicsViewController.forumId = _listItems[self.tableView.indexPathForSelectedRow.row].id;
//    [self.parentViewController.navigationController pushViewController:topicsViewController animated:YES];
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PresentForumTopics"]) {
        UINavigationController* navigationController = [segue destinationViewController];
        TopicsViewController* topicsViewController = navigationController.viewControllers[0];
        
        topicsViewController.forumId = _listItems[self.tableView.indexPathForSelectedRow.row].id;;
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

@end
