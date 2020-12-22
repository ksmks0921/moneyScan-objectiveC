//
//  ScanViewController.h
//  Money Reader
//
//  Created by Muhammad Ahsan on 4/12/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "OpenGLView.h"
//#import <GLKit/GLKViewController.h>

@protocol TCMCardScannerDelegate;

@interface ScanViewController : UIViewController


//@property (nonatomic, weak) id<TCMCardScannerDelegate> delegate;
//@property(nonatomic, strong) OpenGLView *glView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *flashSegmentButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *audioSegmentButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cameraSegmentButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *notesSegmentButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *howToUseButton;
- (IBAction)readingNotes:(UIButton *)sender;
- (IBAction)calculatingNotes:(UIButton *)sender;
- (IBAction)realNotes:(UIButton *)sender;


@end

@protocol TCMCardScannerDelegate <NSObject>


- (void)cardScannerViewControllerDidFinishWithScan:(NSString *)scanString;

@end
