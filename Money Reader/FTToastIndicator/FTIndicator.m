//
//  FTIndicator.m
//  FTIndicator
//
//  Created by liufengting on 16/7/21.
//  Copyright © 2016年 liufengting ( https://github.com/liufengting ). All rights reserved.
//

#import "FTIndicator.h"

@interface FTIndicator ()

@end

@implementation FTIndicator

+ (void)setIndicatorStyleToDefaultStyle
{
    [self setIndicatorStyle:UIBlurEffectStyleLight];
}

+ (void)setIndicatorStyle:(UIBlurEffectStyle)style
{
    [FTToastIndicator setToastIndicatorStyle:style];
}

#pragma mark - FTToastIndicator
/**
 *  FTToastIndicator
 */
+ (void)showToastMessage:(NSString *)toastMessage
{
    [FTToastIndicator showToastMessage:toastMessage];
}

+ (void)dismissToast
{
    [FTToastIndicator dismiss];
}

@end
