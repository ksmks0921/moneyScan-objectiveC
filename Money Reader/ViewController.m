//
//  ViewController.m
//  Money Reader
//
//  Created by Muhammad Ahsan on 4/12/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import "ScannedNoteViewController.h"
#import "FTIndicator.h"

@import UIKit;
@import AVFoundation;       // for AVAudioSession

@interface ViewController ()<TCMCardScannerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self scanAction:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanAction:(id)sender {
    ScanViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    //[controller setDelegate:self];
    [self presentViewController:controller animated:NO completion:nil];
}

-(void)cardScannerViewControllerDidFinishWithScan:(NSString *)scanString
   {
    
    [FTIndicator showToastMessage:[NSString stringWithFormat:@"%@\nQatari Riyal",scanString]];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

//    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:scanString message:[NSString stringWithFormat:@"%@ Qatari Riyal",scanString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    [self initilizeAudioPlayer:scanString];
    assert(self.audioPlayer);
    if (self.audioPlayer && (self.audioPlayer.isPlaying == NO)){
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}


#pragma mark - Audio Support

- (void)initilizeAudioPlayer:(NSString*)file{
    // set our default audio session state
    [self setSessionActiveWithMixing:NO];
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
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

@end
