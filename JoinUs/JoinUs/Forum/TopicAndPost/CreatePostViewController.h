//
//  CreatePostViewController.h
//  JoinUs
//
//  Created by 杨春贵 on 16/5/16.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumModels.h"
#import "TZImagePickerController.h"

@interface CreatePostViewController : UIViewController <TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic) PostAdd* postAdd;
@property (nonatomic) NSString* topicId;

@end
