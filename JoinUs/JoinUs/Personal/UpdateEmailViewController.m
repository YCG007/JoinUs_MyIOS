//
//  UpdateEmailViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/4/16.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "UpdateEmailViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

static const CGFloat kPullDownListIndent = 8;
static const CGFloat kPullDownListWidthRatio = 0.9;

@interface UpdateEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *resendVerifyCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *registerSubmitButton;

@end

static NSTimer* kTimer = nil;
static int kCountDown = 0;

@implementation UpdateEmailViewController{
    UITableView* _tableView;
    CGRect _emailFrame;
    NSArray* _emailSuffix;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.registerSubmitButton.layer.cornerRadius = 5;
    
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    self.emailTextField.text = myProfile.email;
    
    _emailSuffix = @[@"", @"@163.com", @"@126.com", @"@gmail.com", @"@qq.com", @"@outlook.com"];
    
    _emailTextField.delegate = self;
    //注册编辑内容发生改变事件
    [_emailTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
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
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValidate = [emailTest evaluateWithObject:self.emailTextField.text];
    
    if (isValidate == NO) {
        self.registerSubmitButton.enabled = NO;
        self.registerSubmitButton.backgroundColor = [UIColor lightGrayColor];
    } else if (isValidate == YES) {
        self.registerSubmitButton.enabled = YES;
        self.registerSubmitButton.backgroundColor = [UIColor colorWithRGBValue:0x88c43f];
    }
    return YES;
}
- (IBAction)resendVerifyCodeButtonPressed:(id)sender {
    kTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    
    self.registerSubmitButton.enabled = NO;
    self.registerSubmitButton.backgroundColor = [UIColor lightGrayColor];
    kCountDown = 60;
    
    [self.view makeToastActivity:CSToastPositionCenter];
    NSString* url = [NSString stringWithFormat:@"myProfile/updateEmailVerifyCode/%@", self.emailTextField.text];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            Message* msg = [[Message alloc] initWithData:data error:nil];
            
            [self.view makeToast:msg.message duration:1.0f position:CSToastPositionCenter];
            
        } else  {
            [self.view makeToast:errorMessage];
        }
    }];
}

- (IBAction)registerSubmitButtonPressed:(id)sender {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValidate = [emailTest evaluateWithObject:self.emailTextField.text];
    
    if(isValidate){
        EmailVerifyCode* userEmail = [[EmailVerifyCode alloc]init];
        userEmail.email = self.emailTextField.text;
        [[NetworkManager sharedManager] postDataWithUrl:@"myProfile/email" data:[userEmail toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
            [self.view hideToastActivity];
            if (statusCode == 200) {
                NSError* error;
                UserProfileWithToken* userProfileWithToken = [[UserProfileWithToken alloc] initWithData:data error:&error];
                
                UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
                myProfile.email = self.emailTextField.text;

                [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
                if (error == nil) {
                    [[NetworkManager sharedManager] setMyProfile:[userProfileWithToken userProfile]];
                    [[NetworkManager sharedManager] setToken:[userProfileWithToken userToken]];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    NSLog(@"JSON parsing error: %@", error);
                }
                
                
            } else  {
                [self.view makeToast:errorMessage];
            }
        }];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _emailFrame = _emailTextField.frame;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.emailTextField resignFirstResponder];
}



#pragma mark TextField
- (IBAction)textFieldEditingChanged:(id)sender {
    if (_tableView != nil) {
        [_tableView reloadData];
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(_emailFrame.origin.x + kPullDownListIndent, _emailFrame.origin.y + _emailFrame.size.height, _emailFrame.size.width * kPullDownListWidthRatio, 0) style:UITableViewStylePlain];
    _tableView.layer.borderWidth = 1;
    _tableView.layer.cornerRadius = 5;
    _tableView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [UIView animateWithDuration:0.5f animations:^{
        _tableView.frame = CGRectMake(_emailFrame.origin.x + kPullDownListIndent, _emailFrame.origin.y + _emailFrame.size.height, _emailFrame.size.width * kPullDownListWidthRatio, _emailFrame.size.height * 6);
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5f animations:^{
        _tableView.frame = CGRectMake(_emailFrame.origin.x + kPullDownListIndent, _emailFrame.origin.y + _emailFrame.size.height, _emailFrame.size.width * kPullDownListWidthRatio, 0);
    } completion:^(BOOL finished) {
        [_tableView removeFromSuperview];
    }];
}


#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_emailSuffix count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _emailFrame.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (self.emailTextField.text == nil || [self.emailTextField.text isEqual:@""]) {
        cell.textLabel.text = @"";
    } else {
        NSRange range = [_emailTextField.text rangeOfString:@"@"];
        //        NSLog(@"%lu %lu", (unsigned long)range.location, (unsigned long)range.length);
        if (range.location > 0 && range.length == 1) {
            if (indexPath.row == 0) {
                cell.textLabel.text = [self.emailTextField.text stringByAppendingString:_emailSuffix[indexPath.row]];
            } else {
                cell.textLabel.text = [[_emailTextField.text substringToIndex:range.location] stringByAppendingString:_emailSuffix[indexPath.row]];
            }
        } else {
            cell.textLabel.text = [self.emailTextField.text stringByAppendingString:_emailSuffix[indexPath.row]];
        }
    }
    cell.textLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"%@", indexPath);
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.emailTextField.text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    //    [self textFieldValueChanged];
    [_tableView removeFromSuperview];
}

@end
