//
//  PostViewController.h
//  JoinUs
//
//  Created by 杨春贵 on 16/5/12.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "BaseListViewController.h"
#import "NYTPhotosViewController.h"
#import "ForumModels.h"
#import "TZImagePickerController.h"

@interface PostViewController : BaseListViewController <TZImagePickerControllerDelegate,NYTPhotosViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic) NSString* topicId;

@end
