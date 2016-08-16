//
//  ForumSearchResultViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/5/14.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "ForumSearchResultViewController.h"
#import "NetworkManager.h"
#import "Utils.h"
#import "ForumModels.h"
#import "ForumSearchResultTableViewCell.h"
#import "TopicsViewController.h"

@interface ForumSearchResultViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ForumSearchResultViewController {
    NSArray<ForumItem*>* _listItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listItems = [[NSMutableArray alloc] initWithCapacity:30];
    
}

- (void)loadDataWithSearchText:(NSString*) text {
    NSString *encodedText = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString* url = [NSString stringWithFormat:@"forum/search?text=%@&offset=%d&limit=%d", encodedText, 0, 10];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            ForumListLimited* forumList = [[ForumListLimited alloc] initWithData:data error:&error];
            if (error == nil) {
                _listItems = forumList.forumItems;
                [self.tableView reloadData];
            } else {
                NSLog(@"%@", error);
            }
        } else {
            [self.view makeToast:errorMessage];
        }
        
    }];
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"updateSearchResultsForSearchController - %@", searchController.searchBar.text);
    [self loadDataWithSearchText:searchController.searchBar.text];
}

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
    ForumSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ForumItem* item = _listItems[indexPath.row];
    
    if (cell.task != nil && cell.task.state == NSURLSessionTaskStateRunning) {
        [cell.task cancel];
    }
    cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.size.width / 2;
    cell.iconImageView.layer.masksToBounds = YES;
    cell.iconImageView.image = [UIImage imageNamed:@"no_image"];
    if (item.icon != nil) {
        cell.task = [[NetworkManager sharedManager] getResizedImageWithName:item.icon dimension:80 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.iconImageView.image = [UIImage imageWithData:data];
            }
        }];
    }
    cell.forumNameLabel.text = item.name;
    
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"PresentForumTopics" sender:self];
    
//    NSLog(@"didSelectRowAtIndexPath");
//    TopicsViewController* topicsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Topics"];
//    topicsViewController.forumId = _listItems[self.tableView.indexPathForSelectedRow.row].id;
//    [self.presentingViewController.navigationController pushViewController:topicsViewController animated:YES];
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
