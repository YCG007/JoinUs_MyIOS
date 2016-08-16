//
//  BaseListViewController.h
//  JoinUs
//
//  Created by 杨春贵 on 16/4/28.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RefreshView;

typedef enum : NSUInteger {
    LoadingStatusLoadingWithLoadingView,//进入界面加载
    LoadingStatusLoadingWithRefreshView,//下拉刷新加载
    LoadingStatusLoadingWithToastActivity,//变更时刷新
    LoadingStatusLoadingMore,//上拉加载更多
    LoadingStatusIdle//
} LoadingStatus;

@interface BaseListViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) LoadingStatus loadingStatus;
@property (nonatomic) RefreshView* refreshView;
@property (nonatomic) UIView* loadingView;
@property (nonatomic) UIView* errorView;
@property (nonatomic) UIView* loginView;
@property (nonatomic) BOOL noMoreData;

- (UITableView*)tableView;

- (void)addRefreshViewAndLoadMoreView;
- (void)loadData;
- (void)loadWithLoadingView;
- (void)loadWithRefreshView;
- (void)loadWithToastActivity;
- (void)loadMore;
- (void)removeLoadingViews;
- (void)stopLoadMoreAnimation;
- (void)startLoadMoreAnimation;
- (void)showLoadingView;
- (void)showErrorViewWithMessage:(NSString*)message;
- (void)errorReload;
- (void)showLoginView;
- (void)presentLoginTapped;
- (void)removeLoginView;
@end
