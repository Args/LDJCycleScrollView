//
//  ViewController.m
//  masony
//
//  Created by tih on 16/3/18.
//  Copyright © 2016年 TOSHIBA. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "LDJCycleScrollView.h"
#define kWidth      [UIScreen mainScreen].bounds.size.width
#define kHeight     [UIScreen mainScreen].bounds.size.height
@interface ViewController ()
@property LDJCycleScrollView *mainScorllView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mainScorllView = [LDJCycleScrollView
                       cycleScrollViewWithFrame:CGRectMake(0, 0, kWidth, 180)
                       images:@[[UIImage imageNamed:@"img1.jpg"],[UIImage imageNamed:@"img2.jpg"]]
                       titles:@[@"this is one ",@"this  is two"]
                       timeInterval:2
                       didSelect:^(NSInteger atIndex) {
                           NSLog(@"%ld",(long)atIndex);
                       }];
    
    [self.view addSubview:_mainScorllView];
    
    
    //添加约束
    UIView *superview = self.view;
    [_mainScorllView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        make.height.mas_equalTo(superview.mas_height).multipliedBy(0.3);
    }];
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [_mainScorllView rotateReload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
