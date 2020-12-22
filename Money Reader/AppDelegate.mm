//
//  AppDelegate.m
//  Money Reader
//
//  Created by Muhammad Ahsan on 4/12/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "AppDelegate.h"
//#import <easyar/utility.hpp>
#import <UIKit/UIKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AppUtils.h"
#import <easyar/engine.oc.h>
#import "FTIndicator.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ScannerController.h"
#import "ScanViewController.h"

//NSString * key = @"GWe9pra5Wp0Vykp2PWg4HAA803IUKXngf2lf4byrmoQ6eJFS2KGRF531BMZ89lKLYCo8SjXlKC7M8nhKfpnIMxohDGfXGWEN33sGnpMDseKE2GuvsZhMbhuXmimj7cxjmxbbwN4jZ7otNqCrL9dI6vzm8Kzfi65RVG7zORUnHJPTpIFXXEjX60pw0w84IuPPL9qOfSOV";
//hassan changes
NSString * key;


@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize audioPlayer, selectedLanguageIndex;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLocalizedString(@"CFBundleDisplayName", nil);
    NSLocalizedString(@"CFBundleName", nil);
    
    //hassan added it later
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSArray *chunks = [language componentsSeparatedByString:@"-"];
    if ([[chunks objectAtIndex:0] isEqualToString:@"ar"])
    {
        [AppUtils saveLanguage:MRAppLanguageArabic];
    }
    else
    {
        [AppUtils saveLanguage:MRAppLanguageEnglish];
    }
    
    
    [AppUtils saveAppMode:MRScanModeSingle];
    [AppUtils saveMuteState:NO];

    //hassan added it later
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
    //end
    
    sleep(2);

//    (void)application; //hassan commented it to increase loading speed
//    (void)launchOptions; //hassan commented it to increase loading speed
    
    //hassan changes
//#ifdef QatarBuild
    key = @"MM25ju4U1gf8aobA3MEIRHjRawckc8wjbOhvVbDQyJkZ0cEI0qHnWrex6Zb27H6xLxBG6ao6t5h70TktdNGPAG5VnBTJO2iVxYGCoTi7cLHvlaCnEiMB8ApxM2tTniJGMPon8qraNNWHaYGMhr1SL7o3d3PxKWfPFoTygFRdT0nlwqt1J2FetrRYGjqQ28ED3pkD2e1T";
//#else
//    key = @"r0yxo96P8MHvTgY5YrRUMr4dQvU9TMCCl0iUXiAl2nsRfCdSoji9agybnhp6JGof6RUnUGGXNHf5BJHdG8tNE62cX7fIjBaCl6xTTf5GxRiJjAsEBp86xstkbfv7PV8YLUkR7418wepR287aveOvHFbEGOVV7gjMEX2KYU8szQA7almUPVtYVKXPMbKkfYosxTnXj78i";
//#endif
    //changes end

    if (![easyar_Engine initialize:key]) {
        NSLog(@"Initialization Failed.");
    }
    
    [Fabric with:@[[Crashlytics class]]];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//    (void)application;
    [easyar_Engine onPause];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isBackGround"] == NO)
    {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissView11" object:nil];
     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isBackGround"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTTS" object:nil];

    (void)application;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    (void)application;
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    //hassan did this
    [AppUtils saveAppMode:MRScanModeSingle];
    [AppUtils saveMuteState:NO];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"startCamera" object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideCalculateButton" object:nil];

    [self showWelcomeNoteToUser];
    //changes end
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isBackGround"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _active = true;
    [easyar_Engine onResume];
    
    
//    if([AppUtils getLanguage] == MRAppLanguageArabic)
//    {
//        [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
//        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSString *storyboardName = @"Main";
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
//        delegate.window.rootViewController = [storyboard instantiateInitialViewController];
//    }
//    else
//    {
//        [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
//        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSString *storyboardName = @"Main";
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
//        delegate.window.rootViewController = [storyboard instantiateInitialViewController];
//    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    (void)application;
    _active = false;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFromAbout"];
}

-(void)didfoundView:(NSString*)text type:(NSString*)type{
//    NSLog(@"Type: %@",type);
//    NSLog(@"Text: %@",text);
//    _active = false;
    //    EasyAR::onPause();
//    EasyAR::onResume();

    
}

-(void)showWelcomeNoteToUser {
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"Language"] isEqualToString:@"ar"]){
        selectedLanguageIndex = 1;
    }else{
        selectedLanguageIndex = 0;
    }

    NSString *displayMessage;
    if (selectedLanguageIndex == 1)
    {
        displayMessage = @"مرحبا بكم في قارئ العملة القطرية";
        [self playSettingsAudio:@"Qatari Welcome"];
    }
    else
    {
        displayMessage = @"Welcome to QAR Reader App";
        [self utterTextWithString:[NSString stringWithFormat:@"Welcome to Qatari money reader App"] withLocale:@"en-us"];
    }
    
    [FTIndicator showToastMessage:displayMessage];
}

-(void)utterTextWithString:(NSString *)text withLocale:(NSString *)locale
{
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    
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

#pragma mark - Audio Support

- (void)initilizeAudioPlayer:(NSString*)file{
    // set our default audio session state
    [self setSessionActiveWithMixing:NO];
    
    file = selectedLanguageIndex == 0 ? [NSString stringWithFormat:@"%@ Qatari English",file] : [NSString stringWithFormat:@"%@ Qatari Arabic",file];
    
    
    NSURL *heroSoundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:file ofType:@"m4a"]];
    assert(heroSoundURL);
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:heroSoundURL error:nil];
}

- (void)initilizeSettingsAudio:(NSString*)file{
    // set our default audio session state
    [self setSessionActiveWithMixing:NO];
    file =  [NSString stringWithFormat:@"%@",file];
    NSURL *heroSoundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:file ofType:@"m4a"]];
    assert(heroSoundURL);
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:heroSoundURL error:nil];
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
@end
