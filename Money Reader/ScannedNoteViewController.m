//
//  ScannedNoteViewController.m
//  Money Reader
//
//  Created by Muhammad Ahsan on 4/12/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "ScannedNoteViewController.h"

@interface ScannedNoteViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *scanedImageFront;
@property (weak, nonatomic) IBOutlet UIImageView *scanedImageBack;

@end

@implementation ScannedNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scanned";
    [_scanedImageFront setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@ Front.jpeg",_prevNoteString]]];
    [_scanedImageBack setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@ Back.jpg",_prevNoteString]]];

    UIBarButtonItem* backButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    // Do any additional setup after loading the view.
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

-(void)backAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
