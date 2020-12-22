//
//  MREnumerations.h
//  Money Reader
//
//  Created by Syed Qamar Abbas on 2017-11-17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MRScanModeSingle,
    MRScanModeMultiple,
    MRScanModeFakeORReal,
} MRScanMode;

typedef enum : NSUInteger {
    MRVibrationStateNotPlay,
    MRVibrationStatePlay,
} MRVibrationState;

typedef enum : NSUInteger {
    MRAppLanguageEnglish,
    MRAppLanguageArabic,
} MRAppLanguage;

typedef enum : NSUInteger {
    MRNoteOne,
    MRNoteFive,
    MRNoteTen,
    MRNoteFifty,
    MRNoteHundred,
    MRNoteFiveHundred,
} MRNote;

@interface MREnumerations : NSObject

@end
