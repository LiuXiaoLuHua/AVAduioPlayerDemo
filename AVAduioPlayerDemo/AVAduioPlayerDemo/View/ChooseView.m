//
//  ChooseView.m
//  ButterflyPopChooseView
//
//  Created by XiangTaiMini on 2016/11/28.
//  Copyright © 2016年 YueHuaHu. All rights reserved.
//

#import "ChooseView.h"

@interface ChooseView ()
/**
 *  遮盖view
 */
@property (nonatomic , weak) UIView *coverView;

@end

@implementation ChooseView

{
    CGFloat _rowHeight; // 一行的高度
}

-(void)setContents:(NSArray *)contents {
    _contents = contents;
}
-(void)setTargetView:(UIView *)targetView {
    _targetView = targetView;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    // 将rect由rect所在视图转换到目标视图View上
    CGRect rect = [targetView convertRect:targetView.bounds toView:window];
    // - (CGRect)convertRect:(CGRect)rect fromView:(UIView *)view; 将rect从view中转换到当前视图中，返回在当前试图的rect
    _rowHeight = rect.size.height;
//    self.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, (rect.size.height + 0.5) * _contents.count); 展示在下方
    self.frame = CGRectMake(rect.origin.x, rect.origin.y - rect.size.height * _contents.count, rect.size.width, (rect.size.height + 0.5) * _contents.count); // 展示在上方
    [self loadUI];
    
}
-(void)loadUI {
    self.backgroundColor = [UIColor whiteColor];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *coverView = [[UIView alloc] initWithFrame:window.bounds];
    [window addSubview:coverView];
    self.coverView = coverView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTap:)];
    [self.coverView addGestureRecognizer:tap];
    
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, self.frame.size.height)];
    leftLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:leftLine];
    
    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 0.5, 0, 0.5, self.frame.size.height)];
    rightLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:rightLine];

    for (int i = 0; i < self.contents.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, i * _rowHeight, self.frame.size.width, _rowHeight);
        [btn setTitle:self.contents[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.size.height, self.frame.size.width, 0.5)];
        sepLine.backgroundColor = [UIColor lightGrayColor];
        [btn addSubview:sepLine];
    }
}
-(void)btnClick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseCard:)]) {
        [self.delegate chooseCard:button.titleLabel.text];
    }
    [self dismiss];
    
}
-(void)show {
    [self.coverView addSubview:self];
}
-(void)dismiss {
    [self.coverView removeFromSuperview];
    [self removeFromSuperview];
    
}
-(void)coverViewTap:(UITapGestureRecognizer *)tap {
    [self dismiss];
}
@end
