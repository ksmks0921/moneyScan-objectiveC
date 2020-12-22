//
//  AppDelegate.h
//  Money Reader
//
//  Created by Muhammad Ahsan on 4/12/17.
//  Copyright © 2017 Accuretech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (atomic) bool active;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic) int selectedLanguageIndex;

-(void)didfoundView:(NSString*)text type:(NSString*)type;

@end

