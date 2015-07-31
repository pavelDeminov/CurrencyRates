//
//  UIImage+Color.m
//  MoneyExchange
//
//  Created by Pavel Deminov on 31/07/15.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)colorImage:(UIImage *)image color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}


@end
