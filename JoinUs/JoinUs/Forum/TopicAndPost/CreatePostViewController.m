//
//  CreatePostViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/5/16.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "CreatePostViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

#import "UIView+Layout.h"
#import "TZTestCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LxGridViewFlowLayout.h"
#import "TZImageManager.h"


@interface CreatePostViewController () {
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    int _uploadedImageCount;
    PHImageRequestOptions *_submitRequestOptions;
    
    CGFloat _itemWH;
    CGFloat _margin;
    LxGridViewFlowLayout *_layout;
    
}

@property (weak, nonatomic) IBOutlet UITextView *postContentTextView;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation CreatePostViewController {
    int temp;
    UILabel* countLabel;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.postAdd = [[PostAdd alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    temp=0;
}


//点击空白收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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



- (IBAction)pickPhotoButtonPressed:(id)sender {
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
        
        self.postAdd.topicId = self.topicId;
        self.postAdd.content = self.postContentTextView.text;
        self.postAdd.imageIds = [_selectedPhotos copy];
        
        [[NetworkManager sharedManager] putDataWithUrl:@"post" data:[self.postAdd toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
            [self.view hideToastActivity];
            if (statusCode == 200) {
                [self.navigationController popViewControllerAnimated:YES];

            } else {
                [self.view makeToast:errorMessage];
            }
        }];
    }
}


- (IBAction)submitButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    
    _uploadedImageCount = 0;
    [_selectedPhotos removeAllObjects];
    [self submitTopic];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
