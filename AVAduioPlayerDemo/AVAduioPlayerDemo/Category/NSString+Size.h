//
//  NSString+size.h
//  MeiTuan
//
//  Created by 何凯楠 on 16/6/20.
//  Copyright © 2016年 HeXiaoBa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Size)

/**
 *  根据字体算出字符串的size
 *
 *  @param font 字体
 *
 *  @return CGSize
 */
- (CGSize)stringSizeWithFont:(UIFont *)font;

/**
 *  根据（系统默认的）字体的大小算出字符串的size
 *
 *  @param fontFloat 系统默认的字体的大小
 *
 *  @return CGSize
 */
- (CGSize)stringSizeWithFontFloat:(CGFloat)fontFloat;


/**
 根据字体和宽度算出字符串的size

 @param font  字体
 @param width 宽度

 @return CGSize
 */
- (CGSize)stringSizeWithFont:(UIFont *)font width:(CGFloat)width;


/**
 根据（系统默认的）字体的大小和宽度算出字符串的size

 @param fontFloat 系统默认的字体的大小
 @param width     宽度

 @return CGSize
 */
- (CGSize)stringSizeWithFontFloat:(CGFloat)fontFloat width:(CGFloat)width;

@end
