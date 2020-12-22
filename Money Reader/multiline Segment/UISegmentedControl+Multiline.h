//
//  UISegmentedControl+Multiline.h
//
//  Created by Guilherme Araújo on 6/9/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISegmentedControl (Multiline)

- (void)insertSegmentWithMultilineTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)insertSegmentWithMultilineAttributedTitle:(NSAttributedString *)attributedTitle atIndex:(NSUInteger)segment animated:(BOOL)animated;

@end
