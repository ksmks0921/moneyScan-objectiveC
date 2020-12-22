//
//  AppUtils.h
//  Money Reader
//
//  Created by Syed Qamar Abbas on 2017-11-17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MREnumerations.h"
@interface AppUtils : NSObject
+(void)saveLanguage:(MRAppLanguage)language;
+(void)saveAppMode:(MRScanMode)mode;
+(MRAppLanguage)getLanguage;
+(BOOL)getVibrationState;
+(void)saveVibrationState:(BOOL)shouldPlay;
+(MRScanMode)getAppMode;
+(void)postImageDetectNotificationWithText:(NSString *)text;
+(void)postSumOfScannedNotesNotification:(NSString *)sum;
+(void)postRealNoteDetectedNotification:(NSDictionary *)info;
+(void)postNoteDetectedWithSideInfo:(NSString *)text;

//hassan added these methods
+(void)saveMuteState:(BOOL)shouldMute;
+(BOOL)getMuteState;

@end
