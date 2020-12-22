//
//  MRSoundManager.h
//  Money Reader
//
//  Created by Syed Qamar Abbas on 2017-11-17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MREnumerations.h"
@interface MRSoundManager : NSObject
@property (assign, nonatomic) BOOL on;

+ (instancetype)instance;
+(MRNote)getNoteWithNumber:(NSInteger)noteNumber;
+(void)playModeSoundWithMode:(MRScanMode)scanMode withLanguage:(MRAppLanguage)language shouldVibrate:(BOOL)shouldVibrate;
+(void)playNoteSoundWithNote:(MRNote)note withLanguage:(MRAppLanguage)language shouldVibrate:(BOOL)shouldVibrate;

- (void)playVibrateSound;

+(void)playVibrationSettingsSoundWithVibratation:(BOOL)shouldVibrate;

+(void)playWelcomeSoundwithVibration:(BOOL)shouldVibrate;

+(void)playModeSettingsSoundWithLanguage:(MRScanMode)mode shouldVibrate:(BOOL)shouldVibrate;

+(void)playLanguageSettingsSoundWithLanguage:(MRAppLanguage)language shouldVibrate:(BOOL)shouldVibrate;

@end
