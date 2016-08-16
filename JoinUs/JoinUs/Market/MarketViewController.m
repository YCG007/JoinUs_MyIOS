//
//  MarketViewController.m
//  JoinUs
//
//  Created by 杨春贵 on 16/7/18.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//
#import "MarketViewController.h"

@interface MarketViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation MarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //自适应高度
//    CGFloat scrollViewHeight = 0.0f;for (UIView* view in self.scrollView.subviews){ scrollViewHeight += view.frame.size.height;}[self.scrollView setContentSize:(CGSizeMake(self.view.frame.size.width, scrollViewHeight))];
    
//    self.scrollView.contentSize = self.view.bounds.size;

    //设置在拖拽的时候是否锁定其在水平或者垂直的方向
//    self.scrollView.directionalLockEnabled = NO;
//    //隐藏滚动条设置（水平、跟垂直方向）
//    self.scrollView.alwaysBounceHorizontal = NO;
//    self.scrollView.alwaysBounceVertical = NO;
//    self.scrollView.showsHorizontalScrollIndicator = NO;
//    self.scrollView.showsVerticalScrollIndicator = NO;
//    //设置滚动视图的位置
//    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.webView.frame.size.height+self.myView.frame.size.height)];
    
    //webView
    _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 0)];
    _webView.delegate = self;
    _webView.scrollView.bounces = NO;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.scrollEnabled = NO;
    [_webView sizeToFit];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView Delegate Methods
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //获取到webview的高度
    CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    self.webView.frame = CGRectMake(self.webView.frame.origin.x,self.webView.frame.origin.y, self.view.frame.size.width, height);
//    [self.tableView reloadData];
//    [self viewDidLoad];
    NSLog(@"webViewHeight = %f",self.webView.frame.size.height);
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
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
