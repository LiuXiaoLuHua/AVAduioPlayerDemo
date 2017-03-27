//
//  ViewController.m
//  AVAduioPlayerDemo
//
//  Created by XiangTaiMini on 2017/3/23.
//  Copyright © 2017年 Butterfly. All rights reserved.
//

#import "ViewController.h"
#import "RingPlayCustomProgressView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    RingPlayCustomProgressView *progressView = [[RingPlayCustomProgressView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:progressView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
