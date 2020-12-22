//
//  AppUtils.m
//  Money Reader
//
//  Created by Syed Qamar Abbas on 2017-11-17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "AppUtils.h"

@implementation AppUtils
+(void)saveAppMode:(MRScanMode)mode {
    if (mode == MRScanModeSingle) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"AppMode"];
    }else if(mode == MRScanModeMultiple) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"AppMode"];
    }else{
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"AppMode"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(MRScanMode)getAppMode {
    NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"AppMode"];
    if (mode == 0) {
        return MRScanModeMultiple;
    }else if(mode == 1){
         return MRScanModeSingle;
    }else{
         return MRScanModeFakeORReal;
    }
   
}
+(void)saveLanguage:(MRAppLanguage)language {
    if (language == MRAppLanguageArabic) {
        
          [[NSUserDefaults standardUserDefaults] setValue:@"ar" forKey:@"Language"];
    }else {
         [[NSUserDefaults standardUserDefaults] setValue:@"en" forKey:@"Language"];
    }
    
     [[NSUserDefaults standardUserDefaults] synchronize];
}

+(MRAppLanguage)getLanguage
{
    NSString *lang = [[NSUserDefaults standardUserDefaults] valueForKey:@"Language"];
    if ([lang  isEqual: @"ar"]) {
        
        return MRAppLanguageArabic;
    }else {
        return MRAppLanguageEnglish;
    }
}

+(void)saveVibrationState:(BOOL)shouldPlay
{
    [[NSUserDefaults standardUserDefaults] setBool:shouldPlay forKey:@"VibrationIsAllowed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(BOOL)getVibrationState
{
    BOOL isAllowed = [[NSUserDefaults standardUserDefaults] boolForKey:@"VibrationIsAllowed"];
    return isAllowed;
}
+(void)postImageDetectNotificationWithText:(NSString *)text
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"imageCodeScanedNotification" object:nil userInfo:@{ @"image" : text }];
}
+(void)postSumOfScannedNotesNotification:(NSString *)sum {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sumOfScannedNotesNotification" object:nil userInfo:@{ @"totalSum" : sum }];
}
+(void)postRealNoteDetectedNotification:(NSDictionary *)info
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RealNoteDetectedNotification" object:nil userInfo:@{ @"info" : info }];
}
+(void)postNoteDetectedWithSideInfo:(NSString *)text{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noteSideDetecedNotification" object:nil userInfo:@{ @"image" : text }];
}

//hassan added these methods
+(void)saveMuteState:(BOOL)shouldMute {
    [[NSUserDefaults standardUserDefaults] setBool:shouldMute forKey:@"MuteIsAllowed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(BOOL)getMuteState {
    BOOL isAllowed = [[NSUserDefaults standardUserDefaults] boolForKey:@"MuteIsAllowed"];
    return isAllowed;
}

@end
