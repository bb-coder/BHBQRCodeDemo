//
//  NSString+QRImage.h
//  二维码生成和读取demo
//
//  Created by bb_coder on 14/8/9.
//  Copyright (c) 2014年 bb_coder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QRImage)
/**
 * 返回当前字符串对应的二维码图像
 *
 * 二维码的实现是将字符串传递给滤镜，滤镜直接转换生成二维码图片
 */
- (UIImage *)createQRCode;

@end
