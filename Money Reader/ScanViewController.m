//
//  ScanViewController.m
//  Money Reader
//
//  Created by Muhammad Ahsan on 4/12/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "FTIndicator.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppUtils.h"
#import "MRSoundManager.h"
#import "ScannerController.h"
#import <easyar/types.oc.h>
#include <math.h>
#import <QuartzCore/QuartzCore.h>
#import "AboutViewController.h"
#import "howToUseViewController.h"
#import "UISegmentedControl+Multiline.h"

#define VAR_LANGUAGE = @"Language"

@import UIKit;
@import AVFoundation;       // for AVAudioSession

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>{
    BOOL isMultiMode;
    BOOL SubScreenActive;
    

}

//void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);
//void AudioServicesStopSystemSound(SystemSoundID inSystemSoundID);
@property (weak, nonatomic) IBOutlet UIButton *calculateButton;
@property (strong, nonatomic) IBOutlet UIButton *readingNotes;
@property (strong, nonatomic) IBOutlet UIButton *calculatingNotes;
@property (strong, nonatomic) IBOutlet UIButton *realNotes;

@property (nonatomic, strong) IBOutlet UIView *viewPreview;
@property (nonatomic, strong) IBOutlet UIImageView *targetImageView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, assign) BOOL torchModeEnabled;
@property (nonatomic, strong) NSString *lastScannedMcardImage;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *languageSegment;
@property NSInteger count;

@property (nonatomic, strong)UITapGestureRecognizer *showSumGesture;
- (IBAction)cancel:(id)sender;
- (IBAction)didTapTorch:(id)sender;
- (IBAction)notesSegment:(UISegmentedControl *)sender;

@end

//hassan added this
@implementation CALayer (BorderProperties)
- (void)setBorderUIColor:(UIColor *)color {
    self.borderColor = color.CGColor;
}
- (UIColor *)borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}
@end
//end


@implementation ScanViewController
{
     //OpenGLView *glView;
    
    //hassan
    ScannerController* mySVC;
    UITapGestureRecognizer *tapGesture;
    UISwipeGestureRecognizer *swipeGestureForSecondMode;
    UISwipeGestureRecognizer *swipeGestureForSecondModeUpDown;
    BOOL isSameCamera;
    UISwipeGestureRecognizer *swipeGestureForMuteAudio;
    UISwipeGestureRecognizer *swipeGestureForMuteAudioUpDown;
    UIView *aboutView;
    BOOL isFrontCamera;
    UIView *howToUseView;
    AVSpeechSynthesizer *synthesizer;
}



- (void)viewDidLoad {
    [super viewDidLoad];
//    CGFloat *pointsize = 11;
//    [_notesSegmentButton.subviews enumerateObjectsUsingBlock:^(UIView * obj, NSUInteger idx, BOOL *stop) {
//        [obj.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if ([obj isKindOfClass:[UILabel class]]) {
//                UILabel *_tempLabel = (UILabel *)obj;
//                _tempLabel.numberOfLines = 0;
//                [_tempLabel layoutIfNeeded];
//                CGFloat fontSize = _tempLabel.font.pointSize;
//                *pointsize = fontSize;
//            }
//        }];
//    }];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"Verdana-Bold" size:14.0f], NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    _calculateButton.titleLabel.font =  [UIFont fontWithName:@"Verdana-Bold" size:14.0f];

    if ([[UIScreen mainScreen]bounds].size.height > 750)
    {
        attributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"Verdana-Bold" size:20.0f], NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil];
        _calculateButton.titleLabel.font =  [UIFont fontWithName:@"Verdana-Bold" size:20.0f];

    }
    else if ([[UIScreen mainScreen]bounds].size.height > 570)
    {
        attributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"Verdana-Bold" size:17.5f], NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil];
        _calculateButton.titleLabel.font =  [UIFont fontWithName:@"Verdana-Bold" size:17.5f];
    }
//
    [_audioSegmentButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [_flashSegmentButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [_cameraSegmentButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [_notesSegmentButton setTitleTextAttributes:attributes forState:UIControlStateNormal];

//    [_cameraSegmentButton insertSegmentWithMultilineTitle:@"Front Camera" atIndex:1 animated:YES];
    isSameCamera = YES;
    isFrontCamera = NO;
    if([[[NSUserDefaults standardUserDefaults]valueForKey:@"Language"] isEqualToString:@"ar"])
    {
        self.languageSegment.selectedSegmentIndex = 1;
        
        
    }
    else
    {
        self.languageSegment.selectedSegmentIndex = 0;
    }

    
    self.readingNotes.titleLabel.numberOfLines = 2;
    self.readingNotes.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.calculatingNotes.titleLabel.numberOfLines = 2;
    self.calculatingNotes.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.realNotes.titleLabel.numberOfLines = 2;
    self.realNotes.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];

    UIFont *font1 = [UIFont fontWithName:@"Verdana-Bold" size:17.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.whiteColor}; // Added line

    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"كشف العملة الحقيقية" attributes:dict1]];
    }
    else
    {
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Real\nNotes" attributes:dict1]];
    }
    [[self realNotes] setAttributedTitle:attString forState:UIControlStateNormal];
    [self.realNotes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"جمع العملات" attributes:dict1]];
        
    }
    else
    {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Calcuating\nNotes"    attributes:dict1]];
    }
    [[self calculatingNotes] setAttributedTitle:attString1 forState:UIControlStateNormal];
    NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"قراءة العملات" attributes:dict1]];
        
    }
    else
    {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Reading\nNotes"    attributes:dict1]];
    }
    [[self readingNotes] setAttributedTitle:attString2 forState:UIControlStateNormal];
//    [self startObservingNotifications];
//
//    if([[[NSUserDefaults standardUserDefaults]valueForKey:@"Language"] isEqualToString:@"ar"]){
//        self.languageSegment.selectedSegmentIndex = 1;
//    }else{
//        self.languageSegment.selectedSegmentIndex = 0;
//    }
//
//    [self setGestureOnView];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isSameCamera = YES;
    [self startObservingNotifications];

    if([[[NSUserDefaults standardUserDefaults]valueForKey:@"Language"] isEqualToString:@"ar"])
    {
        self.languageSegment.selectedSegmentIndex = 1;
    }
    else
    {
        self.languageSegment.selectedSegmentIndex = 0;
    }
    [self setGestureOnView];
    
    appdelegate.active = true;
//    [self showWelcomeNoteToUser];
    //hassan added it later
    [self loadButtons];
    [self setCalculateButtonVisibility];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFromAbout"] == YES)
    {
        [self aboutButtonTarget:_aboutButton];
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   

    //hassan changes
    mySVC = (ScannerController*)self.childViewControllers.firstObject;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //changes end
     [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self->glView stop];
    appdelegate.active = false;
    
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //[self->glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
   // [self->glView setOrientation:toInterfaceOrientation];
}


- (void)orientationChanged:(NSNotification *)notification {
    NSLog(@"%@",notification);
    //    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject; //hassan commented it :)
    //changes by hassan
    if (isFaceUp) {
        if (mySVC.glView.cameraType == easyar_CameraDeviceType_Default && isSameCamera == YES)
        {
            
        }
        else
        {
            [mySVC.glView switchCamera:easyar_CameraDeviceType_Default];
            [self setflashOnOFF:AVCaptureTorchModeAuto];
            isSameCamera = YES;
        }
    }
    else if(isFaceDown)
    {
        if (mySVC.glView.cameraType == easyar_CameraDeviceType_Default && isSameCamera == YES)
        {
            [mySVC.glView switchCamera:easyar_CameraDeviceType_Front];
            isSameCamera = NO;
        }
    }
}

-(void)startObservingNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCodeScanedNotificationReceived:) name:@"imageCodeScanedNotification" object:nil];
    // notification observer for multiple notes detection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sumOfScannedNotesNotification:) name:@"sumOfScannedNotesNotification" object:nil];
    
    // notification observer for multiple notes detection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realNoteDetected:) name:@"RealNoteDetectedNotification" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realNoteSideDetected:) name:@"noteSideDetecedNotification" object:nil];
   
    //observer for reloading app from appDidBecomeActive
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCamera) name:@"startCamera" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissView1) name:@"dismissView11" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCalculateButtonVisibility) name:@"HideCalculateButton" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTTS) name:@"stopTTS" object:nil];

    [self observeNoteSidesDetection];
}

- (void)calculateAmount:(id)sender {
    
//    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject; //hassan changes
    
    //hassan changes
    NSString *str = [mySVC.glView getTotalSum];
    NSArray *chunks = [str componentsSeparatedByString: @"."];
    if ([[chunks objectAtIndex:1] isEqualToString:@"0"]) {
        str = [chunks objectAtIndex:0];
    }
    if (str.length > 0)
    {
        //[sVC.glView stop];
        if([AppUtils getLanguage] == MRAppLanguageArabic)
            //rial qatariun
            [self utterTextWithString:[NSString stringWithFormat:@"%@ ريال قطري",str] withLocale:@"ar-SA"];
        else
            [self utterTextWithString:[NSString stringWithFormat:@"%@ Qatari Rial",str] withLocale:@"en-us"];

        
        if([AppUtils getLanguage] == MRAppLanguageArabic) //hassan changes
            [FTIndicator showToastMessage:[NSString stringWithFormat:@"%@\n ريال قطري",str]];
        else
            [FTIndicator showToastMessage:[NSString stringWithFormat:@"%@\nQatari Riyal",str]];
       
        //changes end
        
        //[self performSelector:@selector(startCamera) withObject:nil afterDelay:3];
    }
    self.count = 1;
    [self vibrateFor:@"200"];
    //I don't know why previous developer did this.... :#

    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateFlagAction:) userInfo:nil repeats:NO];
    [mySVC.glView setTotalSumToZer];
    [mySVC.glView removeTrackingID];
   
}

-(void)startCamera
{
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;

    //hassan made changes
//     [sVC.glView start];
    [sVC.glView resetTrackingTarget];
    
    _cameraSegmentButton.selectedSegmentIndex = 0;
    _flashSegmentButton.selectedSegmentIndex = 0;

    isFrontCamera = NO;
    //changes end
}

-(void)stopCamera
{
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
    [sVC.glView stop];
}
-(void)setGestureOnView
{
    [self setGesturesForQatar];
}
-(void)setGesturesForQatar
{
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidSwipeLeft)];
    swipeGestureRight.direction = (UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown|UISwipeGestureRecognizerDirectionLeft);
    swipeGestureRight.numberOfTouchesRequired = 3;
    [self.viewPreview addGestureRecognizer:swipeGestureRight];
    //hassan added this gesture to swipe in remaining direction
    UISwipeGestureRecognizer *swipeGestureUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidSwipeLeft)];
    swipeGestureUpDown.direction = (UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown);
    swipeGestureUpDown.numberOfTouchesRequired = 3;
    [self.viewPreview addGestureRecognizer:swipeGestureUpDown];

    
//    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture)];
//    tapGesture.numberOfTapsRequired = 2;
//    [self.viewPreview addGestureRecognizer:tapGesture];
    [AppUtils saveVibrationState:NO]; //viberation gesture deleted now
    
    //hassan changes
    //hassan made this
    swipeGestureForSecondMode = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(calculateAmount:)];
    swipeGestureForSecondMode.direction = (UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown|UISwipeGestureRecognizerDirectionLeft);
    swipeGestureForSecondMode.numberOfTouchesRequired = 1;
    
    swipeGestureForSecondModeUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(calculateAmount:)];
    swipeGestureForSecondModeUpDown.direction = (UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown);
    swipeGestureForSecondModeUpDown.numberOfTouchesRequired = 1;
    
    //for audio mute
//    swipeGestureForMuteAudio = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(muteState)];
//    swipeGestureForMuteAudio.direction = (UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown|UISwipeGestureRecognizerDirectionLeft);
//    swipeGestureForMuteAudio.numberOfTouchesRequired = 1;
//    [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudio];
//
//    swipeGestureForMuteAudioUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(muteState)];
//    swipeGestureForMuteAudioUpDown.direction = (UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown);
//    swipeGestureForMuteAudioUpDown.numberOfTouchesRequired = 1;
//    [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudioUpDown];
    //end
    
    self.showSumGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(calculateAmount:)];
    self.showSumGesture.numberOfTapsRequired = 1;
    if ([AppUtils getAppMode] != MRScanModeMultiple) {
         self.showSumGesture.enabled = false;
    }   
    [self.viewPreview addGestureRecognizer:self.showSumGesture];
    //changes end
}
-(void)userDidSwipeLeft
{
    if (self.languageSegment.selectedSegmentIndex == 1)
    {
        self.languageSegment.selectedSegmentIndex = 0;
    }
    else
    {
        self.languageSegment.selectedSegmentIndex = 1;
    }
    
    [self languageAction:self.languageSegment];
    
    //hassan added this
    [self changeLTR];
}

-(void)muteState
{
    [AppUtils saveMuteState:![AppUtils getMuteState]];
    
    NSString *displayMessage;

    if ([AppUtils getMuteState])
    {
        if([AppUtils getLanguage] == MRAppLanguageArabic)
        {
            displayMessage = @"Sound Muted";
        }
        else
        {
            displayMessage = @"Sound Muted";
        }
    }
    else
    {
        if([AppUtils getLanguage] == MRAppLanguageArabic)
        {
            displayMessage = @"Sound Open";
        }
        else
        {
            displayMessage = @"Sound Open";
        }
    }
    if (SubScreenActive == NO)
    {
    [FTIndicator showToastMessage:displayMessage];
    }
}

-(void)doubleTapGesture {
   
    [AppUtils saveVibrationState:![AppUtils getVibrationState]];
    NSString *displayMessage,*file;
    if (![AppUtils getVibrationState]) {
        //Allow
        [MRSoundManager.instance playVibrateSound];
        if (self.languageSegment.selectedSegmentIndex == 1) {
            displayMessage = @"تم تمكين الاهتزاز";
        }else {
            displayMessage = @"Vibration Enabled";
        }
        file = @"Vibration+Sound Active";
    }
    else
    {
        if (self.languageSegment.selectedSegmentIndex == 1) {
            displayMessage = @"تم تعطيل الاهتزاز";
        }else {
            displayMessage = @"Vibration Disabled";
        }
        
        file = @"Vibration+Sound Disabled";
    }
    
    [self playSettingsAudio:file];
    if (SubScreenActive == NO)
    {
    [FTIndicator showToastMessage:displayMessage];
    }
}


-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (motion == UIEventSubtypeMotionShake) {
        [mySVC.glView setTotalSumToZer];
        [mySVC.glView removeTrackingID];
        NSString *displayMessage,*file;
        isMultiMode = !isMultiMode;
       
        if ([AppUtils getAppMode] == MRScanModeSingle) {
            [AppUtils saveAppMode:MRScanModeMultiple];
            [_notesSegmentButton setSelectedSegmentIndex:1];
            if (self.languageSegment.selectedSegmentIndex == 1) {
//                displayMessage = @"تمكين وضع متعدد";
                displayMessage = @"وضع جمع العملات";
            }
            else
            {
//              displayMessage = @"Multi Mode Enable";
                displayMessage = @"Calculating notes mode is active";
            }
            
            file = @"2nd Mode Active";
            [self setflashOnOFF:AVCaptureTorchModeOff];

            //hassan did this
            [self.viewPreview addGestureRecognizer:swipeGestureForSecondMode];
            [self.viewPreview addGestureRecognizer:swipeGestureForSecondModeUpDown];
//            [self.viewPreview removeGestureRecognizer:swipeGestureForMuteAudio];
//            [self.viewPreview removeGestureRecognizer:swipeGestureForMuteAudioUpDown];
            [self switchSumGesture:TRUE];
        }
        else if ([AppUtils getAppMode] == MRScanModeMultiple){
            [AppUtils saveAppMode:MRScanModeFakeORReal];
            [_notesSegmentButton setSelectedSegmentIndex:2];

            if (self.languageSegment.selectedSegmentIndex == 1) {
//                displayMessage = @"الوضع الثالث";
                displayMessage = @"وضع كشف العملات الحقيقية";
            }else {
//                displayMessage = @"Mode Three";
                displayMessage = @"Detecting real notes mode is active";
            }
            
            file = @"3rd Mode Active";
            
            [self.viewPreview removeGestureRecognizer:swipeGestureForSecondMode]; //hassan did this
            [self.viewPreview removeGestureRecognizer:swipeGestureForSecondModeUpDown]; //hassan did this
            [self setflashOnOFF:AVCaptureTorchModeOff];

            //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudio];
            //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudioUpDown];
            
            [self switchSumGesture:FALSE];
            //hassan did this to start controller initially to prevent modes overlaping
            //and it's working fine with this piece of code
            ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
            //            [sVC.glView start];
            [sVC.glView resetTrackingTarget];
            //for third mode only
            if (_cameraSegmentButton.selectedSegmentIndex == 0)
            {
                [self setflashOnOFF:AVCaptureTorchModeOn];
            }
        }
        else if ([AppUtils getAppMode] == MRScanModeFakeORReal)
        {
            [AppUtils saveAppMode:MRScanModeSingle];
            if (self.languageSegment.selectedSegmentIndex == 1) {
//                displayMessage = @"تمكين وضع واحد";
                displayMessage = @"وضع قراءة العملات";
            }else {
//                displayMessage = @"Single Mode Enable";
                displayMessage = @"Reading notes mode is active";
            }
            [_notesSegmentButton setSelectedSegmentIndex:0];

            file = @"1st Mode Active";
            
            [self.viewPreview removeGestureRecognizer:swipeGestureForSecondMode]; //hassan did this
            [self.viewPreview removeGestureRecognizer:swipeGestureForSecondModeUpDown]; //hassan did this
            [self setflashOnOFF:AVCaptureTorchModeOff];

//            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudio];
//            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudioUpDown];

            [self switchSumGesture:FALSE];
            //hassan did this to start controller initially to prevent modes overlaping
            //and it's working fine with this piece of code
            ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
//            [sVC.glView start];
            [sVC.glView resetTrackingTarget];
            
            _flashSegmentButton.selectedSegmentIndex = 0;
        }
        if (SubScreenActive == NO)
        {
        if([AppUtils getLanguage] == MRAppLanguageArabic)
        {
            [self showModeChangeWith:displayMessage andAudio:file];
        }
        else
        {
            [self utterTextWithString:displayMessage withLocale:@"en-us"];
            [FTIndicator showToastMessage:displayMessage];
        }
        }
        //[self.glView stop];
       // [self.glView start];
       //  [self switchSumGesture:FALSE];
         [self setCalculateButtonVisibility];
     
    }
}
-(void)showWelcomeNoteToUser
{
    NSString *displayMessage;
    if (self.languageSegment.selectedSegmentIndex == 1)
    {
        displayMessage = @"أهلا بك";
    }
    else
    {
        displayMessage = @"Qatari Welcome";
    }
    if (SubScreenActive == NO)
    {
    [FTIndicator showToastMessage:displayMessage];
    [self playSettingsAudio:@"Qatari Welcome"];
    }
}
-(void)showModeChangeWith:(NSString*)displayMessage andAudio:(NSString *)file {
//    NSString *displayMessage,*file;
//
//    if (isMultiMode) {
//
//
//
//        if (self.languageSegment.selectedSegmentIndex == 1) {
//            displayMessage = @"تمكين وضع متعدد";
//        }else {
//            displayMessage = @"Multi Mode Enable";
//        }
//
//        file = @"1st Mode Active";
//    }else {
//
//        if (self.languageSegment.selectedSegmentIndex == 1) {
//            displayMessage = @"تمكين وضع واحد";
//        }else {
//            displayMessage = @"Single Mode Enable";
//        }
//
//         file = @"2nd Mode Active";
//    }
    if (SubScreenActive == NO)
    {
    [FTIndicator showToastMessage:displayMessage];

    
    
    [self playSettingsAudio:file];
    }
    
}
- (void)imageCodeScanedNotificationReceived:(NSNotification *)notification
{
    appdelegate.active = false;
    NSLog(@"%@",notification.userInfo);
    if (SubScreenActive == NO)
    {
    if([notification.userInfo valueForKey:@"image"]){
        NSString * qCardImage = [notification.userInfo valueForKey:@"image"];
        
        qCardImage = [qCardImage componentsSeparatedByString:@" "].firstObject;
    
        
        if (qCardImage.length) {
//            self.glView = nil;
//            self.lastScannedMcardImage = nil;
            self.lastScannedMcardImage = qCardImage;
        }
        if (self.lastScannedMcardImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopObserving];
                [self performSelector:@selector(startObservingNotifications) withObject:nil afterDelay:1];
            });
            //hassan changes
            if([AppUtils getLanguage] == MRAppLanguageArabic)
                [FTIndicator showToastMessage:[NSString stringWithFormat:@"%@\n ريال قطري",self.lastScannedMcardImage]];
            else
                [FTIndicator showToastMessage:[NSString stringWithFormat:@"%@\n Qatari Riyal",self.lastScannedMcardImage]];
             //hassan changes end
            
            //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            self.count = 1;
            [self vibrateFor:qCardImage];
            
                [self initilizeAudioPlayer:self.lastScannedMcardImage];
                assert(self.audioPlayer);
                if (self.audioPlayer && (self.audioPlayer.isPlaying == NO)){
                    [self.audioPlayer prepareToPlay];
                    [self.audioPlayer play];
                    
                    //hassan added this
                    if ([AppUtils getMuteState] == YES)
                    {
                        self.audioPlayer.volume = 0.0;
                    }
                    else
                    {
                        self.audioPlayer.volume = 1.0;
                    }

                    //[self startReading];
                    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateFlagAction:) userInfo:nil repeats:NO];
                }
        }
    }
    }
}

-(void)sumOfScannedNotesNotification:(NSNotification*)notification
{
    if (SubScreenActive == NO)
    {
    if([notification.userInfo valueForKey:@"totalSum"]){
        
        NSString * total = [notification.userInfo valueForKey:@"totalSum"];

        [FTIndicator showToastMessage:[NSString stringWithFormat:@"%@\nQatari Riyal",total]];
        
        if([AppUtils getLanguage] == MRAppLanguageArabic)
            [self utterTextWithString:[NSString stringWithFormat:@"%@ ريال قطري",total] withLocale:@"ar-SA"];
        else
            [self utterTextWithString:[NSString stringWithFormat:@"%@ Qatari Rial",total] withLocale:@"en-us"];
        
        self.count = 1;
        [self vibrateFor:@"200"];//I don't know why previous developer did this.... :#
        
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateFlagAction:) userInfo:nil repeats:NO];
    }
    }
}
-(void)realNoteDetected:(NSNotification*)notification
{
    if (SubScreenActive == NO)
    {
    NSDictionary * dic = [notification.userInfo objectForKey:@"info"];
    
    //hassan changes
        NSArray* SidesCount = [[dic valueForKey:@"side"] componentsSeparatedByString:@" "];
        if (SidesCount.count > 2)
        {
    NSString *noteSide = [[dic valueForKey:@"side"] componentsSeparatedByString:@" "][2];
    NSString *noteValue = [[dic valueForKey:@"side"] componentsSeparatedByString:@" "][0];
    //changes end
    
    if ([noteSide isEqualToString:@"Back"] && [[dic valueForKey:@"count"] integerValue] == 1 ){

        NSLog(@"Real Back side ");
        
        if([AppUtils getLanguage] == MRAppLanguageArabic) {
            [FTIndicator showToastMessage:[NSString stringWithFormat:@"إقلب العملة"]];
            [self playSettingsAudio:@"Turn over Arabic"];
        }
        else {
            [FTIndicator showToastMessage:[NSString stringWithFormat:@"Back side detected"]];
            [self utterTextWithString:[NSString stringWithFormat:@"Please turn over"] withLocale:@"en-us"];
        }
        [self vibrateFor: @"200"];
        
    }
    else if([noteSide isEqualToString:@"Front"] && [[dic valueForKey:@"count"] integerValue] == 1 ){
        if([AppUtils getLanguage] == MRAppLanguageArabic) {
            [FTIndicator showToastMessage:[NSString stringWithFormat:@"إقلب العملة"]];
            [self playSettingsAudio:@"Turn over Arabic"];
        }
        else {
            [FTIndicator showToastMessage:[NSString stringWithFormat:@"Front side detected"]];
            [self utterTextWithString:[NSString stringWithFormat:@"Please turn over"] withLocale:@"en-us"];
        }
         [self vibrateFor: @"200"];
    
        
    }

    else if([[dic valueForKey:@"count"] integerValue] == 2)
    {
        NSLog(@"This is a real note");
        
        //hassan changes
//        if([AppUtils getLanguage] == MRAppLanguageArabic)
//            [self utterTextWithString:[NSString stringWithFormat:@"%@ Riyal Real Note",noteValue] withLocale:@"ar-SA"];
//        else
//            [self utterTextWithString:[NSString stringWithFormat:@"%@ Riyal Real Note",noteValue] withLocale:@"en-us"];
//        [self vibrateFor: @"500"];
            
//            dispatch_async(dispatch_get_main_queue(), ^{
        [self clientVoice:noteValue];
//            });
        [self vibrateFor: @"500"];
//        //hassan did this to start scanning next note
            ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
            [sVC.glView startTrackingRealNote];
        
        [self setflashOnOFF:AVCaptureTorchModeOff];
    }
    }
    }
    //changes end
}




//hassan added this
-(void)clientVoice:(NSString *)noteValue
{
    if (SubScreenActive == NO)
    {
    [self initilizeAudioPlayer:noteValue];
    assert(self.audioPlayer);
    if (self.audioPlayer && (self.audioPlayer.isPlaying == NO)){
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
        //hassan added this
        if ([AppUtils getMuteState] == YES)
        {
            self.audioPlayer.volume = 0.0;
        }
        else
        {
            self.audioPlayer.volume = 1.0;
        }
    }
    }
}
//end

-(void)setNotesTargetNoteSide:(NSString*)str{
    [self performSelector:@selector(realNotesDetections) withObject:nil afterDelay:3];
}
-(void)realNotesDetections
{
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;

    [sVC.glView realNoteSideDetected];

}
-(void)setNotesTargetForBackSide:(NSString*)str{
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
    [sVC.glView realNoteSideDetected];
}
-(void)resetTargets{
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
    [sVC.glView resetTrackingTarget];
}
-(void)realNoteSideDetected:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noteSideDetecedNotification" object:nil];
    
    NSString * nameOfNoteDetected = [notification.userInfo objectForKey:@"image"];
    
    NSString * nameOfSide = [nameOfNoteDetected componentsSeparatedByString:@"."].firstObject;
    
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
    [sVC.glView realNoteSideDetected];
}
-(void)observeNoteSidesDetection
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realNoteSideDetected:) name:@"noteSideDetecedNotification" object:nil];
}
-(void)utterTextWithString:(NSString *)text withLocale:(NSString *)locale
{
    synthesizer = [[AVSpeechSynthesizer alloc]init];
    
    AVSpeechUtterance *speechutt = [AVSpeechUtterance speechUtteranceWithString:text];
    [speechutt setRate:0.5];
    speechutt.voice = [AVSpeechSynthesisVoice voiceWithLanguage:locale];
    
    //hassan added this
    if ([AppUtils getMuteState] == YES)
    {
        speechutt.volume = 0.0;
    }
    else
    {
        speechutt.volume = 1.0;
    }

    [synthesizer speakUtterance:speechutt];
}

//hassan has changed the whole method
-(void)vibrateFor:(NSString *)qCardImage
{
//    NSString *shortText = @"200";
//    NSString *mediumText = @"500";
//    NSString *longText = @"800";
//
//    if ([qCardImage isEqualToString:@"1"])
//    {
//
//    }
//    else if ([qCardImage isEqualToString:@"1-2"])
//    {
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"1-2" afterDelay:(longText.doubleValue / 1000) + 1];
//        }
//        else if (self.count == 2)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"1-2" afterDelay:(longText.doubleValue / 1000) + 1];
//        }
//    }
//    else if ([qCardImage isEqualToString:@"5"])
//    {
//#ifdef QatarBuild
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"5" afterDelay:(longText.doubleValue / 1000) + 1];
//        }
//#else
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"5" afterDelay:(mediumText.doubleValue / 1000) + 1];
//        }
//#endif
//    }
//    else if ([qCardImage isEqualToString:@"10"])
//    {
//#ifdef QatarBuild
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"10" afterDelay:(mediumText.doubleValue / 1000) + 1];
//        }
//#else
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"10" afterDelay:(mediumText.doubleValue / 1000) + 1];
//        }
//#endif
//    }
//    else if ([qCardImage isEqualToString:@"20"] || [qCardImage isEqualToString:@"20.1"])
//    {
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"20" afterDelay:(shortText.doubleValue / 1000) + 1];
//        }
//    }
//    else if ([qCardImage isEqualToString:@"50"])
//    {
//#ifdef QatarBuild
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"50" afterDelay:(shortText.doubleValue / 1000) + 1];
//        }
//#else
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"50" afterDelay:(shortText.doubleValue / 1000) + 1];
//        }
//#endif
//    }
//    else if ([qCardImage isEqualToString:@"100"])
//    {
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"100" afterDelay:(mediumText.doubleValue / 1000) + 1];
//        }
//        else if (self.count == 2)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"100" afterDelay:(mediumText.doubleValue / 1000) + 1];
//        }
//    }
//    else if ([qCardImage isEqualToString:@"500"])
//    {
//        if (self.count == 1)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"500" afterDelay:(shortText.doubleValue / 1000) + 1];
//        }
//        else if (self.count == 2)
//        {
//            [self performSelector:@selector(vibrateFor:) withObject:@"500" afterDelay:(shortText.doubleValue / 1000) + 1];
//        }
//    }
    
    NSString *shortText = @"200";
    NSString *mediumText = @"500";
    NSString *longText = @"800";
    
    if ([qCardImage isEqualToString:@"1"])
    {
        
    }
    else if ([qCardImage isEqualToString:@"5"])
    {
        if (self.count == 1)
        {
            [self performSelector:@selector(vibrateFor:) withObject:@"5" afterDelay:(longText.floatValue / 1000) + 0.6];
        }
    }
    else if ([qCardImage isEqualToString:@"10"])
    {
        if (self.count == 1)
        {
            [self performSelector:@selector(vibrateFor:) withObject:@"10" afterDelay:(mediumText.floatValue / 1000) + 0.6];
        }
    }
    else if ([qCardImage isEqualToString:@"50"])
    {
        if (self.count == 1)
        {
            [self performSelector:@selector(vibrateFor:) withObject:@"50" afterDelay:(shortText.floatValue / 1000) + 0.6];
        }
    }
    else if ([qCardImage isEqualToString:@"100"])
    {
        if (self.count == 1)
        {
            [self performSelector:@selector(vibrateFor:) withObject:@"100" afterDelay:(mediumText.floatValue / 1000) + 0.6];
        }
        else if (self.count == 2)
        {
            [self performSelector:@selector(vibrateFor:) withObject:@"100" afterDelay:(mediumText.floatValue / 1000) + 0.6];
        }
    }
    else if ([qCardImage isEqualToString:@"500"])
    {
        if (self.count == 1)
        {
            [self performSelector:@selector(vibrateFor:) withObject:@"500" afterDelay:(shortText.floatValue / 1000) + 0.6];
        }
        else if (self.count == 2)
        {
            [self performSelector:@selector(vibrateFor:) withObject:@"500" afterDelay:(shortText.floatValue / 1000) + 0.6];
        }
    }
    
    if (![AppUtils getVibrationState] == YES) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); //defaul vibration //by hassan
//        AudioServicesPlaySystemSound(1520); //for short single vibration //by hassan
//        AudioServicesPlaySystemSound(1521); //for short double vibration //by hassan
    }
    
    self.count++;
}

-(IBAction)updateFlagAction:(id)sender{
    appdelegate.active = YES;

}


-(void)dealloc{
    [self stopObserving];
}
-(void)stopObserving{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"qrCodeScanedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageCodeScanedNotification" object:nil];
    
    //hassan did this
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sumOfScannedNotesNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RealNoteDetectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:@"dismissView11" object:nil];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.videoPreviewLayer setFrame:[UIScreen mainScreen].bounds];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

#pragma mark - Action

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
//        [self.delegate cardScannerViewControllerDidCancel:self];
    }];
}

- (IBAction)didTapTorch:(id)sender {
    self.torchModeEnabled = !self.torchModeEnabled;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode:self.torchModeEnabled ? AVCaptureTorchModeAuto : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

- (IBAction)notesSegment:(UISegmentedControl *)sender {
    
    [mySVC.glView setTotalSumToZer];
    [mySVC.glView removeTrackingID];
    if(sender.selectedSegmentIndex == 0)
    {
        NSString *displayMessage,*file;
        isMultiMode = !isMultiMode;
        [AppUtils saveAppMode:MRScanModeSingle];
        if (self.languageSegment.selectedSegmentIndex == 1) {
            //                displayMessage = @"تمكين وضع واحد";
            displayMessage = @"وضع قراءة العملات";
        }
        else
        {
            // displayMessage = @"Single Mode Enable";
            displayMessage = @"Reading notes mode is active";
        }
        
        file = @"1st Mode Active";
        
        self.readingNotes.layer.borderColor = [UIColor yellowColor].CGColor;
        self.calculatingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
        self.realNotes.layer.borderColor = [UIColor whiteColor].CGColor;
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        UIFont *font1 = [UIFont fontWithName:@"Verdana-Bold" size:17.0f];
        NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                NSFontAttributeName:font1,
                                NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.yellowColor}; // Added line
        NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                NSFontAttributeName:font1,
                                NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.whiteColor}; // Added line
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
        if (self.languageSegment.selectedSegmentIndex == 1) {
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@" كشف العملة الحقيقية" attributes:dict2]];
        }
        else
        {
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Real\nNotes"    attributes:dict2]];
        }
        [[self realNotes] setAttributedTitle:attString forState:UIControlStateNormal];
        NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];
        
        if (self.languageSegment.selectedSegmentIndex == 1)
        {
            [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"جمع العملات" attributes:dict2]];
        }
        else
        {
            [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Calcuating\nNotes" attributes:dict2]];
        }
        [[self calculatingNotes] setAttributedTitle:attString1 forState:UIControlStateNormal];
        
        NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
        if (self.languageSegment.selectedSegmentIndex == 1) {
            [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"قراءة العملات" attributes:dict1]];
            
        }
        else
        {
            [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Reading\nNotes" attributes:dict1]];
        }
        [[self readingNotes] setAttributedTitle:attString2 forState:UIControlStateNormal];
        
        [self setflashOnOFF:AVCaptureTorchModeOff];
        
        [self.viewPreview removeGestureRecognizer:swipeGestureForSecondMode]; //hassan did this
        [self.viewPreview removeGestureRecognizer:swipeGestureForSecondModeUpDown]; //hassan did this
        
        // [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudio];
        // [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudioUpDown];
        
        [self switchSumGesture:FALSE];
        //hassan did this to start controller initially to prevent modes overlaping
        //and it's working fine with this piece of code
        ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
        //            [sVC.glView start];
        [sVC.glView resetTrackingTarget];
        
        _flashSegmentButton.selectedSegmentIndex = 0;
        if([AppUtils getLanguage] == MRAppLanguageArabic)
        {
            [self showModeChangeWith:displayMessage andAudio:file];
        }
        else
        {
            [self utterTextWithString:displayMessage withLocale:@"en-us"];
            [FTIndicator showToastMessage:displayMessage];
        }
        [self setCalculateButtonVisibility];
    }
    else if(sender.selectedSegmentIndex == 1)
    {
        NSString *displayMessage,*file;
        isMultiMode = !isMultiMode;
        
        [AppUtils saveAppMode:MRScanModeMultiple];
        
        if (self.languageSegment.selectedSegmentIndex == 1) {
            //                displayMessage = @"تمكين وضع متعدد";
            displayMessage = @"وضع جمع العملات";
        }else {
            //                displayMessage = @"Multi Mode Enable";
            displayMessage = @"Calculating notes mode is active";
        }
        [self setflashOnOFF:AVCaptureTorchModeOff];
        
        file = @"2nd Mode Active";
        self.readingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
        self.calculatingNotes.layer.borderColor = [UIColor yellowColor].CGColor;
        
        self.realNotes.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        UIFont *font1 = [UIFont fontWithName:@"Verdana-Bold" size:17.0f];
        NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                NSFontAttributeName:font1,
                                NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.yellowColor}; // Added line
        NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                NSFontAttributeName:font1,
                                NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.whiteColor}; // Added line
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
        if (self.languageSegment.selectedSegmentIndex == 1) {
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@" كشف العملة الحقيقية" attributes:dict2]];
        }
        else
        {
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Real\nNotes"    attributes:dict2]];
        }
        [[self realNotes] setAttributedTitle:attString forState:UIControlStateNormal];
        NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];
        
        if (self.languageSegment.selectedSegmentIndex == 1) {
            [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"جمع العملات" attributes:dict1]];
            
        }
        else
        {
            [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Calcuating\nNotes"    attributes:dict1]];
        }
        [[self calculatingNotes] setAttributedTitle:attString1 forState:UIControlStateNormal];
        
        NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
        if (self.languageSegment.selectedSegmentIndex == 1) {
            [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"قراءة العملات" attributes:dict2]];
            
        }
        else
        {
            [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Reading\nNotes"    attributes:dict2]];
        }
        [[self readingNotes] setAttributedTitle:attString2 forState:UIControlStateNormal];
        //hassan did this
        [self.viewPreview addGestureRecognizer:swipeGestureForSecondMode];
        [self.viewPreview addGestureRecognizer:swipeGestureForSecondModeUpDown];
        
        //            [self.viewPreview removeGestureRecognizer:swipeGestureForMuteAudio];
        //            [self.viewPreview removeGestureRecognizer:swipeGestureForMuteAudioUpDown];
        
        [self switchSumGesture:TRUE];
        
        if([AppUtils getLanguage] == MRAppLanguageArabic)
        {
            [self showModeChangeWith:displayMessage andAudio:file];
        }
        else
        {
            [self utterTextWithString:displayMessage withLocale:@"en-us"];
            [FTIndicator showToastMessage:displayMessage];
        }
        
        //[self.glView stop];
        // [self.glView start];
        //  [self switchSumGesture:FALSE];
        [self setCalculateButtonVisibility];
    }
    else if(sender.selectedSegmentIndex == 2)
    {
            
            NSString *displayMessage,*file;
            isMultiMode = !isMultiMode;
            [AppUtils saveAppMode:MRScanModeFakeORReal];
            
            if (self.languageSegment.selectedSegmentIndex == 1) {
                //                displayMessage = @"الوضع الثالث";
                displayMessage = @"وضع كشف العملات الحقيقية";
            }else {
                //                displayMessage = @"Mode Three";
                displayMessage = @"Detecting real notes mode is active";
            }
            
            file = @"3rd Mode Active";
            self.readingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
            self.calculatingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
            
            self.realNotes.layer.borderColor = [UIColor yellowColor].CGColor;
            
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [style setAlignment:NSTextAlignmentCenter];
            [style setLineBreakMode:NSLineBreakByWordWrapping];
            UIFont *font1 = [UIFont fontWithName:@"Verdana-Bold" size:17.0f];
            NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                    NSFontAttributeName:font1,
                                    NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.yellowColor}; // Added line
            NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                    NSFontAttributeName:font1,
                                    NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.whiteColor}; // Added line
            
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
            if (self.languageSegment.selectedSegmentIndex == 1) {
                [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@" كشف العملة الحقيقية" attributes:dict1]];
            }
            else
            {
                [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Real\nNotes"    attributes:dict1]];
            }
            [[self realNotes] setAttributedTitle:attString forState:UIControlStateNormal];
            NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];
            
            if (self.languageSegment.selectedSegmentIndex == 1) {
                [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"جمع العملات" attributes:dict2]];
                
            }
            else
            {
                [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Calcuating\nNotes"    attributes:dict2]];
            }
            [[self calculatingNotes] setAttributedTitle:attString1 forState:UIControlStateNormal];
            
            NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
            if (self.languageSegment.selectedSegmentIndex == 1) {
                [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"قراءة العملات" attributes:dict2]];
                
            }
            else
            {
                [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Reading\nNotes"    attributes:dict2]];
            }
            [[self readingNotes] setAttributedTitle:attString2 forState:UIControlStateNormal];
            self.calculatingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
            self.calculatingNotes.titleLabel.textColor = [UIColor whiteColor];
            
        [self.viewPreview removeGestureRecognizer:swipeGestureForSecondMode]; //hassan did this
        [self.viewPreview removeGestureRecognizer:swipeGestureForSecondModeUpDown]; //hassan did this
        [self setflashOnOFF:AVCaptureTorchModeOff];
        
        //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudio];
        //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudioUpDown];
        
        [self switchSumGesture:FALSE];
        //hassan did this to start controller initially to prevent modes overlaping
        //and it's working fine with this piece of code
        ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
        //            [sVC.glView start];
        [sVC.glView resetTrackingTarget];
        //for third mode only

            //for third mode only
        if (_cameraSegmentButton.selectedSegmentIndex == 0)
        {
             [self setflashOnOFF:AVCaptureTorchModeOn];
        }
            if([AppUtils getLanguage] == MRAppLanguageArabic)
            {
                [self showModeChangeWith:displayMessage andAudio:file];
            }
            else
            {
                [self utterTextWithString:displayMessage withLocale:@"en-us"];
                [FTIndicator showToastMessage:displayMessage];
            }
            
            //[self.glView stop];
            // [self.glView start];
            //  [self switchSumGesture:FALSE];
            [self setCalculateButtonVisibility];
        }
    
}

#pragma mark - Card Scanner methods

//- (BOOL)startReading {
//    if(!self.glView){
//        self.glView = [[OpenGLView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        //        [self.view addSubview:self.glView];
//        [self.glView setOrientation:self.interfaceOrientation];
//        [self.viewPreview addSubview:self.glView];
//        [self.viewPreview bringSubviewToFront:self.targetImageView];
//    }
//    return YES;
//}



- (void)stopReading {
    [self.captureSession stopRunning];
    self.captureSession = nil;
    
    [self.videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - Audio Support

- (void)initilizeAudioPlayer:(NSString*)file{
    // set our default audio session state
    [self setSessionActiveWithMixing:NO];
    
    file = _languageSegment.selectedSegmentIndex == 0 ? [NSString stringWithFormat:@"%@ Qatari English",file] : [NSString stringWithFormat:@"%@ Qatari Arabic",file];
    
    NSURL *heroSoundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:file ofType:@"m4a"]];
    assert(heroSoundURL);
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:heroSoundURL error:nil];
}

- (void)initilizeSettingsAudio:(NSString*)file{
    // set our default audio session state
    [self setSessionActiveWithMixing:NO];
    file =  [NSString stringWithFormat:@"%@",file];
    NSURL *heroSoundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:file ofType:@"m4a"]];
    assert(heroSoundURL);
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:heroSoundURL error:nil];
}
- (void)setSessionActiveWithMixing:(BOOL)duckIfOtherAudioIsPlaying{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    if ([[AVAudioSession sharedInstance] isOtherAudioPlaying] && duckIfOtherAudioIsPlaying){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers error:nil];
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)playSound{
    assert(self.audioPlayer);
    if (self.audioPlayer && (self.audioPlayer.isPlaying == NO)){
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
        //hassan added this
        if ([AppUtils getMuteState] == YES)
        {
            self.audioPlayer.volume = 0.0;
        }
        else
        {
            self.audioPlayer.volume = 1.0;
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (IBAction)languageAction:(UISegmentedControl *)sender
{
//    [FTIndicator showToastMessage:@"Switching Language..."];

    NSString *languageName,*file;
    if(sender.selectedSegmentIndex == 0)
    {
        [AppUtils saveLanguage:MRAppLanguageEnglish];
        languageName = @"English";
        file = @"English Active";
    }
    else
    {
        [AppUtils saveLanguage:MRAppLanguageArabic];
        languageName = @"العربیة";
        file = @"Arabic Active";
    }
    
    [FTIndicator showToastMessage:languageName];
    [self playSettingsAudio:file];
}

-(void)playSettingsAudio:(NSString*)fileName{
    
    [self initilizeSettingsAudio:fileName];
    assert(self.audioPlayer);
    if (self.audioPlayer && (self.audioPlayer.isPlaying == NO)){
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
        //hassan added this
        if ([AppUtils getMuteState] == YES)
        {
            self.audioPlayer.volume = 0.0;
        }
        else
        {
            self.audioPlayer.volume = 1.0;
        }
        
    }
}
-(void)setCalculateButtonVisibility
{
    if ([AppUtils getAppMode] == MRScanModeMultiple)
    {
        [self.calculateButton setHidden:false];
    }
    else
    {
        [self.calculateButton setHidden:true];
    }
}

-(void)switchSumGesture:(BOOL)abled{
   
    self.showSumGesture.enabled = abled;
    
    self.showSumGesture.enabled = false; //hassan did this to manage new gestures

//    //hassan changes before new gestures
//    if (abled == true) {
//        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(calculateAmount:)];
//        tapGesture.numberOfTapsRequired = 2;
//        [self.viewPreview addGestureRecognizer:tapGesture];
//
//        self.showSumGesture.enabled = false;
//    }
//    else {
//        self.showSumGesture.enabled = false;
//        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture)];
//        tapGesture.numberOfTapsRequired = 2;
//        [self.viewPreview addGestureRecognizer:tapGesture];
//    }
//    //end
}

//hassan changes below till end
- (IBAction)aboutButtonTarget:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFromAbout"];
    SubScreenActive = YES;
    aboutView = [[UIView alloc]initWithFrame:CGRectMake(0, 20 + [[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    [aboutView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    [imageView setImage:[UIImage imageNamed:@"about"]];
    if (self.languageSegment.selectedSegmentIndex == 1)
    {
        [imageView setImage:[UIImage imageNamed:@"aboutAR"]];
    }
    [aboutView addSubview:imageView];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen]bounds].size.height * 0.65, [[UIScreen mainScreen]bounds].size.width - 20, [[UIScreen mainScreen]bounds].size.height/2)];
    [textView setUserInteractionEnabled:NO];
    [textView setFont:[UIFont systemFontOfSize:24]];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setHidden:YES];

    [aboutView addSubview:textView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width - 120)/2, [[UIScreen mainScreen]bounds].size.height - 60, 120, 40)];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton.layer setCornerRadius:10.0];
    [backButton.layer setBorderWidth:5.0];
    [backButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [backButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [aboutView addSubview:backButton];
    
    NSString *locale;
    if([AppUtils getLanguage] == MRAppLanguageArabic)
    {
        locale = @"ar-SA";
        [textView setText:@"تطبيق قارئ العملة القطرية حاصل على كامل الدعم من شركة مدى مركز التكنلوجيا المساعدة"];
//        [textView setTextAlignment:NSTextAlignmentRight];
        [backButton setTitle:@"→" forState:UIControlStateNormal];
    }
    else
    {
        locale = @"en-us";
        [textView setText:@"Money Reader App for Qatari currency completely funded and supported by Mada Assistive Technology"];
//        [textView setTextAlignment:NSTextAlignmentLeft];
        [backButton setTitle:@"←" forState:UIControlStateNormal];
    }
    
    [self utterTextWithString:textView.text withLocale:locale];
    [self.view addSubview:aboutView];
    
    UITapGestureRecognizer *tapGestureForRemoveView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    tapGestureForRemoveView.numberOfTouchesRequired = 1;
    [aboutView addGestureRecognizer:tapGestureForRemoveView];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _viewPreview.hidden = YES;

                         aboutView.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
                     }
                     completion:^(BOOL finished){
//                         [view removeFromSuperview];
                         
                     }];
}
-(void)dismissView1
{
    [aboutView removeFromSuperview];
    [howToUseView removeFromSuperview];
    _viewPreview.hidden = NO;
    [self activeReadingNotes];
    [mySVC.glView setTotalSumToZer];
    [mySVC.glView removeTrackingID];
}
-(void)dismissView
{
    SubScreenActive = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFromAbout"];
    [UIView animateWithDuration:0.2
                     animations:^{
                         _viewPreview.hidden = NO;

                         aboutView.frame = CGRectMake(0, 20 + [[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
                        
                         howToUseView.frame = CGRectMake(0, 20 + [[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
                     }
                     completion:^(BOOL finished){
                         [aboutView removeFromSuperview];
                         [howToUseView removeFromSuperview];

                     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTTS" object:nil];
}

-(void)changeLTR
{
    if([AppUtils getLanguage] == MRAppLanguageArabic)
    {
        [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        delegate.window.rootViewController = [storyboard instantiateInitialViewController];
    }
    else
    {
        [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        delegate.window.rootViewController = [storyboard instantiateInitialViewController];
    }        
}

-(void)loadButtons
{
    if ([AppUtils getMuteState])
    {
        _audioSegmentButton.selectedSegmentIndex = 1;
    }
    
    NSString *flashOn;
    NSString *flashOff;
    NSString *audioOn;
    NSString *audioOff;
    NSString *cameraBack;
    NSString *cameraFront;
    NSString *total;
    NSString *about;
    NSString *howToUse;
    NSString *readNotes;
    NSString *calcNotes;
    NSString *realNotes;

    if([AppUtils getLanguage] == MRAppLanguageArabic)
    {
        flashOn = @"تشغيل الضوء";
        flashOff = @"إغلاق الضوء";
        audioOn = @"تشغيل الصوت";
        audioOff = @"إغلاق الصوت";
        cameraBack = @"الكاميرا الخلفية";
        cameraFront = @"الكاميرا الأمامية";
        total = @"المجموع";
        about = @"معلومات عنا";
        howToUse = @"كيفية الإستخدام";
        readNotes = @"قراءة العملات";
        calcNotes = @"جمع العملات";
        realNotes = @" كشف العملة الحقيقية";

    }
    else
    {
        flashOn = @"Flash ON";
        flashOff = @"Flash OFF";
        audioOn = @"Audio ON";
        audioOff = @"Audio OFF";
        cameraBack = @"Back Camera";
        cameraFront = @"Front Camera";
        total = @"Total Amount";
        about = @"About Us";
        howToUse = @"How to use?";
        readNotes = @"Reading Notes";
        calcNotes = @"Calculating Notes";
        realNotes = @"Real \n Notes";
    }
    [[UILabel appearanceWhenContainedIn:[UISegmentedControl class], nil] setNumberOfLines:0];

    [_notesSegmentButton setTitle:readNotes forSegmentAtIndex:0];
    [_notesSegmentButton setTitle:calcNotes forSegmentAtIndex:1];
    [_notesSegmentButton setTitle:realNotes forSegmentAtIndex:2];

    [_flashSegmentButton setTitle:flashOff forSegmentAtIndex:0];
    [_flashSegmentButton setTitle:flashOn forSegmentAtIndex:1];

    [_audioSegmentButton setTitle:audioOn forSegmentAtIndex:0];
    [_audioSegmentButton setTitle:audioOff forSegmentAtIndex:1];
    [_cameraSegmentButton setTitle:cameraBack forSegmentAtIndex:0];
    [_cameraSegmentButton setTitle:cameraFront forSegmentAtIndex:1];
    for(UIView *subview in _cameraSegmentButton.subviews) {
        if([NSStringFromClass(subview.class) isEqualToString:@"UISegment"]) {
            for(UIView *segmentSubview in subview.subviews) {
                if([NSStringFromClass(segmentSubview.class) isEqualToString:@"UISegmentLabel"]) {
                    UILabel *label = (id)segmentSubview;
                    label.numberOfLines = 2;
//                    label.text = cameraFront;
                    CGRect frame = label.frame;
                    frame.size = label.superview.frame.size;
                    label.frame = frame;
                }
            }
        }
    }
    for(UIView *subview in _notesSegmentButton.subviews) {
        if([NSStringFromClass(subview.class) isEqualToString:@"UISegment"]) {
            for(UIView *segmentSubview in subview.subviews) {
                if([NSStringFromClass(segmentSubview.class) isEqualToString:@"UISegmentLabel"]) {
                    UILabel *label = (id)segmentSubview;
                    label.numberOfLines = 2;
                    //                    label.text = cameraFront;
                    CGRect frame = label.frame;
                    frame.size = label.superview.frame.size;
                    label.frame = frame;
                }
            }
        }
    }
    [_calculateButton setTitle:total forState:UIControlStateNormal];
    [_aboutButton setTitle:about forState:UIControlStateNormal];
    [_howToUseButton setTitle:howToUse forState:UIControlStateNormal];
}




- (IBAction)flashSegmentTarget:(UISegmentedControl *)sender
{
    if (_flashSegmentButton.selectedSegmentIndex == 1)
    {
        _flashSegmentButton.selectedSegmentIndex = 1;
    }
    else
    {
        _flashSegmentButton.selectedSegmentIndex = 0;
    }
    
    if (mySVC.glView.cameraType == easyar_CameraDeviceType_Default && isFrontCamera == YES)
    {
        _flashSegmentButton.selectedSegmentIndex = 0;
        if (SubScreenActive == NO)
        {
        [FTIndicator showToastMessage:@"Flash not available on Front Camera"];
        }
    }
    else
    {
        NSString *displayMessage;
        if(sender.selectedSegmentIndex == 0)
        {
            displayMessage = @"Flash OFF";
            [self setflashOnOFF:AVCaptureTorchModeOff];
        }
        else
        {
            displayMessage = @"Flash ON";
            [self setflashOnOFF:AVCaptureTorchModeOn];
        }
        if (SubScreenActive == NO)
        {
            [self utterTextWithString:displayMessage withLocale:@"en-us"];
        [FTIndicator showToastMessage:displayMessage];
        }
    }
}

-(IBAction)audioSegmentTarget:(UISegmentedControl *)sender {
    
    
    if (_audioSegmentButton.selectedSegmentIndex == 1)
    {
        _audioSegmentButton.selectedSegmentIndex = 1;
    }
    else
    {
        _audioSegmentButton.selectedSegmentIndex = 0;
    }

//    [AppUtils saveMuteState:![AppUtils getMuteState]]; //HASSAN COMMENTED IT TO PLAY AUDIO OF "SOUND OFF"
    
    NSString *displayMessage;
    NSString *fileName;
    if (![AppUtils getMuteState])
    {
        if([AppUtils getLanguage] == MRAppLanguageArabic)
        {
            displayMessage = @"Sound OFF";
            fileName = @"Vibration+Sound Disabled";
            [self playSettingsAudio:fileName];

            [AppUtils saveMuteState:![AppUtils getMuteState]];
        }
        else
        {
            displayMessage = @"Sound OFF";
            [self utterTextWithString:[NSString stringWithFormat:@"Sound OFF"] withLocale:@"en-us"];
            [AppUtils saveMuteState:![AppUtils getMuteState]];
        }
    }
    else
    {
        [AppUtils saveMuteState:![AppUtils getMuteState]];

        if([AppUtils getLanguage] == MRAppLanguageArabic)
        {
            displayMessage = @"Sound ON";
            fileName = @"Vibration+Sound Active";
            [self playSettingsAudio:fileName];
        }
        else
        {
            displayMessage = @"Sound ON";
            [self utterTextWithString:[NSString stringWithFormat:@"Sound ON"] withLocale:@"en-us"];
        }
    }
    
    [FTIndicator showToastMessage:displayMessage];
}

-(IBAction)cameraSegmentTarget:(UISegmentedControl *)sender
{
    NSString *displayMessage;

    if (_cameraSegmentButton.selectedSegmentIndex == 1)
    {
        _cameraSegmentButton.selectedSegmentIndex = 1;

        if (mySVC.glView.cameraType == easyar_CameraDeviceType_Default && isFrontCamera == NO)
        {
            displayMessage = @"Front Camera";

            [mySVC.glView switchCamera:easyar_CameraDeviceType_Front];
            isFrontCamera = YES;
            _flashSegmentButton.selectedSegmentIndex = 0;
        }
    }
    else
    {
        _cameraSegmentButton.selectedSegmentIndex = 0;
        
        if (mySVC.glView.cameraType == easyar_CameraDeviceType_Default && isFrontCamera == YES)
        {
            displayMessage = @"Back Camera";
            [mySVC.glView switchCamera:easyar_CameraDeviceType_Default];
            isFrontCamera = NO;
        }
        if (_notesSegmentButton.selectedSegmentIndex == 2)
        {
            [self setflashOnOFF:AVCaptureTorchModeOn];
        }
    }
    if (SubScreenActive == NO)
    {
    [self utterTextWithString:displayMessage withLocale:@"en-us"];
    [FTIndicator showToastMessage:displayMessage];
    }
}

-(void)stopTTS
{
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
}

-(void)setflashOnOFF:(AVCaptureTorchMode)mode
{
    if (mode == AVCaptureTorchModeOn)
    {
        _flashSegmentButton.selectedSegmentIndex = 1;
    }
    else
    {
        _flashSegmentButton.selectedSegmentIndex = 0;
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchModeOnWithLevel:0.2 error:NULL];
        [device setTorchMode:mode];
        [device unlockForConfiguration];
    }
}

- (IBAction)howToUseTarget:(id)sender
{
int fontSize = [[UIScreen mainScreen]bounds].size.height==568?12:15;
    SubScreenActive = YES;
howToUseView = [[UIView alloc]initWithFrame:CGRectMake(0, 20 + [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
[howToUseView setBackgroundColor:[UIColor whiteColor]];
[self.view addSubview:howToUseView];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    [imageView setImage:[UIImage imageNamed:@"howToUse"]];
    if (self.languageSegment.selectedSegmentIndex == 1)
    {
        [imageView setImage:[UIImage imageNamed:@"howToUseAR"]];
    }
    [howToUseView addSubview:imageView];
    
UILabel *howToScanLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, [[UIScreen mainScreen]bounds].size.width-20, 20)];
[howToScanLabel setFont:[UIFont boldSystemFontOfSize:18]];
//    [howToScanLabel setBackgroundColor:[UIColor blueColor]];
    [howToScanLabel setHidden:YES];
[howToUseView addSubview:howToScanLabel];

int y = 60;
UILabel *howToScanDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, [[UIScreen mainScreen]bounds].size.height * 0.1)];
[howToScanDescription setFont:[UIFont systemFontOfSize:fontSize]];
[howToScanDescription setNumberOfLines:3];
//    [howToScanDescription setBackgroundColor:[UIColor redColor]];
    [howToScanDescription setHidden:YES];

[howToUseView addSubview:howToScanDescription];

y += howToScanDescription.frame.size.height + 20;
UILabel *switchingLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, 20)];
[switchingLabel setFont:[UIFont boldSystemFontOfSize:18]];
//    [switchingLabel setBackgroundColor:[UIColor brownColor]];
    [switchingLabel setHidden:YES];

[howToUseView addSubview:switchingLabel];

y += switchingLabel.frame.size.height;
UILabel *switchingDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, [[UIScreen mainScreen]bounds].size.height * 0.3)];
[switchingDescription setFont:[UIFont systemFontOfSize:fontSize]];
[switchingDescription setNumberOfLines:12];
//    [switchingDescription setBackgroundColor:[UIColor greenColor]];
    [switchingDescription setHidden:YES];

[howToUseView addSubview:switchingDescription];

y += switchingDescription.frame.size.height + 20;
UILabel *vibrationPatternLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, 20)];
[vibrationPatternLabel setFont:[UIFont boldSystemFontOfSize:18]];
//    [vibrationPatternLabel setBackgroundColor:[UIColor yellowColor]];
    [vibrationPatternLabel setHidden:YES];

[howToUseView addSubview:vibrationPatternLabel];

y += switchingLabel.frame.size.height;
UILabel *vibrationPatternDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, [[UIScreen mainScreen]bounds].size.height * 0.28)];
[vibrationPatternDescription setFont:[UIFont systemFontOfSize:fontSize]];
[vibrationPatternDescription setNumberOfLines:10];
    [vibrationPatternDescription setHidden:YES];

//    [vibrationPatternDescription setBackgroundColor:[UIColor purpleColor]];
[howToUseView addSubview:vibrationPatternDescription];

int minusY = [[UIScreen mainScreen]bounds].size.height==568?45:60;

UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width - 120)/2, [[UIScreen mainScreen]bounds].size.height - minusY, 120, 40)];
[backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
[backButton.layer setCornerRadius:10.0];
[backButton.layer setBorderWidth:5.0];
[backButton.layer setBorderColor:[UIColor blackColor].CGColor];
[backButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
[howToUseView addSubview:backButton];

NSString *locale;
if([AppUtils getLanguage] == MRAppLanguageArabic)
{
    locale = @"ar-SA";
    [howToScanLabel setText:@"كيفية قراءة العملات"];
    [howToScanDescription setText:@"إفتح التطبيق وثَبّت العملة لكي يستطيع  الهاتف المحمول من قراءة العملة باستخدام الكاميرا وإعطاء قيمة العملة "];
    
    [switchingLabel setText:@"تغير الوضعيات والخيارات:"];
    [switchingDescription setText:@"التطبيق يحتوي على ٣ وضعيات كما هو موضّح أدناه: \n\n ١ الوضع الأول لقراءة العملات \n ٢ الوضع الثاني لجمع العملات الورقية \n ٣ الوضع الثالث لكشف العملات الحقيقية \n\nالمستخدم يستطيع تغيير الأوضاع عن طريق هَزّ الموبايل \nلكي ينتقل التطبيق للوضع الآخر \n\nالوضع الأول وهو قراءة العملات هو الوضع التلقائي عند \nفتح التطبيق في كل مرة."];
    
    [vibrationPatternLabel setText:@"ترجمة الاهتزاز المختلفة:"];
    [vibrationPatternDescription setText:@"التطبيق مصمم ليعطي إهتزاز مختلف لكل قيمة عملة تمت قراءتها، ترجمة الاهتزاز لكل قيمة موضحة أدناه: \n\n ٥٠٠ ريال = ٣ اهتزازات (وقفات قصيرة بين كل هزّة) \n ١٠٠ ريال = ٣ اهتزازات (وقفات طويلة بين كل هزّة) \n ٥٠ ريال = ٢ اهتزازين (وقفات قصيرة بين كل هزّة) \n ١٠ ريال = ٢ اهتزازين (وقفات طويلة بين كل هزّة) \n ٥ ريال = ٢ اهتزازين (وقفة طويلة جدا قصيرة بين كل هزّة) \n ١ ريال = ١ هزّة واحدة"];
    
    [backButton setTitle:@"→" forState:UIControlStateNormal];
}
else
{
    locale = @"en-us";
    [howToScanLabel setText:@"How To Scan?"];
    [howToScanDescription setText:@"Open the app and hold the notes to allow the phone to face the note in order to scan the note via the camera and say the value."];
    
    [switchingLabel setText:@"Switching between modes:"];
    [switchingDescription setText:@"The app has 3 different modes as follow:\n\n 1) First mode to scan notes \n 2) Second mode to calculate notes \n 3) Third mode to detect real notes \n\nUser able to switch between modes by shaking the phone to go to the next mode.\n\nThe first mode is the default mode when the app opening every time."];
    
    [vibrationPatternLabel setText:@"Vibration patterns meaning:"];
    [vibrationPatternDescription setText:@"The app customised vibration patterns for each notes to know the exact value, below the translation of each: \n\n 500 Riyal = 3x vibration (short pauses) \n 100 Riyal = 3x vibration (long pauses) \n 50 Riyal = 2x vibration (short pauses) \n 10 Riyal = 2x vibration (long pauses) \n 5 Riyal = 2x vibration (very long pauses) \n 1 Riyal = 1x vibration"];
    
    [backButton setTitle:@"←" forState:UIControlStateNormal];
}

NSString *totalSpeech = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",howToScanLabel.text, howToScanDescription.text, switchingLabel.text, switchingDescription.text, vibrationPatternLabel.text, vibrationPatternDescription.text];
[self utterTextWithString:totalSpeech withLocale:locale];

UITapGestureRecognizer *tapGestureForRemoveView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
tapGestureForRemoveView.numberOfTouchesRequired = 1;
[howToUseView addGestureRecognizer:tapGestureForRemoveView];
    
[self.view bringSubviewToFront:howToUseView];
    [UIView animateWithDuration:0.2
                     animations:^{
                         _viewPreview.hidden = YES;
                         howToUseView.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
                     }
                     completion:^(BOOL finished){
                         //                         [view removeFromSuperview];
                         
                     }];
}
-(void)activeReadingNotes
{
    [self.cameraSegmentButton setSelectedSegmentIndex:0];
    [self startCamera];
    NSString *displayMessage,*file;
    isMultiMode = !isMultiMode;
    [AppUtils saveAppMode:MRScanModeSingle];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        //                displayMessage = @"تمكين وضع واحد";
        displayMessage = @"وضع قراءة العملات";
    }else {
        //                displayMessage = @"Single Mode Enable";
        displayMessage = @"Reading notes mode is active";
    }
    
    file = @"1st Mode Active";
    
    self.readingNotes.layer.borderColor = [UIColor yellowColor].CGColor;
    self.calculatingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.realNotes.layer.borderColor = [UIColor whiteColor].CGColor;
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    UIFont *font1 = [UIFont fontWithName:@"Verdana-Bold" size:17.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.yellowColor}; // Added line
    NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.whiteColor}; // Added line
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@" كشف العملة الحقيقية" attributes:dict2]];
    }
    else
    {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Real\nNotes"    attributes:dict2]];
    }
    [[self realNotes] setAttributedTitle:attString forState:UIControlStateNormal];
    NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];
    
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"جمع العملات" attributes:dict2]];
        
    }
    else
    {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Calcuating\nNotes"    attributes:dict2]];
    }
    [[self calculatingNotes] setAttributedTitle:attString1 forState:UIControlStateNormal];
    
    NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"قراءة العملات" attributes:dict1]];
        
    }
    else
    {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Reading\nNotes"    attributes:dict1]];
    }
    [[self readingNotes] setAttributedTitle:attString2 forState:UIControlStateNormal];
    self.notesSegmentButton.selectedSegmentIndex = 0;
    [self setflashOnOFF:AVCaptureTorchModeOff];
    
    [self.viewPreview removeGestureRecognizer:swipeGestureForSecondMode]; //hassan did this
    [self.viewPreview removeGestureRecognizer:swipeGestureForSecondModeUpDown]; //hassan did this
    
    //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudio];
    //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudioUpDown];
    
    [self switchSumGesture:FALSE];
    //hassan did this to start controller initially to prevent modes overlaping
    //and it's working fine with this piece of code
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
    //            [sVC.glView start];
    [sVC.glView resetTrackingTarget];
    
    _flashSegmentButton.selectedSegmentIndex = 0;
    if([AppUtils getLanguage] == MRAppLanguageArabic)
    {
        [self showModeChangeWith:displayMessage andAudio:file];
    }
    else
    {
        [self utterTextWithString:displayMessage withLocale:@"en-us"];
        [FTIndicator showToastMessage:displayMessage];
    }
    
    //[self.glView stop];
    // [self.glView start];
    //  [self switchSumGesture:FALSE];
    [self setCalculateButtonVisibility];

}

//hassan changes end

- (IBAction)readingNotes:(UIButton *)sender {
    [mySVC.glView setTotalSumToZer];
    [mySVC.glView removeTrackingID];
    NSString *displayMessage,*file;
    isMultiMode = !isMultiMode;
    [AppUtils saveAppMode:MRScanModeSingle];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        //                displayMessage = @"تمكين وضع واحد";
        displayMessage = @"وضع قراءة العملات";
    }else {
        //                displayMessage = @"Single Mode Enable";
        displayMessage = @"Reading notes mode is active";
    }
    
    file = @"1st Mode Active";
    
    self.readingNotes.layer.borderColor = [UIColor yellowColor].CGColor;
    self.calculatingNotes.layer.borderColor = [UIColor whiteColor].CGColor;

    self.realNotes.layer.borderColor = [UIColor whiteColor].CGColor;

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    UIFont *font1 = [UIFont fontWithName:@"Verdana-Bold" size:17.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.yellowColor}; // Added line
    NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.whiteColor}; // Added line
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@" كشف العملة الحقيقية" attributes:dict2]];
    }
    else
    {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Real\nNotes"    attributes:dict2]];
    }
    [[self realNotes] setAttributedTitle:attString forState:UIControlStateNormal];
    NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];
    
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"جمع العملات" attributes:dict2]];
        
    }
    else
    {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Calcuating\nNotes"    attributes:dict2]];
    }
    [[self calculatingNotes] setAttributedTitle:attString1 forState:UIControlStateNormal];
    
    NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"قراءة العملات" attributes:dict1]];
        
    }
    else
    {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Reading\nNotes"    attributes:dict1]];
    }
    [[self readingNotes] setAttributedTitle:attString2 forState:UIControlStateNormal];
    
    [self setflashOnOFF:AVCaptureTorchModeOff];

    [self.viewPreview removeGestureRecognizer:swipeGestureForSecondMode]; //hassan did this
    [self.viewPreview removeGestureRecognizer:swipeGestureForSecondModeUpDown]; //hassan did this
    
    //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudio];
    //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudioUpDown];
    
    [self switchSumGesture:FALSE];
    //hassan did this to start controller initially to prevent modes overlaping
    //and it's working fine with this piece of code
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
    //            [sVC.glView start];
    [sVC.glView resetTrackingTarget];
    
    _flashSegmentButton.selectedSegmentIndex = 0;
    if([AppUtils getLanguage] == MRAppLanguageArabic)
    {
        [self showModeChangeWith:displayMessage andAudio:file];
    }
    else
    {
        [self utterTextWithString:displayMessage withLocale:@"en-us"];
        [FTIndicator showToastMessage:displayMessage];
    }
    
    //[self.glView stop];
    // [self.glView start];
    //  [self switchSumGesture:FALSE];
    [self setCalculateButtonVisibility];
}

- (IBAction)calculatingNotes:(UIButton *)sender {
    [mySVC.glView setTotalSumToZer];
//    [mySVC.glView removeTrackingID];
    NSString *displayMessage,*file;
    isMultiMode = !isMultiMode;
    
    [AppUtils saveAppMode:MRScanModeMultiple];
    
    if (self.languageSegment.selectedSegmentIndex == 1) {
        //                displayMessage = @"تمكين وضع متعدد";
        displayMessage = @"وضع جمع العملات";
    }else {
        //                displayMessage = @"Multi Mode Enable";
        displayMessage = @"Calculating notes mode is active";
    }
    [self setflashOnOFF:AVCaptureTorchModeOff];

    file = @"2nd Mode Active";
    self.readingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
    self.calculatingNotes.layer.borderColor = [UIColor yellowColor].CGColor;
    
    self.realNotes.layer.borderColor = [UIColor whiteColor].CGColor;

    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    UIFont *font1 = [UIFont fontWithName:@"Verdana-Bold" size:17.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.yellowColor}; // Added line
    NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.whiteColor}; // Added line
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1)
    {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"كشف العملة الحقيقية" attributes:dict2]];
    }
    else
    {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Real\nNotes"    attributes:dict2]];
    }
    [[self realNotes] setAttributedTitle:attString forState:UIControlStateNormal];
    NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];
    
    if (self.languageSegment.selectedSegmentIndex == 1)
    {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"جمع العملات" attributes:dict1]];
    }
    else
    {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Calcuating\nNotes" attributes:dict1]];
    }
    [[self calculatingNotes] setAttributedTitle:attString1 forState:UIControlStateNormal];
    
    NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1)
    {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"قراءة العملات" attributes:dict2]];
    }
    else
    {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Reading\nNotes"    attributes:dict2]];
    }
    [[self readingNotes] setAttributedTitle:attString2 forState:UIControlStateNormal];
    //hassan did this
    [self.viewPreview addGestureRecognizer:swipeGestureForSecondMode];
    [self.viewPreview addGestureRecognizer:swipeGestureForSecondModeUpDown];
    
    // [self.viewPreview removeGestureRecognizer:swipeGestureForMuteAudio];
    // [self.viewPreview removeGestureRecognizer:swipeGestureForMuteAudioUpDown];
    
    [self switchSumGesture:TRUE];
    
    if([AppUtils getLanguage] == MRAppLanguageArabic)
    {
        [self showModeChangeWith:displayMessage andAudio:file];
    }
    else
    {
        [self utterTextWithString:displayMessage withLocale:@"en-us"];
        [FTIndicator showToastMessage:displayMessage];
    }
    
    //[self.glView stop];
    // [self.glView start];
    //  [self switchSumGesture:FALSE];
    [self setCalculateButtonVisibility];
}


- (IBAction)realNotes:(UIButton *)sender {
    [mySVC.glView setTotalSumToZer];
//    [mySVC.glView removeTrackingID];
    
    NSString *displayMessage,*file;
    isMultiMode = !isMultiMode;
    [AppUtils saveAppMode:MRScanModeFakeORReal];
    
    if (self.languageSegment.selectedSegmentIndex == 1) {
        //                displayMessage = @"الوضع الثالث";
        displayMessage = @"وضع كشف العملات الحقيقية";
    }
    else
    {
        //                displayMessage = @"Mode Three";
        displayMessage = @"Detecting real notes mode is active";
    }
    
    file = @"3rd Mode Active";
    self.readingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
    self.calculatingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.realNotes.layer.borderColor = [UIColor yellowColor].CGColor;

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    UIFont *font1 = [UIFont fontWithName:@"Verdana-Bold" size:17.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.yellowColor}; // Added line
    NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName :  UIColor.whiteColor}; // Added line

    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"كشف العملة الحقيقية" attributes:dict1]];
    }
    else
    {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Real\nNotes"    attributes:dict1]];
    }
    [[self realNotes] setAttributedTitle:attString forState:UIControlStateNormal];
    NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];

    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"جمع العملات" attributes:dict2]];
        
    }
    else
    {
        [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Calcuating\nNotes"    attributes:dict2]];
    }
    [[self calculatingNotes] setAttributedTitle:attString1 forState:UIControlStateNormal];

    NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
    if (self.languageSegment.selectedSegmentIndex == 1) {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"قراءة العملات" attributes:dict2]];
        
    }
    else
    {
        [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:@"Reading\nNotes"    attributes:dict2]];
    }
    [[self readingNotes] setAttributedTitle:attString2 forState:UIControlStateNormal];
    self.calculatingNotes.layer.borderColor = [UIColor whiteColor].CGColor;
    self.calculatingNotes.titleLabel.textColor = [UIColor whiteColor];

    [self.viewPreview removeGestureRecognizer:swipeGestureForSecondMode];
    [self.viewPreview removeGestureRecognizer:swipeGestureForSecondModeUpDown];
    
    //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudio];
    //            [self.viewPreview addGestureRecognizer:swipeGestureForMuteAudioUpDown];
    
    [self switchSumGesture:FALSE];
    
    ScannerController* sVC = (ScannerController*)self.childViewControllers.firstObject;
    [sVC.glView startTrackingRealNote];
    
    //for third mode only
    [self setflashOnOFF:AVCaptureTorchModeOn];
    if([AppUtils getLanguage] == MRAppLanguageArabic)
    {
        [self showModeChangeWith:displayMessage andAudio:file];
    }
    else
    {
        [self utterTextWithString:displayMessage withLocale:@"en-us"];
        [FTIndicator showToastMessage:displayMessage];
    }
    
    //[self.glView stop];
    // [self.glView start];
    //  [self switchSumGesture:FALSE];
    [self setCalculateButtonVisibility];
}


@end
