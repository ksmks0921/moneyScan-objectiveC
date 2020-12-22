//
//  SplashViewController.m
//  Money Reader
//
//  Created by Asad Khan on 11/27/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *splashImageView;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];

    self.splashImageView.image = [UIImage imageNamed:@"Splash Screen Qatar"];
    
    [self performSelector:@selector(performSegue) withObject:nil afterDelay:4.0];
}

-(void)performSegue{
    
    [self performSegueWithIdentifier:@"launchScannerSegue" sender:self];
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
