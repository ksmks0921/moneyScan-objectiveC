//
//  ScannerController.h
//  Money Reader
//
//  Created by Asad Khan on 11/29/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKViewController.h>
#import "OpenGLView.h"

@interface ScannerController : GLKViewController
@property (nonatomic, strong) OpenGLView *glView;
@end
