//
//  CoreAnimationViewController.m
//  JoinUs
//
//  Created by Liang Qian on 14/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CoreAnimationViewController.h"
#import "DGAaimaView.h"

@interface CoreAnimationViewController ()

@end

@implementation CoreAnimationViewController{
    DGAaimaView *animaView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //引入文件  用下面的方法控制各个空间的速度
    
    animaView = [[DGAaimaView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:animaView];
    [animaView DGAaimaView:animaView BigCloudSpeed:1.5 smallCloudSpeed:1 earthSepped:1.0 huojianSepped:2.0 littleSpeed:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
