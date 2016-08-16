//
//  MyProfileTableViewController.m
//  JoinUs
//
//  Created by Liang Qian on 31/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "CustomIOSAlertView.h"

@interface MyProfileTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *registerDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (nonatomic) UIPickerView* genderPickView;
@property (nonatomic) NSArray *gender;

@end

@implementation MyProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logoutButton.layer.cornerRadius = 5;
    
    _gender = @[@"保密",@"男",@"女"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    //把下面的tabBar给隐藏
    self.tabBarController.tabBar.hidden = YES;
    
    [super viewWillAppear:animated];
    [self loadData];
}


- (void)loadData {
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    if (myProfile.photo) {
        [[NetworkManager sharedManager] getResizedImageWithName:myProfile.photo dimension:80 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                self.photoImageView.image = [UIImage imageWithData:data];
            }
        }];
    } else {
        self.photoImageView.image = [UIImage imageNamed:@"no_photo"];
    }
    self.nameLabel.text = myProfile.name;
    self.mobileLabel.text = myProfile.mobile ? myProfile.mobile : @"未设置";
    self.emailLabel.text = myProfile.email ? myProfile.email : @"未设置";
    self.genderLabel.text = myProfile.gender.name;
    self.cityLabel.text = myProfile.city ? [NSString stringWithFormat:@"%@ %@", myProfile.city.province.name, myProfile.city.name] : @"未设置";
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    self.lastUpdateDateLabel.text = [dateFormatter stringFromDate:myProfile.lastUpdateDate];
    self.registerDateLabel.text = [dateFormatter stringFromDate:myProfile.registerDate];
}


- (IBAction)logoutButtonPressed:(id)sender {
    [[NetworkManager sharedManager] logout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)chooseMobileTapPressed:(id)sender {
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    if (myProfile.mobile == nil) {
//        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"UpdataMobile"] animated:YES];
    } else {
        [self performSegueWithIdentifier:@"GoToOldMobile" sender:self];
    }
}

- (IBAction)chooseEmailTapPressed:(id)sender {
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    if (myProfile.email == nil) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"UpdataEmail"] animated:YES];
    } else {
        [self performSegueWithIdentifier:@"GoToOldEmail" sender:self];
    }
}

- (IBAction)chooseGenderTapPressed:(id)sender {
    CustomIOSAlertView* alertView = [[CustomIOSAlertView alloc]init];
    self.genderPickView = [[UIPickerView alloc]init];
    self.genderPickView.delegate = self;
    
    [alertView setContainerView:self.genderPickView];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"确定", nil]];
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if(buttonIndex == 0){
            UserGender* userGender = [[UserGender alloc]init];
            userGender.genderId = (int)[self.genderPickView selectedRowInComponent:0]+(int)1;
            
            [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/gender" data:[userGender toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
                if (statusCode == 200) {
                    NSError* error;
                    UserProfile* myProfile = [[UserProfile alloc] initWithData:data error:&error];
                    
                    if (error == nil) {
                        
                        [[NetworkManager sharedManager]setMyProfile:myProfile];
                        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
                        [self loadData];
                    } else {
                        NSLog(@"JSON parsing error: %@", error);
                    }
                    
                    
                } else  {
                    [self.view makeToast:errorMessage];
                }
            }];
        } else {
            
        }
        
        [alertView close];
    }];
    
    [alertView show];
}

-(NSInteger)numberOfComponentsInPickView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _gender.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *userGender = _gender[row];
    return userGender;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 10;
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - Navigation

- (IBAction)unwindToMyProfile:(UIStoryboardSegue*)sender
{
    // UIViewController *sourceViewController = sender.sourceViewController;
    // Pull any data from the view controller which initiated the unwind segue.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
