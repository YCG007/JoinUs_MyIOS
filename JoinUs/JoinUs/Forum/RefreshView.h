//
//  RefreshView.h
//  JoinUs
//
//  Created by 杨春贵 on 16/4/23.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
static const float kRefreshViewHeight = 120.0f;

@interface RefreshView : UIView

- (void)setVisibleHeight:(float)visibleHeight;

- (void)beginRefreshing;
- (void)endRefreshing;
- (void)reset;

@end
