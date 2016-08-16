//
//  RegisterGetVerifyCodeViewController.m
//  JoinUs
//
//  Created by Liang Qian on 21/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "RegisterGetVerifyCodeViewController.h"
#import "NetworkManager.h"
#import "Utils.h"


@interface RegisterGetVerifyCodeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVerifyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

static NSTimer* kTimer = nil;
static int kCountDown = 0;

@implementation RegisterGetVerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // button round corner
    self.getVerifyCodeButton.layer.cornerRadius = 3;
    self.submitButton.layer.cornerRadius = 5;
    
    // disable submit button
//    self.getVerifyCodeButton.enabled = NO;
//    self.getVerifyCodeButton.backgroundColor = [UIColor lightGrayColor];
    
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
            self.submitButton.enabled = NO;
            self.submitButton.backgroundColor = [UIColor lightGrayColor];
        } else if (text.length == 6) {
            self.submitButton.enabled = YES;
            self.submitButton.backgroundColor = [UIColor colorWithRGBValue:0x88c43f];
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
    NSString* url = [NSString stringWithFormat:@"register/mobile/%@", self.mobileTextField.text];
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
- (IBAction)submitButtonPressed:(id)sender {
    
    if (self.mobileTextField.text.length < 11 || self.verifyCodeTextField.text.length != 6) {
        [self.view makeToast:@"请输入有效的手机号码与验证码"];
        return;
    }
    
    MobileVerifyCode* mobileVerifyCode = [[MobileVerifyCode alloc] init];
    mobileVerifyCode.mobile = self.mobileTextField.text;
    mobileVerifyCode.verifyCode = self.verifyCodeTextField.text;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] putDataWithUrl:@"register/mobile" data:[mobileVerifyCode toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
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
- (IBAction)registerWithEmailButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RegisterWithEmail"] animated:YES];
}

- (IBAction)showAgreementButtonPressed:(id)sender {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

@end

//kCFURLErrorUnknown   = -998,
//kCFURLErrorCancelled = -999,
//kCFURLErrorBadURL    = -1000,
//kCFURLErrorTimedOut  = -1001,
//kCFURLErrorUnsupportedURL = -1002,
//kCFURLErrorCannotFindHost = -1003,
//kCFURLErrorCannotConnectToHost    = -1004,
//kCFURLErrorNetworkConnectionLost  = -1005,
//kCFURLErrorDNSLookupFailed        = -1006,
//kCFURLErrorHTTPTooManyRedirects   = -1007,
//kCFURLErrorResourceUnavailable    = -1008,
//kCFURLErrorNotConnectedToInternet = -1009,
//kCFURLErrorRedirectToNonExistentLocation = -1010,
//kCFURLErrorBadServerResponse             = -1011,
//kCFURLErrorUserCancelledAuthentication   = -1012,
//kCFURLErrorUserAuthenticationRequired    = -1013,
//kCFURLErrorZeroByteResource        = -1014,
//kCFURLErrorCannotDecodeRawData     = -1015,
//kCFURLErrorCannotDecodeContentData = -1016,
//kCFURLErrorCannotParseResponse     = -1017,
//kCFURLErrorInternationalRoamingOff = -1018,
//kCFURLErrorCallIsActive               = -1019,
//kCFURLErrorDataNotAllowed             = -1020,
//kCFURLErrorRequestBodyStreamExhausted = -1021,
//kCFURLErrorFileDoesNotExist           = -1100,
//kCFURLErrorFileIsDirectory            = -1101,
//kCFURLErrorNoPermissionsToReadFile    = -1102,
//kCFURLErrorDataLengthExceedsMaximum   = -1103,
