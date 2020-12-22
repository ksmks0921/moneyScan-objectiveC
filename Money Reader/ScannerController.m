//
//  ScannerController.m
//  Money Reader
//
//  Created by Asad Khan on 11/29/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "ScannerController.h"



@interface ScannerController ()

@end



@implementation ScannerController {
   
    
}

- (void)loadView {
    self.glView = [[OpenGLView alloc] initWithFrame:CGRectZero];
    self.view = self.glView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.glView setOrientation:self.interfaceOrientation];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView start];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView stop];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.glView setOrientation:toInterfaceOrientation];
}

@end
