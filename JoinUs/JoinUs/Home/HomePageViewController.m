//
//  HomePageViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/8/15.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "HomePageViewController.h"
#import "DWBubbleMenuButton.h"
#import "FFNavbarMenu.h"
#import "SKSplashIcon.h"
#import "DGAaimaView.h"

@interface HomePageViewController ()< FFNavbarMenuDelegate>

@property (strong, nonatomic) SKSplashView *splashView;
//Demo of how to add other UI elements on top of splash view
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (assign, nonatomic) NSInteger numberOfItemsInRow;
@property (strong, nonatomic) FFNavbarMenu *menu;

@property (nonatomic , strong) DWBubbleMenuButton *dingdingAnimationMenu;

@end

@implementation HomePageViewController{
    DGAaimaView *animaView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //开始加载类似twitter动画
    [self twitterSplash];
    
    //菜单按钮
    self.numberOfItemsInRow = 3;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStylePlain target:self action:@selector(openMenu:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    //加载仿造钉钉动画
//    [self dingdingAnimation];
}


/**
 *  仿造钉钉菜单动画
 */
//-(void)dingdingAnimation{
//    
//    if (!_dingdingAnimationMenu) {
//        UILabel *homeLabel = [self createHomeButtonView];
//        
//        DWBubbleMenuButton *upMenuView = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - homeLabel.frame.size.width - 20.f,
//                                                                                              self.view.frame.size.height - homeLabel.frame.size.height-60.0f,
//                                                                                              homeLabel.frame.size.width,
//                                                                                              homeLabel.frame.size.height)
//                                                                expansionDirection:DirectionUp];
//        upMenuView.homeButtonView = homeLabel;
//        [upMenuView addButtons:[self createDemoButtonArray]];
//        
//        _dingdingAnimationMenu = upMenuView;
//        
//        [self.view addSubview:upMenuView];
//    }else{
//        _dingdingAnimationMenu.hidden = NO;
//    }
//}
//
//- (UILabel *)createHomeButtonView {
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
//    
//    label.text = @"Tap";
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.layer.cornerRadius = label.frame.size.height / 2.f;
//    label.backgroundColor =[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
//    label.clipsToBounds = YES;
//    
//    return label;
//}
//
//- (NSArray *)createDemoButtonArray {
//    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
//    
//    int i = 0;
//    for (NSString *title in @[@"A", @"B", @"C", @"D", @"E", @"F"]) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//        
//        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [button setTitle:title forState:UIControlStateNormal];
//        
//        button.frame = CGRectMake(0.f, 0.f, 30.f, 30.f);
//        button.layer.cornerRadius = button.frame.size.height / 2.f;
//        button.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
//        button.clipsToBounds = YES;
//        button.tag = i++;
//        
//        [button addTarget:self action:@selector(dwBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [buttonsMutable addObject:button];
//    }
//    
//    return [buttonsMutable copy];
//}
//
//- (void)dwBtnClick:(UIButton *)sender {
//    NSLog(@"DWButton tapped, tag: %ld", (long)sender.tag);
//}



//下拉菜单
- (FFNavbarMenu *)menu {
    if (_menu == nil) {
        FFNavbarMenuItem *item1 = [FFNavbarMenuItem ItemWithTitle:@"时间" icon:[UIImage imageNamed:@"0"]];
        FFNavbarMenuItem *item2 = [FFNavbarMenuItem ItemWithTitle:@"文件" icon:[UIImage imageNamed:@"1"]];
        FFNavbarMenuItem *item3 = [FFNavbarMenuItem ItemWithTitle:@"主页" icon:[UIImage imageNamed:@"2"]];
        FFNavbarMenuItem *item4 = [FFNavbarMenuItem ItemWithTitle:@"位置" icon:[UIImage imageNamed:@"3"]];
        FFNavbarMenuItem *item5 = [FFNavbarMenuItem ItemWithTitle:@"标签" icon:[UIImage imageNamed:@"4"]];
        FFNavbarMenuItem *item6 = [FFNavbarMenuItem ItemWithTitle:@"信息" icon:[UIImage imageNamed:@"5"]];
        
        
        
        _menu = [[FFNavbarMenu alloc] initWithItems:@[item1,item2,item3,item4,item5,item6] width:300 maximumNumberInRow:_numberOfItemsInRow];
        _menu.backgroundColor = [UIColor whiteColor];
        _menu.separatarColor = [UIColor lightGrayColor];
        _menu.textColor = [UIColor blackColor];
        _menu.delegate = self;
    }
    return _menu;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.menu) {
        [self.menu dismissWithAnimation:NO];
    }
}

- (void)openMenu:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
    } else {
        [self.menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(FFNavbarMenu *)menu {
    [self.navigationItem.rightBarButtonItem setTitle:@"收起"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(FFNavbarMenu *)menu {
    [self.navigationItem.rightBarButtonItem setTitle:@"菜单"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(FFNavbarMenu *)menu atIndex:(NSInteger)index {
    //    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"你点击了" message:[NSString stringWithFormat:@"item%@", @(index+1)] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    //    [av show];
    NSLog(@"item = %@",@(index+1));
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.menu = nil;
}


//刚进入页面模仿twitter
#pragma mark - Twitter Example

- (void) twitterSplash
{
    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"twitterIcon.png"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor colorWithRed:0.25098 green:0.6 blue:1.0 alpha:1.0];
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon backgroundColor:twitterColor animationType:SKSplashAnimationTypeNone];
    _splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    _splashView.animationDuration = 3.2; //Optional -> set animation duration. Default: 1s
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
}

#pragma mark - Delegate methods (Optional)

- (void) splashView:(SKSplashView *)splashView didBeginAnimatingWithDuration:(float)duration
{
    //刚进入时把下面的tabBar和上面的navigationBar给隐藏
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    
    NSLog(@"Started animating from delegate");
    //To start activity animation when splash animation starts
    [_indicatorView startAnimating];
}

- (void) splashViewDidEndAnimating:(SKSplashView *)splashView
{
    //结束后把下面的tabBar和上面的navigationBar给显现
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    //加载首页动画
    //引入文件  用下面的方法控制各个空间的速度
    animaView = [[DGAaimaView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:animaView];
    [animaView DGAaimaView:animaView BigCloudSpeed:1.5 smallCloudSpeed:1 earthSepped:1.0 huojianSepped:2.0 littleSpeed:2];
    
    NSLog(@"Stopped animating from delegate");
    //To stop activity animation when splash animation ends
    [_indicatorView stopAnimating];
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
