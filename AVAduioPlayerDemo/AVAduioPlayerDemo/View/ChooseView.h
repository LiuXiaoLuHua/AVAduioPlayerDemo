//
//  ChooseView.h
//  ButterflyPopChooseView
//
//  Created by XiangTaiMini on 2016/11/28.
//  Copyright © 2016年 YueHuaHu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseViewDelegate <NSObject>

@optional
-(void)chooseCard:(NSString *)cardStyle;

@end
@interface ChooseView : UIView

@property (nonatomic , weak) id <ChooseViewDelegate> delegate;
/**
 *  需要指向的目标view
 */
@property (nonatomic , strong) UIView *targetView;
/**
 *  内容数据，
 */
@property (nonatomic , strong) NSArray *contents;
/**
 *  显示
 */
-(void)show;

@end
