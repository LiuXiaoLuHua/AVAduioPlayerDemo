//
//  NSString+size.m
//  MeiTuan
//
//  Created by 何凯楠 on 16/6/20.
//  Copyright © 2016年 HeXiaoBa. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGSize)stringSizeWithFont:(UIFont *)font {
    
    return [self stringSizeWithFont:font width:MAXFLOAT];
}


- (CGSize)stringSizeWithFontFloat:(CGFloat)fontFloat {
    
   return [self stringSizeWithFont:[UIFont systemFontOfSize:fontFloat]];
}

- (CGSize)stringSizeWithFont:(UIFont *)font width:(CGFloat)width {
    
    NSDictionary *attr = @{NSFontAttributeName : font};
    CGSize size = CGSizeMake(width, MAXFLOAT);
    CGSize result = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    return result;
}


- (CGSize)stringSizeWithFontFloat:(CGFloat)fontFloat width:(CGFloat)width {
    return  [self stringSizeWithFont:[UIFont systemFontOfSize:fontFloat] width:width];
}
@end
