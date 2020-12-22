//
//  MRSoundManager.m
//  Money Reader
//
//  Created by Syed Qamar Abbas on 2017-11-17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import "MRSoundManager.h"
#import "AppUtils.h"
static NSString * const kQMSoundManagerSettingKey = @"kQMSoundManagerSettingKey";
@interface MRSoundManager ()

@end
@implementation MRSoundManager{
    
    NSMutableDictionary *_sounds;
    NSMutableDictionary *_completionBlocks;
    BOOL _audioDeviceChanged;
}

+(MRNote)getNoteWithNumber:(NSInteger)noteNumber {
    MRNote currencyNote = MRNoteOne;
    switch (noteNumber) {
        case 1:
            currencyNote = MRNoteOne;
            break;
        case 5:
            currencyNote = MRNoteFive;
            break;
        case 10:
            currencyNote = MRNoteTen;
            break;
        case 50:
            currencyNote = MRNoteFifty;
            break;
        case 100:
            currencyNote = MRNoteHundred;
            break;
        case 500:
            currencyNote = MRNoteFiveHundred;
            break;
        default:
            break;
    }
    return currencyNote;
}

+(void)playNoteSoundWithNote:(MRNote)note withLanguage:(MRAppLanguage)language shouldVibrate:(BOOL)shouldVibrate {
    NSString *fileName;
    switch (note) {
        case MRNoteOne:
            if (language == MRAppLanguageArabic) {
                fileName = @"1-1";
            }else {
                fileName = @"1";
            }
            break;
            
        case MRNoteFive:
            if (language == MRAppLanguageArabic) {
                fileName = @"5-1";
            }else {
                fileName = @"5";
            }
            break;
        case MRNoteTen:
            if (language == MRAppLanguageArabic) {
                fileName = @"10-1";
            }else {
                fileName = @"10";
            }
            break;
        case MRNoteFifty:
            if (language == MRAppLanguageArabic) {
                fileName = @"50-1";
            }else {
                fileName = @"50";
            }
            break;
        case MRNoteHundred:
            if (language == MRAppLanguageArabic) {
                fileName = @"100-1";
            }else {
                fileName = @"100";
            }
            break;
        case MRNoteFiveHundred:
            if (language == MRAppLanguageArabic) {
                fileName = @"500-1";
            }else {
                fileName = @"500";
            }
            break;
        default:
            break;
    }
    [MRSoundManager.instance playSoundWithName:fileName extension:@"m4a" shouldVibrate:shouldVibrate];
}
    ///////
/**
  param : MRAppLanguage Type
  plays language selection notification sound
 **/
+(void)playLanguageSettingsSoundWithLanguage:(MRAppLanguage)language shouldVibrate:(BOOL)shouldVibrate {
    
    NSString *fileName;
    
    if (language == MRAppLanguageArabic) {
        fileName = @"Arabic Lanaguage Active";
    }else {
        fileName = @"English Lanaguae Active";
    }
    
     [MRSoundManager.instance playSoundWithName:fileName extension:@"m4a" isAlert:true completion:nil];
}
/**
 param : MRScanMode mode
 plays scan mode change notification sound
 **/
+(void)playModeSettingsSoundWithLanguage:(MRScanMode)mode shouldVibrate:(BOOL)shouldVibrate {
    
    NSString *fileName;
    
    if (mode == MRScanModeSingle) {
        fileName = @"1st Mode Active";
    }else {
        fileName = @"2nd Mode Active";
    }
    
     [MRSoundManager.instance playSoundWithName:fileName extension:@"m4a" isAlert:true completion:nil];
}
/**
 params : MRVibrationState state
 plays vibration selection notification sound
 **/
+(void)playVibrationSettingsSoundWithVibratation:(BOOL)shouldVibrate {
    
    NSString *fileName;
    
    if (shouldVibrate) {
        fileName = @"Vibration+Sound Active";
    }else {
        fileName = @"Vibration+Sound Disabled";
    }
    
     [MRSoundManager.instance playSoundWithName:fileName extension:@"m4a" isAlert:true completion:nil];
}

/**
 params :
 plays Welcome sound
 **/
+(void)playWelcomeSoundwithVibration:(BOOL)shouldVibrate {
    
    NSString *fileName = @"Welcome";

    //[MRSoundManager.instance playSoundWithName:fileName extension:@"m4a" shouldVibrate:shouldVibrate];
    
    [MRSoundManager.instance playSoundWithName:fileName extension:@"m4a" isAlert:true completion:nil];
}
/////////////

- (void)dealloc {
    
    NSNotificationCenter *notifcationCenter =
    [NSNotificationCenter defaultCenter];
    [notifcationCenter removeObserver:self];
}

void systemServicesSoundCompletion(SystemSoundID  soundID, void *__unused data) {
    
    void(^completion)(void) = [MRSoundManager.instance completionBlockForSoundID:soundID];
    
    if (completion) {
        
        completion();
        [MRSoundManager.instance  removeCompletionBlockForSoundID:soundID];
    }
}

+ (instancetype)instance {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self setOn:YES];
        
        _sounds = [NSMutableDictionary dictionary];
        _completionBlocks = [NSMutableDictionary dictionary];
        
        NSNotificationCenter *notifcationCenter =
        [NSNotificationCenter defaultCenter];
        
        [notifcationCenter addObserver:self
                              selector:@selector(didReceiveMemoryWarningNotification:)
                                  name:UIApplicationDidReceiveMemoryWarningNotification
                                object:nil];
    }
    
    return self;
}


- (void)setOn:(BOOL)on {
    
    _on = on;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:on forKey:kQMSoundManagerSettingKey];
    [userDefaults synchronize];
    
    if (!on) {
        
        [self stopAllSounds];
    }
}

//MARK: - Playing sounds

- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
                  isAlert:(BOOL)isAlert
               completion:(void(^)(void))completion {
    
    if (!self.on) {
        return;
    }
    
    if (!filename || !extension) {
        return;
    }
    
    if (!_sounds[filename]) {
        
        [self addSoundIDForAudioFileWithName:filename
                                   extension:extension];
    }
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    
    if (soundID) {
        
        if (completion) {
            
            OSStatus error =
            AudioServicesAddSystemSoundCompletion(soundID,
                                                  NULL,
                                                  NULL,
                                                  systemServicesSoundCompletion,
                                                  NULL);
            if (error) {
                
                [self logError:error
                   withMessage:@"Warning! Completion block could not be added to SystemSoundID."];
            }
            else {
                
                [self addCompletionBlock:completion
                               toSoundID:soundID];
            }
        }
        
        if (isAlert) {
            AudioServicesPlayAlertSound(soundID);
        }
        else {
            AudioServicesPlaySystemSound(soundID);
        }
    }
}

- (void)playSoundWithName:(NSString *)filename extension:(NSString *)extension shouldVibrate:(BOOL)shouldVibrate{
    if (shouldVibrate) {
        [self playVibrateSound];
    }
    [self stopAllSounds];
    [self playSoundWithName:filename
                  extension:extension
                 completion:nil];
}

- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
               completion:(void(^)(void))completion {
    
    [self playSoundWithName:filename
                  extension:extension
                    isAlert:NO
                 completion:completion];
}

- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension
                    completion:(void(^)(void))completion {
    
    [self playSoundWithName:filename
                  extension:extension
                    isAlert:YES
                 completion:completion];
}

- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension {
    
    [self playAlertSoundWithName:filename
                       extension:extension
                      completion:nil];
}

- (void)playVibrateSound {
    if (![AppUtils getVibrationState]) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)stopAllSounds {
    [self unloadSoundIDs];
}

- (void)stopSoundWithFilename:(NSString *)filename {
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    NSData *data = [self dataWithSoundID:soundID];
    
    [self unloadSoundIDForFileNamed:filename];
    
    [_sounds removeObjectForKey:filename];
    [_completionBlocks removeObjectForKey:data];
}

- (void)preloadSoundWithFilename:(NSString *)filename
                       extension:(NSString *)extension {
    
    if (!_sounds[filename]) {
        [self addSoundIDForAudioFileWithName:filename
                                   extension:extension];
    }
}

//MARK: - Sound data

- (NSData *)dataWithSoundID:(SystemSoundID)soundID {
    
    return [NSData dataWithBytes:&soundID
                          length:sizeof(SystemSoundID)];
}

- (SystemSoundID)soundIDFromData:(NSData *)data {
    
    if (data) {
        
        SystemSoundID soundID;
        [data getBytes:&soundID length:sizeof(SystemSoundID)];
        return soundID;
    }
    
    return 0;
}

//MARK: - Sound files

- (SystemSoundID)soundIDForFilename:(NSString *)filenameKey {
    
    NSData *soundData = _sounds[filenameKey];
    return [self soundIDFromData:soundData];
}

- (void)addSoundIDForAudioFileWithName:(NSString *)filename
                             extension:(NSString *)extension {
    
    SystemSoundID soundID = [self createSoundIDWithName:filename
                                              extension:extension];
    if (soundID) {
        
        NSData *data = [self dataWithSoundID:soundID];
        _sounds[filename] = data;
    }
}

//MARK: - Sound completion blocks

- (void(^)(void))completionBlockForSoundID:(SystemSoundID)soundID {
    
    NSData *data = [self dataWithSoundID:soundID];
    return _completionBlocks[data];
}

- (void)addCompletionBlock:(void(^)(void))block
                 toSoundID:(SystemSoundID)soundID {
    
    NSData *data = [self dataWithSoundID:soundID];
    _completionBlocks[data] = [block copy];
}

- (void)removeCompletionBlockForSoundID:(SystemSoundID)soundID {
    
    NSData *key = [self dataWithSoundID:soundID];
    [_completionBlocks removeObjectForKey:key];
    AudioServicesRemoveSystemSoundCompletion(soundID);
}

//MARK: - Managing sounds

- (SystemSoundID)createSoundIDWithName:(NSString *)filename
                             extension:(NSString *)extension {
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename
                                             withExtension:extension];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        
        SystemSoundID soundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
        
        if (error) {
            [self logError:error withMessage:@"Warning! SystemSoundID could not be created."];
            return 0;
        }
        else {
            return soundID;
        }
    }
    
    NSLog(@"Error: audio file not found at URL: %@", fileURL);
    
    return 0;
}

- (void)unloadSoundIDs {
    
    for(NSString *eachFilename in [_sounds allKeys]) {
        [self unloadSoundIDForFileNamed:eachFilename];
    }
    
    [_sounds removeAllObjects];
    [_completionBlocks removeAllObjects];
}

- (void)unloadSoundIDForFileNamed:(NSString *)filename {
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    
    if(soundID) {
        AudioServicesRemoveSystemSoundCompletion(soundID);
        
        OSStatus error = AudioServicesDisposeSystemSoundID(soundID);
        
        if(error) {
            
            [self logError:error withMessage:@"Warning! SystemSoundID could not be disposed."];
        }
    }
}

- (void)didReceiveMemoryWarningNotification:(NSNotification *)__unused notification {
    
    [self unloadSoundIDs];
}
- (void)logError:(OSStatus)error withMessage:(NSString *)message {
    
    NSString *errorMessage = nil;
    
    switch (error) {
            
        case kAudioServicesUnsupportedPropertyError: errorMessage = @"The property is not supported."; break;
        case kAudioServicesBadPropertySizeError: errorMessage = @"The size of the property data was not correct."; break;
        case kAudioServicesBadSpecifierSizeError: errorMessage = @"The size of the specifier data was not correct."; break;
        case kAudioServicesSystemSoundUnspecifiedError:errorMessage = @"An unspecified error has occurred."; break;
        case kAudioServicesSystemSoundClientTimedOutError: errorMessage = @"System sound client message timed out."; break;
    }
    
    NSLog(@"%@ Error: (code %d) %@", message, (int)error, errorMessage);
}

@end
