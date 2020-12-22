//
//  howToUseViewController.m
//  Qatar Money Reader
//
//  Created by dottechmac5 on 12/02/18.
//  Copyright © 2018 Accuretech. All rights reserved.
//

#import "howToUseViewController.h"
#import "AppUtils.h"
#import <easyar/engine.oc.h>

@interface howToUseViewController ()
{
    UIView *howToUseView;
    AVSpeechSynthesizer *synthesizer;

}

@end

@implementation howToUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int fontSize = [[UIScreen mainScreen]bounds].size.height==568?12:15;
    
    howToUseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    [howToUseView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:howToUseView];
    
    UILabel *howToScanLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, [[UIScreen mainScreen]bounds].size.width-20, 20)];
    [howToScanLabel setFont:[UIFont boldSystemFontOfSize:18]];
    //    [howToScanLabel setBackgroundColor:[UIColor blueColor]];
    [howToUseView addSubview:howToScanLabel];
    
    int y = 50;
    UILabel *howToScanDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, [[UIScreen mainScreen]bounds].size.height * 0.1)];
    [howToScanDescription setFont:[UIFont systemFontOfSize:fontSize]];
    [howToScanDescription setNumberOfLines:3];
    //    [howToScanDescription setBackgroundColor:[UIColor redColor]];
    [howToUseView addSubview:howToScanDescription];
    
    y += howToScanDescription.frame.size.height + 20;
    UILabel *switchingLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, 20)];
    [switchingLabel setFont:[UIFont boldSystemFontOfSize:18]];
    //    [switchingLabel setBackgroundColor:[UIColor brownColor]];
    [howToUseView addSubview:switchingLabel];
    
    y += switchingLabel.frame.size.height;
    UILabel *switchingDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, [[UIScreen mainScreen]bounds].size.height * 0.3)];
    [switchingDescription setFont:[UIFont systemFontOfSize:fontSize]];
    [switchingDescription setNumberOfLines:12];
    //    [switchingDescription setBackgroundColor:[UIColor greenColor]];
    [howToUseView addSubview:switchingDescription];
    
    y += switchingDescription.frame.size.height + 20;
    UILabel *vibrationPatternLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, 20)];
    [vibrationPatternLabel setFont:[UIFont boldSystemFontOfSize:18]];
    //    [vibrationPatternLabel setBackgroundColor:[UIColor yellowColor]];
    [howToUseView addSubview:vibrationPatternLabel];
    
    y += switchingLabel.frame.size.height;
    UILabel *vibrationPatternDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, y, [[UIScreen mainScreen]bounds].size.width-20, [[UIScreen mainScreen]bounds].size.height * 0.28)];
    [vibrationPatternDescription setFont:[UIFont systemFontOfSize:fontSize]];
    [vibrationPatternDescription setNumberOfLines:10];
    //    [vibrationPatternDescription setBackgroundColor:[UIColor purpleColor]];
    [howToUseView addSubview:vibrationPatternDescription];
    
    int minusY = [[UIScreen mainScreen]bounds].size.height==568?45:60;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width - 120)/2, [[UIScreen mainScreen]bounds].size.height - minusY, 120, 40)];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton.layer setCornerRadius:10.0];
    [backButton.layer setBorderWidth:5.0];
    [backButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [backButton addTarget:self action:@selector(dismissView1) forControlEvents:UIControlEventTouchUpInside];
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
    
    
    UITapGestureRecognizer *tapGestureForRemoveView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView1)];
    tapGestureForRemoveView.numberOfTouchesRequired = 1;
    [howToUseView addGestureRecognizer:tapGestureForRemoveView];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dismissView1
{
    //    [self dismissViewControllerAnimated:YES completion:nil];
    

  
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFromAbout"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTTS" object:nil];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"startCamera" object:nil];
//    [easyar_Engine onResume];
        }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
