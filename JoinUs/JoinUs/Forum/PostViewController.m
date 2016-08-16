//
//  PostViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/5/12.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "PostViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ForumModels.h"
#import "PostItemTableViewCell.h"
#import "NYTPhotosViewController.h"
#import "ViewingImage.h"

#import "UIView+Layout.h"
#import "TZTestCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LxGridViewFlowLayout.h"
#import "TZImageManager.h"

@interface PostViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    int _uploadedImageCount;
    PHImageRequestOptions *_submitRequestOptions;
    PHImageRequestOptions *_thumbnailRequestOptions;
    
    CGFloat _itemWH;
    CGFloat _margin;
    LxGridViewFlowLayout *_layout;
}
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userGenderImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicStatisticsLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UIView *createPostView;
@property (weak, nonatomic) IBOutlet UITextView *postContentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postContentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postContentBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blockingViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PostViewController {
    NSMutableArray<PostItem*>* _listItems;
    
    int temp;
    UILabel* countLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    temp=0;
    
    _listItems = [[NSMutableArray alloc] initWithCapacity:100];
    
    [self addRefreshViewAndLoadMoreView];
    [self loadWithLoadingView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    //To make the border look very close to a UITextField
    [self.createPostView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.createPostView.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.createPostView.layer.cornerRadius = 5;
    self.createPostView.clipsToBounds = YES;
    
    //To make the border look very close to a UITextField
    [self.postContentTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.postContentTextView.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.postContentTextView.layer.cornerRadius = 5;
    self.postContentTextView.clipsToBounds = YES;
    
    [self.photoView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.photoView.layer setBorderWidth:1.0];
    self.photoView.layer.cornerRadius = 5;
    self.photoView.clipsToBounds = YES;
    
    _submitRequestOptions = [[PHImageRequestOptions alloc] init];
    _submitRequestOptions.synchronous = YES;
    _submitRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    _submitRequestOptions.networkAccessAllowed = NO;
    
    _submitRequestOptions = [[PHImageRequestOptions alloc] init];
    _submitRequestOptions.synchronous = YES;
    _submitRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    _submitRequestOptions.networkAccessAllowed = NO;
    _submitRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;

    self.postContentBottomConstraint.constant = -self.photoView.frame.size.height;
    self.photoView.hidden = YES;
//    self.blockingViewTopConstraint.constant = 0;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString* countString = [[NSString alloc]initWithFormat:@"%lu / 9",(unsigned long)_selectedAssets.count];
    [countLabel setText:countString];
    
}

- (void)configCollectionView {
    _layout = [[LxGridViewFlowLayout alloc] init];
    _margin = 4;
    _layout.itemSize = CGSizeMake(70, 105);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    [_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(_margin, 20, self.view.frame.size.width - 8, 110) collectionViewLayout:_layout];
    CGFloat rgb = 244 / 255.0;
    _collectionView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    _collectionView.scrollEnabled = YES;
    _collectionView.pagingEnabled = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(4, 0, 0, 2);
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_photoView addSubview:_collectionView];
    
    [_collectionView registerClass:[TZTestCell class] forCellWithReuseIdentifier:@"TZTestCell"];
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedPhotos.count + 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
    if (indexPath.row == _selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn.png"];
        cell.deleteBtn.hidden = YES;
    } else {
        cell.imageView.image = _selectedPhotos[indexPath.row];
        cell.deleteBtn.hidden = NO;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedPhotos.count) {
        [self pickPhotoButtonClick];
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.item >= _selectedPhotos.count || destinationIndexPath.item >= _selectedPhotos.count) return;
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    if (image) {
        [_selectedPhotos exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
        [_selectedAssets exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
        [_collectionView reloadData];
    }
}

#pragma mark Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    _layout.itemCount = _selectedPhotos.count;
    
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
}




- (void)loadData {
    NSString* url = [NSString stringWithFormat:@"topic/%@?offset=%d&limit=%d", self.topicId, self.loadingStatus == LoadingStatusLoadingMore ? (int)_listItems.count : 0, 10];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            PostListLimited* postList = [[PostListLimited alloc] initWithData:data error:&error];
            if (error == nil) {
                self.userNameLabel.text = postList.topicInfo.postedBy.name;
                if (postList.topicInfo.postedBy.photo != nil) {
                    [[NetworkManager sharedManager] getResizedImageWithName:postList.topicInfo.postedBy.photo dimension:40 completionHandler:^(long statusCode, NSData *data) {
                        if (statusCode == 200) {
                            self.userPhotoImageView.image = [UIImage imageWithData:data];
                        } else {
                            self.userPhotoImageView.image = [UIImage imageNamed:@"no_photo"];
                        }
                    }];
                } else {
                    self.userPhotoImageView.image = [UIImage imageNamed:@"no_photo"];
                }
                
                self.topicStatisticsLabel.text = [NSString stringWithFormat:@"浏览:%d 帖子:%d", postList.topicInfo.views, postList.topicInfo.posts];
                if (postList.topicInfo.postedBy.gender.id == 2) {
                    self.userGenderImageView.image = [UIImage imageNamed:@"icon_male"];
                } else if (postList.topicInfo.postedBy.gender.id == 3) {
                    self.userGenderImageView.image = [UIImage imageNamed:@"icon_female"];
                } else {
                    self.userGenderImageView.image = [UIImage imageNamed:@"icon_no_gender"];
                }
                self.userLevelLabel.text = [NSString stringWithFormat:@" LV.%d", postList.topicInfo.postedBy.level];
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
                self.topicTitleLabel.text = postList.topicInfo.title;
                
                //正常刷新
                if (postList.limit > postList.postItems.count) {
                    self.noMoreData = YES;
                } else {
                    self.noMoreData = NO;
                }
                
                if (self.loadingStatus == LoadingStatusLoadingWithLoadingView
                    || self.loadingStatus == LoadingStatusLoadingWithRefreshView
                    || self.loadingStatus == LoadingStatusLoadingWithToastActivity) {
                    [_listItems removeAllObjects];
                }
                
                for (PostItem *item in postList.postItems) {
                    [_listItems addObject:item];
                }
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


- (void)deletePostButtonPressed:(UIButton*)sender {
    long row = sender.tag;
    NSString* postId = [_listItems objectAtIndex:row].id;
    NSString* url = [NSString stringWithFormat:@"post/%@", postId];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_listItems != nil) {
        return _listItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    PostItem* post = _listItems[indexPath.row];
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
    
    if (post.postedBy.photo != nil) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:post.postedBy.photo dimension:160 completionHandler:^(long statusCode, NSData *data) {
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
    
    cell.userNameLabel.text = post.postedBy.name;
    if (post.postedBy.gender.id == 2) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_male"];
    } else if (post.postedBy.gender.id == 3) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_female"];
    } else {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_no_gender"];
    }
    cell.userLevelLabel.text = [NSString stringWithFormat:@" LV.%d", post.postedBy.level];
    
    cell.deletePostButton.tag = indexPath.row;
    [cell.deletePostButton addTarget:self action:@selector(deletePostButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (post.deleteable) {
        cell.deletePostButton.hidden = NO;
    } else {
        cell.deletePostButton.hidden = YES;
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    cell.topicPostDateLabel.text = [dateFormatter stringFromDate:post.postDate];
    cell.nextPostContentLabel.text = post.content;
        
    
    [cell.imageStackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [cell.imageStackView removeArrangedSubview:obj];
        [obj removeFromSuperview];
    }];
    
    if (post.imageItems != nil && post.imageItems.count > 0) {
        float width = self.view.frame.size.width - 16;
        for (ImageItem* image in post.imageItems) {
            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_photo"]];
            [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [imageView.widthAnchor constraintEqualToConstant:width].active = YES;
            NSLayoutConstraint* constraint = [imageView.heightAnchor constraintEqualToConstant:width*image.height / image.width];//高度
            constraint.priority = 999;//优先级
            constraint.active = YES;
            imageView.clipsToBounds = YES;
            [cell.imageStackView addArrangedSubview:imageView];
            
            NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:image.name width:width completionHandler:^(long statusCode, NSData *data) {
                if (statusCode == 200) {
                    imageView.image = [UIImage imageWithData:data];
                }
            }];
            [cell.tasks addObject:task];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
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
    PostItem* postItem = [_listItems objectAtIndex:indexPath.row];
    if (postItem.imageItems != nil && postItem.imageItems.count > 0) {
        
        NSMutableArray* viewingImages = [NSMutableArray array];
        for (ImageItem* image in postItem.imageItems) {
            ViewingImage* viewingImage = [[ViewingImage alloc] init];
            viewingImage.imageName = image.name;
            [viewingImages addObject:viewingImage];
        }
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:viewingImages];
        photosViewController.delegate = self;
        [self presentViewController:photosViewController animated:YES completion:nil];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)photosViewController:(NYTPhotosViewController *)photosViewController maximumZoomScaleForPhoto:(id <NYTPhoto>)photo {
    return 2.0f;
}



#pragma mark - Keyboard notification

- (void)keyboardDidShow:(NSNotification *)sender {
    self.blockingViewTopConstraint.constant = 0;
    self.photoView.hidden = YES;
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.1f animations:^{
        self.postContentBottomConstraint.constant = frame.size.height - self.photoView.frame.size.height;
    }];
    CGSize sizeThatFitsTextView = [self.postContentTextView sizeThatFits:CGSizeMake(self.postContentTextView.frame.size.width, 100.0f)];
    self.postContentHeightConstraint.constant = MIN(sizeThatFitsTextView.height, 100.0f);
    
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    //    NSLog(@"%@", textView.text);
    
    CGSize sizeThatFitsTextView = [self.postContentTextView sizeThatFits:CGSizeMake(self.postContentTextView.frame.size.width, 100.0f)];
    self.postContentHeightConstraint.constant = MIN(sizeThatFitsTextView.height, 100.0f);
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    return YES;
}

#pragma mark - submit buttons

//监视遮挡view
- (IBAction)blockingViewTapped:(id)sender {
    self.blockingViewTopConstraint.constant = self.view.frame.size.height;
    [self.postContentTextView resignFirstResponder];
    self.postContentHeightConstraint.constant = 30;
    self.photoView.hidden = YES;
    self.postContentBottomConstraint.constant = -self.photoView.frame.size.height;
}



- (IBAction)pickPhotoButtonPressed:(id)sender {
    //反复点击会在照片与键盘之间切换
    if (self.photoView.hidden) {
        self.photoView.hidden = NO;
        [self.postContentTextView resignFirstResponder];
        self.blockingViewTopConstraint.constant = 0;
        [UIView animateWithDuration:0.1f animations:^{
            self.postContentBottomConstraint.constant = 0;
        }];
    } else {
        self.photoView.hidden = YES;
        [self.postContentTextView becomeFirstResponder];
    }
    
    
    countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 53, 21)];
    NSString* countString = [[NSString alloc]initWithFormat:@"%lu / 9",(unsigned long)_selectedAssets.count];
    [countLabel setText:countString];
    [countLabel setTextColor:[UIColor darkGrayColor]];
    countLabel.font = [UIFont systemFontOfSize:12];
    [_photoView addSubview:countLabel];
    
    UILabel* dragToMoveLabel = [[UILabel alloc]initWithFrame:CGRectMake(95, 135, 150, 21)];
    [dragToMoveLabel setText:@"长按图片可以拖动排序"];
    [dragToMoveLabel setTextColor:[UIColor darkGrayColor]];
    dragToMoveLabel.font = [UIFont systemFontOfSize:12];
    [_photoView addSubview:dragToMoveLabel];

    [self configCollectionView];
}

-(void)pickPhotoButtonClick {
    
    NSLog(@"picked Photo");
    [self configCollectionView];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    // Set the appearance
    // 在这里设置imagePickerVc的外观
    imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // Set allow picking video & photo & originalPhoto or not
    // 设置是否可以选择视频/图片/原图
    // imagePickerVc.allowPickingVideo = NO;
    // imagePickerVc.allowPickingImage = NO;
    // imagePickerVc.allowPickingOriginalPhoto = NO;
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _layout.itemCount = _selectedPhotos.count;
    [_collectionView reloadData];
    _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}


- (void)submitTopic {
    _uploadedImageCount++;
    if (_uploadedImageCount <= _selectedAssets.count) {
        PHAsset *asset = [_selectedAssets objectAtIndex:_uploadedImageCount - 1];
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageDataForAsset:asset options:_submitRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            NSLog(@"%@", [info objectForKey:@"PHImageFileURLKey"]);
            [[NetworkManager sharedManager] uploadImageWithUrl:@"upload/image" data:imageData completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
                if (statusCode == 200) {
                    NSError* error;
                    UploadImage* uploadImage = [[UploadImage alloc] initWithData:data error:&error];
                    if (error == nil) {
                        NSLog(@"%@", uploadImage);
                        [_selectedPhotos addObject:uploadImage.imageId];
                        [self submitTopic];
                    } else {
                        NSLog(@"%@", error);
                    }
                } else {
                    [self.view hideToastActivity];
                    [self.view makeToast:errorMessage];
                }
            }];
            
        }];
        
    } else {
        
        PostAdd* postAdd = [[PostAdd alloc] init];
        postAdd.topicId = self.topicId;
        postAdd.content = self.postContentTextView.text;
        postAdd.imageIds = [_selectedPhotos copy];
        
        [[NetworkManager sharedManager] putDataWithUrl:@"post" data:[postAdd toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
            [self.view hideToastActivity];
            if (statusCode == 200) {
                [_selectedAssets removeAllObjects];
                self.postContentTextView.text= nil;//清空输入内容
//                [self.photoView reloadData];
                self.blockingViewTopConstraint.constant = self.view.frame.size.height;
                [self.postContentTextView resignFirstResponder];
                self.postContentHeightConstraint.constant = 30;
                self.photoView.hidden = YES;
                self.postContentBottomConstraint.constant = -160;

                [self loadWithToastActivity];
                
            } else {
                [self.view makeToast:errorMessage];
            }
        }];
    }
}

//发送帖子
- (IBAction)submitPostButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    
    _uploadedImageCount = 0;
    [_selectedPhotos removeAllObjects];

    if (self.postContentTextView.text != nil && self.postContentTextView.text.length > 2) {
        [self.view makeToastActivity:CSToastPositionCenter];
        [self submitTopic];
    } else {
        [self.view makeToast:@"发帖内容不能为空"];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}


@end
