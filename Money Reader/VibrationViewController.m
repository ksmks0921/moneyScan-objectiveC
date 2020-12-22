//
//  VibrationViewController.m
//  Money Reader
//
//  Created by macbook on 07/11/2017.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "VibrationViewController.h"
#import "FTIndicator.h"

@interface VibrationViewController () <UITextFieldDelegate>

@end

@implementation VibrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *shortText = [[NSUserDefaults standardUserDefaults] objectForKey:@"shortText"];
    NSString *longText = [[NSUserDefaults standardUserDefaults] objectForKey:@"longText"];
    
    if (!shortText) {
        shortText = @"200";
    }
    
    if (!longText) {
        longText = @"500";
    }
    
    [self setUp:self.shortText text:shortText];
    [self setUp:self.longText text:longText];
}

-(void)setUp:(UITextField *)textField text:(NSString *)text
{
    textField.layer.borderWidth = 1.0;
    textField.layer.borderColor = [UIColor colorWithRed:51.0/255.0 green:134.0/255.0 blue:166.0/255.0 alpha:1.0].CGColor;
    
    textField.layer.cornerRadius = 3.0;
    textField.clipsToBounds = YES;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    textField.text = text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.shortText resignFirstResponder];
    [self.longText resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender
{
    [self.shortText resignFirstResponder];
    [self.longText resignFirstResponder];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.shortText.text forKey:@"shortText"];
    [[NSUserDefaults standardUserDefaults] setObject:self.longText.text forKey:@"longText"];
    
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Success"
                                                                  message:@"Settings updated"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Ok"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
