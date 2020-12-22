//
//  AboutViewController.m
//  Qatar Money Reader
//
//  Created by Hassan Bhatti on 04/01/2018.
//  Copyright © 2018 Accuretech. All rights reserved.
//

#import "AboutViewController.h"
#import "AppUtils.h"
#import <easyar/engine.oc.h>

@interface AboutViewController ()
{
    UISwipeGestureRecognizer *swipeGestureForSecondMode;
    UISwipeGestureRecognizer *swipeGestureForSecondModeUpDown;
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    swipeGestureForSecondMode = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    swipeGestureForSecondMode.direction = (UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown|UISwipeGestureRecognizerDirectionLeft);
    swipeGestureForSecondMode.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGestureForSecondMode];

    swipeGestureForSecondModeUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    swipeGestureForSecondModeUpDown.direction = (UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown);
    swipeGestureForSecondModeUpDown.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGestureForSecondModeUpDown];

    
    if([AppUtils getLanguage] == MRAppLanguageArabic)
    {
        [_aboutTextView setText:@"تطبيق قارئ العملة القطرية حاصل على كامل الدعم من شركة مدى مركز التكنلوجيا المساعدة"];
        [_aboutTextView setTextAlignment:NSTextAlignmentRight];
    }
    else
    {
        [_aboutTextView setText:@"The country currency reader application is fully supported by Mada Technology Center"];
        [_aboutTextView setTextAlignment:NSTextAlignmentLeft];
    }
}

-(void)dismissView
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startCamera" object:nil];
        
        
        [easyar_Engine onResume];

    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
