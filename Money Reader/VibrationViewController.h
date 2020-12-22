//
//  VibrationViewController.h
//  Money Reader
//
//  Created by macbook on 07/11/2017.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VibrationViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *shortText;
@property (strong, nonatomic) IBOutlet UITextField *longText;

- (IBAction)goBack:(id)sender;
- (IBAction)saveAction:(id)sender;
@end
