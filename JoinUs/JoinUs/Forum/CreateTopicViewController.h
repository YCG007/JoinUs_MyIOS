//
//  CreateTopicViewController.h
//  JoinUs
//
//  Created by 杨春贵 on 16/5/13.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumModels.h"
#import "TZImagePickerController.h"

@interface CreateTopicViewController : UIViewController <TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic) NSString* forumId;

@end
