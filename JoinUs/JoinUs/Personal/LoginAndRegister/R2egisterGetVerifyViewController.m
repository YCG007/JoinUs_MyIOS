//
//  R2egisterGetVerifyViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/4/16.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "R2egisterGetVerifyViewController.h"
#import "NetworkManager.h"
#import "Utils.h"

@interface R2egisterGetVerifyViewController ()
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVerifyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

static NSTimer* kTimer = nil;
static int kCountDown = 0;

@implementation R2egisterGetVerifyViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // button round corner
    self.getVerifyCodeButton.layer.cornerRadius = 3;
    self.loginButton.layer.cornerRadius = 5;
    
    // disable submit button
    self.getVerifyCodeButton.enabled = NO;
    self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
//    self.loginButton.enabled = NO;
//    self.loginButton.backgroundColor = [UIColor lightGrayColor];
    
    if (kTimer != nil) {
        [kTimer invalidate];
        kTimer = nil;
        kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
        [self onTick];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField == self.mobileTextField){
        NSString* proposedtext = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (proposedtext.length < 11) {
            self.getVerifyCodeButton.enabled = NO;
            self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
        } else if (proposedtext.length == 11) {
            self.getVerifyCodeButton.enabled = YES;
            self.getVerifyCodeButton.backgroundColor = [UIColor colorWithRGBValue:0x88c43f];
        } else if (proposedtext.length > 11) {
            return NO;
        }
        return YES;
    } else if(textField == self.verifyCodeTextField){
        NSString* text = textField.text;
        if (range.length > 0) {
            text = [text substringToIndex:(text.length - range.length)];
        } else {
            text = [text stringByAppendingString:string];
        }
        if (text.length < 6) {
            self.loginButton.enabled = NO;
            self.loginButton.backgroundColor = [UIColor lightGrayColor];
        } else if (text.length == 6) {
            self.loginButton.enabled = YES;
            self.loginButton.backgroundColor = [UIColor colorWithRGBValue:0x88c43f];
        } else if (text.length > 6) {
            return NO;
        }
        return YES;
    }
    return NO;
    
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
        [self.getVerifyCodeButton setTitle:[NSString stringWithFormat:@"重新获取(%ds)", kCountDown] forState:UIControlStateDisabled];
        self.getVerifyCodeButton.enabled = NO;
        self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    } else if (kCountDown == 0) {
        [self.getVerifyCodeButton setTitle:[NSString stringWithFormat:@"获取验证码"] forState:UIControlStateNormal];
        self.getVerifyCodeButton.enabled = YES;
        self.getVerifyCodeButton.backgroundColor = [UIColor colorWithRGBValue:0x00bbd5];
        
        [kTimer invalidate];
        kTimer = nil;
    }
}

- (IBAction)getVerifyCodeButtonPressed:(id)sender {
    self.getVerifyCodeButton.enabled = NO;
    self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    kCountDown = 60;
    if (kTimer == nil) {
        kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    }
    
    [self.view makeToastActivity:CSToastPositionCenter];
    NSString* url = [NSString stringWithFormat:@"login/mobile/%@", self.mobileTextField.text];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            NSError* error;
            Message* msg = [[Message alloc] initWithData:data error:&error];
            if (error == nil) {
                [self.view makeToast:msg.message];
            } else {
                NSLog(@"JSON parsing error: %@", error);
            }
        } else {
            [self.view makeToast:errorMessage];
        }
    }];

}
- (IBAction)loginButtonPressed:(id)sender {
    
    if (self.mobileTextField.text.length < 11 || self.verifyCodeTextField.text.length != 6) {
        [self.view makeToast:@"请输入有效的手机号码与验证码"];
        return;
    }
    
    MobileVerifyCode* mobileVerifyCode = [[MobileVerifyCode alloc] init];
    mobileVerifyCode.mobile = self.mobileTextField.text;
    mobileVerifyCode.verifyCode = self.verifyCodeTextField.text;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] postDataWithUrl:@"login/mobile/verifyCode" data:[mobileVerifyCode toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            //            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //            NSLog(@"Response body: %@", responseBody);
            NSError* error;
            UserProfileWithToken* userProfileWithToken = [[UserProfileWithToken alloc] initWithData:data error:&error];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation


@end
