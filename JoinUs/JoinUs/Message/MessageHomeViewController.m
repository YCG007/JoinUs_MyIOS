//
//  MessageHomeViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/8/5.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "MessageHomeViewController.h"

@interface MessageHomeViewController ()

@end

@implementation MessageHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)goToChatItemButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"PushChatRoom" sender:self];
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
