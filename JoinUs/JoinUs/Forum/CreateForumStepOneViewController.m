//
//  CreateForumStepOneViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/4/23.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "CreateForumStepOneViewController.h"
#import "NetworkManager.h"
#import "CreateFroumStepTwoViewController.h"

@interface CreateForumStepOneViewController ()
@property (weak, nonatomic) IBOutlet UITextField *forumNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextField *forumSeconTextField;

@end

@implementation CreateForumStepOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.forumAdd = [[ForumAdd alloc]init];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* proposedtext = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.forumNameTextField) {
        if ((proposedtext.length >= 3 && proposedtext.length <= 16) || proposedtext.length == 0) {
            self.forumNameTextField.layer.borderColor = [UIColor greenColor].CGColor;
            self.forumNameTextField.layer.borderWidth = 1;
            self.forumNameTextField.layer.cornerRadius = 5;
        } else {
            self.forumNameTextField.layer.borderColor = [UIColor redColor].CGColor;
            self.forumNameTextField.layer.borderWidth = 1;
            self.forumNameTextField.layer.cornerRadius = 5;
        }
    } else if (textField == self.forumSeconTextField) {
        if (proposedtext.length >= 3 && proposedtext.length <= 100) {
            self.forumSeconTextField.layer.borderColor = [UIColor greenColor].CGColor;
            self.forumSeconTextField.layer.borderWidth = 1;
            self.forumSeconTextField.layer.cornerRadius = 5;
        } else {
            self.forumSeconTextField.layer.borderColor = [UIColor redColor].CGColor;
            self.forumSeconTextField.layer.borderWidth = 1;
            self.forumSeconTextField.layer.cornerRadius = 5;
        }
    }
    
    return YES;
}

- (IBAction)nextStepButtonPressed:(id)sender {
    
    if (self.forumAdd == nil) {
        self.forumAdd = [[ForumAdd alloc] init];
    }
    self.forumAdd.name = self.forumNameTextField.text;
    self.forumAdd.desc = self.forumSeconTextField.text;
    
    [self performSegueWithIdentifier:@"PushTwo" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushTwo"]) {
        
        CreateFroumStepTwoViewController* createForumStepTwoViewController = segue.destinationViewController;
        createForumStepTwoViewController.forumAdd = self.forumAdd;
    }
}

@end
