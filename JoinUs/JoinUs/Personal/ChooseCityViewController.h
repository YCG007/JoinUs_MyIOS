//
//  ChooseCityViewController.h
//  JoinUs
//
//  Created by Liang Qian on 16/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Models.h"

@interface ChooseCityViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) ProvinceItem* provinceItem;

@end
