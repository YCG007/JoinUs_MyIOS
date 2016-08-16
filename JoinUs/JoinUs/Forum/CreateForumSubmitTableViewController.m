//
//  CreateForumSubmitTableViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/4/23.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "CreateForumSubmitTableViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface CreateForumSubmitTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation CreateForumSubmitTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.submitButton.layer.cornerRadius = 5;
    
    self.nameLabel.text = self.forumAdd.name;
    self.descLabel.text = self.forumAdd.desc;
    self.logoImageView.image = self.forumAdd.iconImage;

    self.categoryLabel.text = @"";
    for (Category* category in self.categories) {
        if (category.selected != nil) {
            self.categoryLabel.text = [NSString stringWithFormat:@"%@ %@ %@", self.categoryLabel.text,  @" ", category.name];//此处我用换行符就不能显示
        }
    }
}
- (IBAction)submitButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    
    NSData* imageData = UIImageJPEGRepresentation(self.forumAdd.iconImage, 0.9);
    [[NetworkManager sharedManager] uploadImageWithUrl:@"upload/image" data:imageData completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            UploadImage* uploadImage = [[UploadImage alloc] initWithData:data error:&error];
            self.forumAdd.iconImageId = uploadImage.imageId;
            
            [[NetworkManager sharedManager] putDataWithUrl:@"forum" data:[self.forumAdd toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
                [self.view hideToastActivity];
                if (statusCode == 200) {
                    //                    [self performSegueWithIdentifier:@"UnwindToForumHome" sender:self];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    [self.view makeToast:errorMessage];
                }
            }];
            
        } else {
            [self.view hideToastActivity];
            [self.view makeToast:errorMessage];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
