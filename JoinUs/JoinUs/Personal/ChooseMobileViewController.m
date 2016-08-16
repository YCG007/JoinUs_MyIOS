//
//  ChooseMobileViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/4/16.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "ChooseMobileViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface ChooseMobileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *oldMobileLabel;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *resendVerifyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *registerSubmitButton;

@end

static NSTimer* kTimer = nil;
static int kCountDown = 0;

@implementation ChooseMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resendVerifyCodeButton.layer.cornerRadius = 5;
    self.registerSubmitButton.layer.cornerRadius = 5;
    
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    self.oldMobileLabel.text = myProfile.mobile;
    
    if (kTimer != nil) {
        [kTimer invalidate];
        kTimer = nil;
        kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
        [self onTick];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)onTick {
    NSLog(@"Tick!");
    
    if (kCountDown > 0) {
        //不闪
        [UIView setAnimationsEnabled:NO];
        
        kCountDown--;
        [self.resendVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新获取(%ds)", kCountDown] forState:UIControlStateDisabled];
        self.resendVerifyCodeButton.enabled = NO;
        self.resendVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    } else if (kCountDown == 0) {
        [self.resendVerifyCodeButton setTitle:[NSString stringWithFormat:@"获取验证码"] forState:UIControlStateNormal];
        self.resendVerifyCodeButton.enabled = YES;
        self.resendVerifyCodeButton.backgroundColor = [UIColor colorWithRGBValue:0x00bbd5];
        
        [kTimer invalidate];
        kTimer = nil;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* text = textField.text;
    if (range.length > 0) {
        text = [text substringToIndex:(text.length - range.length)];
    } else {
        text = [text stringByAppendingString:string];
    }
    //    NSLog(@"Range location: %ld, length: %ld, string: %@, text: %@, will be: %@", range.location, range.length, string, textField.text, text);
    if (text.length < 6) {
        self.registerSubmitButton.enabled = NO;
        self.registerSubmitButton.backgroundColor = [UIColor lightGrayColor];
    } else if (text.length == 6) {
        self.registerSubmitButton.enabled = YES;
        self.registerSubmitButton.backgroundColor = [UIColor colorWithRGBValue:0x88c43f];
    } else if (text.length > 6) {
        return NO;
    }
    return YES;
}
- (IBAction)resendVerifyCodeButtonPressed:(id)sender {
    kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    
    self.resendVerifyCodeButton.enabled = NO;
    self.resendVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    kCountDown = 60;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    NSString* url = [NSString stringWithFormat:@"myProfile/mobileVerifyCode"];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            Message* msg = [[Message alloc] initWithData:data error:nil];
            
            [self.view makeToast:msg.message duration:1.0f position:CSToastPositionCenter];
            
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}
- (IBAction)registerSubmitButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    
    MobileVerifyCode* mobileVerifyCode = [[MobileVerifyCode alloc] init];
    mobileVerifyCode.mobile = self.oldMobileLabel.text;
    mobileVerifyCode.verifyCode = self.verifyCodeTextField.text;
    
    [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/verifyMobile" data:[mobileVerifyCode toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            NSError* error;
            UserProfileWithToken* userProfileWithToken = [[UserProfileWithToken alloc] initWithData:data error:&error];
            
            Message* msg = [[Message alloc] initWithData:data error:nil];
            [self.view makeToast:msg.message duration:1.0f position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                [self performSegueWithIdentifier:@"GoToNewMobile" sender:self];
            }];
            if (error == nil) {
                [[NetworkManager sharedManager] setMyProfile:[userProfileWithToken userProfile]];
                [[NetworkManager sharedManager] setToken:[userProfileWithToken userToken]];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"JSON parsing error: %@", error);
            }
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
