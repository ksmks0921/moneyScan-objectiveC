//=============================================================================================================================
//
// Copyright (c) 2015-2017 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#define IS_PORTRAIT     UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])
#define IS_LANDSCAPE    UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])


#import "helloar.h"

#import "BoxRenderer.h"


#import <easyar/camera.oc.h>
#import <easyar/frame.oc.h>
#import <easyar/framestreamer.oc.h>
#import <easyar/imagetracker.oc.h>
#import <easyar/imagetarget.oc.h>
#import <easyar/renderer.oc.h>

#include <OpenGLES/ES2/gl.h>
#import "AppUtils.h"
#import <AVFoundation/AVFoundation.h>
//#import <GraphicsServices/GraphicsServices.h>
#import <CoreGraphics/CoreGraphics.h>

easyar_CameraDevice * camera;
easyar_CameraFrameStreamer * streamer;
NSMutableArray<easyar_ImageTracker *> * trackers;
easyar_Renderer * videobg_renderer;
BoxRenderer * box_renderer;
bool viewport_changed = false;
double sumOfAmount = 0 ;
AVAudioPlayer *audioPlayer;
BOOL any = YES;

int view_size[] = {0, 0};
int view_rotation = 0;
int viewport[] = {0, 0, 1280, 720};
NSMutableArray *array,*fakeTrackerArray;
NSMutableSet* fakeTrackerNoteTypeArray;
NSString *detectedNote = @"";
BOOL isSameNote;
easyar_ImageTracker * tracker1;
easyar_ImageTracker * tracker2;
easyar_ImageTracker * tracker7;
easyar_ImageTracker * tracker8;


void loadFromImage(easyar_ImageTracker * tracker, NSString * path)
{
    easyar_ImageTarget * target = [easyar_ImageTarget create];

    NSString *name = [path substringToIndex:[path rangeOfString:@"."].location];

//    dispatch_async(dispatch_get_main_queue(), ^(void){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        NSString *jstr = [@[@"{\n"
                  "  \"images\" :\n"
                  "  [\n"
                  "    {\n"
                  "      \"image\" : \"", path, @"\",\n"
                  "      \"name\" : \"", name, @"\"\n"
                  "    }\n"
                  "  ]\n"
                  "}"] componentsJoinedByString:@""];

        [target setup:jstr storageType:easyar_StorageType_Assets | easyar_StorageType_Json name:@""];
        //with this call back, app launch immediately but images loading taking longer time - Hassan
//        [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
//            NSLog(@"load target (%d): %@ (%d)", status, [target name], [target runtimeID]);
//        }];
        
        [tracker loadTargetBlocked:target];
        NSLog(@"Target Name is : %@ (%d)", [target name], [target runtimeID]);
    });
}

void loadFromImage3(easyar_ImageTracker * tracker, NSString * path)
{
    easyar_ImageTarget * target = [easyar_ImageTarget create];
    
    NSString *name = [path substringToIndex:[path rangeOfString:@"."].location];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

    NSString *jstr = [@[@"{\n"
                            "  \"images\" :\n"
                            "  [\n"
                            "    {\n"
                            "      \"image\" : \"", path, @"\",\n"
                            "      \"name\" : \"", name, @"\"\n"
                            "    }\n"
                            "  ]\n"
                            "}"] componentsJoinedByString:@""];
        
        [target setup:jstr storageType:easyar_StorageType_Assets | easyar_StorageType_Json name:@""];
        [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
            NSLog(@"load target (%d): %@ (%d)", status, [target name], [target runtimeID]);
        }];
//        [tracker loadTargetBlocked:target];
//        NSLog(@"3rd Mode Target Name is : %@ (%d)", [target name], [target runtimeID]);
    });
}



void loadFromJsonFile(easyar_ImageTracker * tracker, NSString * path, NSString * targetname)
{
    easyar_ImageTarget * target = [easyar_ImageTarget create];
    [target setup:path storageType:easyar_StorageType_Assets name:targetname];
    [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
        NSLog(@"load target (%d): %@ (%d)", status, [target name], [target runtimeID]);
    }];
}

void loadAllFromJsonFile(easyar_ImageTracker * tracker, NSString * path)
{
    for (easyar_ImageTarget * target in [easyar_ImageTarget setupAll:path storageType:easyar_StorageType_Assets]) {
        [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
            NSLog(@"load target (%d): %@ (%d)", status, [target name], [target runtimeID]);
        }];
    }
}

//void setFakeRealTrackingObject(easyar_ImageTracker*  tracker1, easyar_ImageTracker * tracker2,easyar_ImageTracker * tracker3) {
void setFakeRealTrackingObject(easyar_ImageTracker*  tracker, easyar_ImageTracker*  tracker2) {
    //hassan changes
    //back sides
//    NSString * identityMark1 = [NSString stringWithFormat:@"1 Qatari Back First Mark.jpeg"];
    NSString * identityMark2 = [NSString stringWithFormat:@"1 Qatari Back Second Mark.jpeg"];
    NSString * identityMark3 = [NSString stringWithFormat:@"1 Qatari Back Third Mark.jpeg"];
    NSString * identityMark4 = [NSString stringWithFormat:@"1 Qatari Back Fourth Mark.jpeg"];
    NSString * identityMark5 = [NSString stringWithFormat:@"1 Qatari Back Fifth Mark.jpeg"];

    NSString * identityMark6 = [NSString stringWithFormat:@"5 Qatari Back First Mark.jpeg"];
    NSString * identityMark7 = [NSString stringWithFormat:@"5 Qatari Back Second Mark.jpeg"];
    NSString * identityMark8 = [NSString stringWithFormat:@"5 Qatari Back Third Mark.jpeg"];
    NSString * identityMark9 = [NSString stringWithFormat:@"5 Qatari Back Fourth Mark.jpeg"];
//    NSString * identityMark10 = [NSString stringWithFormat:@"5 Qatari Back Fifth Mark.jpeg"];

    NSString * identityMark11 = [NSString stringWithFormat:@"10 Qatari Back First Mark.jpeg"];
    NSString * identityMark12 = [NSString stringWithFormat:@"10 Qatari Back Second Mark.jpeg"];
    NSString * identityMark13 = [NSString stringWithFormat:@"10 Qatari Back Third Mark.jpeg"];
    NSString * identityMark14 = [NSString stringWithFormat:@"10 Qatari Back Fourth Mark.jpeg"];
//    NSString * identityMark15 = [NSString stringWithFormat:@"10 Qatari Back Fifth Mark.jpeg"];

    NSString * identityMark16 = [NSString stringWithFormat:@"50 Qatari Back First Mark.jpeg"];
    NSString * identityMark17 = [NSString stringWithFormat:@"50 Qatari Back Second Mark.jpeg"];
    NSString * identityMark18 = [NSString stringWithFormat:@"50 Qatari Back Third Mark.jpeg"];
    NSString * identityMark19 = [NSString stringWithFormat:@"50 Qatari Back Fourth Mark.jpeg"];
    NSString * identityMark20 = [NSString stringWithFormat:@"50 Qatari Back Fifth Mark.jpeg"];

    NSString * identityMark21 = [NSString stringWithFormat:@"100 Qatari Back First Mark.jpeg"];
    NSString * identityMark22 = [NSString stringWithFormat:@"100 Qatari Back Second Mark.jpeg"];
//    NSString * identityMark23 = [NSString stringWithFormat:@"100 Qatari Back Third Mark.jpeg"];
    NSString * identityMark24 = [NSString stringWithFormat:@"100 Qatari Back Fourth Mark.jpeg"];
    NSString * identityMark25 = [NSString stringWithFormat:@"100 Qatari Back Fifth Mark.jpeg"];

    NSString * identityMark26 = [NSString stringWithFormat:@"500 Qatari Back First Mark.jpeg"];
    NSString * identityMark27 = [NSString stringWithFormat:@"500 Qatari Back Second Mark.jpeg"];
    NSString * identityMark28 = [NSString stringWithFormat:@"500 Qatari Back Third Mark.jpeg"];
//    NSString * identityMark29 = [NSString stringWithFormat:@"500 Qatari Back Fourth Mark.jpeg"];
    NSString * identityMark30 = [NSString stringWithFormat:@"500 Qatari Back Fifth Mark.jpeg"];

    //front sides
    NSString * identityMarkf1 = [NSString stringWithFormat:@"1 Qatari Front First Mark.jpeg"];
    NSString * identityMarkf2 = [NSString stringWithFormat:@"1 Qatari Front Second Mark.jpeg"];
    NSString * identityMarkf3 = [NSString stringWithFormat:@"1 Qatari Front Third Mark.jpeg"];
    NSString * identityMarkf4 = [NSString stringWithFormat:@"1 Qatari Front Fourth Mark.jpeg"];
    NSString * identityMarkf5 = [NSString stringWithFormat:@"1 Qatari Front Fifth Mark.jpeg"];

    NSString * identityMarkf6 = [NSString stringWithFormat:@"5 Qatari Front First Mark.jpeg"];
    NSString * identityMarkf7 = [NSString stringWithFormat:@"5 Qatari Front Second Mark.jpeg"];
    NSString * identityMarkf8 = [NSString stringWithFormat:@"5 Qatari Front Third Mark.jpeg"];
    NSString * identityMarkf9 = [NSString stringWithFormat:@"5 Qatari Front Fourth Mark.jpeg"];
    NSString * identityMarkf10 = [NSString stringWithFormat:@"5 Qatari Front Fifth Mark.jpeg"];

    NSString * identityMarkf11 = [NSString stringWithFormat:@"10 Qatari Front First Mark.jpeg"];
//    NSString * identityMarkf12 = [NSString stringWithFormat:@"10 Qatari Front Second Mark.jpeg"];
    NSString * identityMarkf13 = [NSString stringWithFormat:@"10 Qatari Front Third Mark.jpeg"];
    NSString * identityMarkf14 = [NSString stringWithFormat:@"10 Qatari Front Fourth Mark.jpeg"];
    NSString * identityMarkf15 = [NSString stringWithFormat:@"10 Qatari Front Fifth Mark.jpeg"];

    NSString * identityMarkf16 = [NSString stringWithFormat:@"50 Qatari Front First Mark.jpeg"];
    NSString * identityMarkf17 = [NSString stringWithFormat:@"50 Qatari Front Second Mark.jpeg"];
    NSString * identityMarkf18 = [NSString stringWithFormat:@"50 Qatari Front Third Mark.jpeg"];
    NSString * identityMarkf19 = [NSString stringWithFormat:@"50 Qatari Front Fourth Mark.jpeg"];
    NSString * identityMarkf20 = [NSString stringWithFormat:@"50 Qatari Front Fifth Mark.jpeg"];

    NSString * identityMarkf21 = [NSString stringWithFormat:@"100 Qatari Front First Mark.jpeg"];
    NSString * identityMarkf22 = [NSString stringWithFormat:@"100 Qatari Front Second Mark.jpeg"];
    NSString * identityMarkf23 = [NSString stringWithFormat:@"100 Qatari Front Third Mark.jpeg"];
    NSString * identityMarkf24 = [NSString stringWithFormat:@"100 Qatari Front Fourth Mark.jpeg"];
    NSString * identityMarkf25 = [NSString stringWithFormat:@"100 Qatari Front Fifth Mark.jpeg"];

    NSString * identityMarkf26 = [NSString stringWithFormat:@"500 Qatari Front First Mark.jpeg"];
    NSString * identityMarkf27 = [NSString stringWithFormat:@"500 Qatari Front Second Mark.jpeg"];
    NSString * identityMarkf28 = [NSString stringWithFormat:@"500 Qatari Front Third Mark.jpeg"];
    NSString * identityMarkf29 = [NSString stringWithFormat:@"500 Qatari Front Fourth Mark.jpeg"];
    NSString * identityMarkf30 = [NSString stringWithFormat:@"500 Qatari Front Fifth Mark.jpeg"];

    dispatch_async(dispatch_get_main_queue(), ^(void){
        //backs
//        loadFromImage3(tracker, identityMark1);
        loadFromImage3(tracker, identityMark2);
        loadFromImage3(tracker, identityMark3);
        loadFromImage3(tracker, identityMark4);
        loadFromImage3(tracker, identityMark5);

        loadFromImage3(tracker, identityMark6);
        loadFromImage3(tracker, identityMark7);
        loadFromImage3(tracker, identityMark8);
        loadFromImage3(tracker, identityMark9);
//        loadFromImage3(tracker, identityMark10);

        loadFromImage3(tracker, identityMark11);
        loadFromImage3(tracker, identityMark12);
        loadFromImage3(tracker, identityMark13);
        loadFromImage3(tracker, identityMark14);
//        loadFromImage3(tracker, identityMark15);

        loadFromImage3(tracker, identityMark16);
        loadFromImage3(tracker, identityMark17);
        loadFromImage3(tracker, identityMark18);
        loadFromImage3(tracker, identityMark19);
        loadFromImage3(tracker, identityMark20);

        loadFromImage3(tracker, identityMark21);
        loadFromImage3(tracker, identityMark22);
//        loadFromImage3(tracker, identityMark23);
        loadFromImage3(tracker, identityMark24);
        loadFromImage3(tracker, identityMark25);

        loadFromImage3(tracker, identityMark26);
        loadFromImage3(tracker, identityMark27);
        loadFromImage3(tracker, identityMark28);
//        loadFromImage3(tracker, identityMark29);
        loadFromImage3(tracker, identityMark30);


        //fronts
        loadFromImage3(tracker, identityMarkf1);
        loadFromImage3(tracker, identityMarkf2);
        loadFromImage3(tracker, identityMarkf3);
        loadFromImage3(tracker, identityMarkf4);
        loadFromImage3(tracker, identityMarkf5);

        loadFromImage3(tracker, identityMarkf6);
        loadFromImage3(tracker, identityMarkf7);
        loadFromImage3(tracker, identityMarkf8);
        loadFromImage3(tracker, identityMarkf9);
        loadFromImage3(tracker, identityMarkf10);

        loadFromImage3(tracker, identityMarkf11);
//        loadFromImage3(tracker, identityMarkf12);
        loadFromImage3(tracker, identityMarkf13);
        loadFromImage3(tracker, identityMarkf14);
        loadFromImage3(tracker, identityMarkf15);

        loadFromImage3(tracker, identityMarkf16);
        loadFromImage3(tracker, identityMarkf17);
        loadFromImage3(tracker, identityMarkf18);
        loadFromImage3(tracker, identityMarkf19);
        loadFromImage3(tracker, identityMarkf20);

        loadFromImage3(tracker, identityMarkf21);
        loadFromImage3(tracker, identityMarkf22);
        loadFromImage3(tracker, identityMarkf23);
        loadFromImage3(tracker, identityMarkf24);
        loadFromImage3(tracker, identityMarkf25);

        loadFromImage3(tracker, identityMarkf26);
        loadFromImage3(tracker, identityMarkf27);
        loadFromImage3(tracker, identityMarkf28);
        loadFromImage3(tracker, identityMarkf29);
        loadFromImage3(tracker, identityMarkf30);
        //hassan chnages end
    });
}


//void setTrackingObject(easyar_ImageTracker*  tracker1, easyar_ImageTracker * tracker2) {
void setTrackingObject(easyar_ImageTracker*  tracker, easyar_ImageTracker * tracker2)
{
    //hassan changes for note detection only
    //FOR NEW IMAGES SLICES - HASSAN
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        loadFromImage(tracker, @"1 Qatari Back.jpeg");
        loadFromImage(tracker, @"1 Qatari Front.jpeg");

        loadFromImage(tracker, @"5 Qatari Front.jpeg");
        loadFromImage(tracker, @"5 Qatari Back.jpeg");

        loadFromImage(tracker, @"10 Qatari Back.jpeg");
        loadFromImage(tracker, @"10 Qatari Front.jpeg");

        loadFromImage(tracker, @"50 Qatari Back.jpeg");
        loadFromImage(tracker, @"50 Qatari Front.jpeg");

        loadFromImage(tracker, @"100 Qatari Back.jpeg");
        loadFromImage(tracker, @"100 Qatari Front.jpeg");

        loadFromImage(tracker, @"500 Qatari Back.jpeg");
        loadFromImage(tracker, @"500 Qatari Front.jpeg");
//    });
//    //end

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        loadFromImage(tracker, @"1 B1.jpg");
        loadFromImage(tracker, @"1 B2.jpg");
        loadFromImage(tracker, @"1 B3.jpg");
        loadFromImage(tracker, @"1 B4.jpg");
        loadFromImage(tracker, @"1 B5.jpg");
        loadFromImage(tracker, @"1 B6.jpg");
        loadFromImage(tracker, @"1 B7.jpg");
//        loadFromImage(tracker, @"1 B8.jpg");
//        loadFromImage(tracker, @"1 B9.jpg");
//        loadFromImage(tracker, @"1 B10.jpg");
//        loadFromImage(tracker, @"1 B11.jpg");
        loadFromImage(tracker, @"1 F1.jpg");
        loadFromImage(tracker, @"1 F2.jpg");
        loadFromImage(tracker, @"1 F3.jpg");
        loadFromImage(tracker, @"1 F4.jpg");
        loadFromImage(tracker, @"1 F5.jpg");
        loadFromImage(tracker, @"1 F6.jpg");
        loadFromImage(tracker, @"1 F7.jpg");
//        loadFromImage(tracker, @"1 F8.jpg");
//        loadFromImage(tracker, @"1 F9.jpg");
//        loadFromImage(tracker, @"1 F10.jpg");
//        loadFromImage(tracker, @"1 F11.jpg");
//
        loadFromImage(tracker, @"5 B1.jpg");
        loadFromImage(tracker, @"5 B2.jpg");
        loadFromImage(tracker, @"5 B3.jpg");
        loadFromImage(tracker, @"5 B4.jpg");
        loadFromImage(tracker, @"5 B5.jpg");
        loadFromImage(tracker, @"5 B6.jpg");
        loadFromImage(tracker, @"5 B7.jpg");
//        loadFromImage(tracker, @"5 B8.jpg");
//        loadFromImage(tracker, @"5 B9.jpg");
//        loadFromImage(tracker, @"5 B10.jpg");
//        loadFromImage(tracker, @"5 B11.jpg");
        loadFromImage(tracker, @"5 F1.jpg");
        loadFromImage(tracker, @"5 F2.jpg");
        loadFromImage(tracker, @"5 F3.jpg");
        loadFromImage(tracker, @"5 F4.jpg");
        loadFromImage(tracker, @"5 F5.jpg");
        loadFromImage(tracker, @"5 F6.jpg");
        loadFromImage(tracker, @"5 F7.jpg");
//        loadFromImage(tracker, @"5 F8.jpg");
//        loadFromImage(tracker, @"5 F9.jpg");
//        loadFromImage(tracker, @"5 F10.jpg");
//        loadFromImage(tracker, @"5 F11.jpg");
//
        loadFromImage(tracker, @"10 B1.jpg");
        loadFromImage(tracker, @"10 B2.jpg");
        loadFromImage(tracker, @"10 B3.jpg");
        loadFromImage(tracker, @"10 B4.jpg");
        loadFromImage(tracker, @"10 B5.jpg");
        loadFromImage(tracker, @"10 B6.jpg");
        loadFromImage(tracker, @"10 B7.jpg");
//        loadFromImage(tracker, @"10 B8.jpg");
//        loadFromImage(tracker, @"10 B9.jpg");
//        loadFromImage(tracker, @"10 B10.jpg");
//        loadFromImage(tracker, @"10 B11.jpg");
        loadFromImage(tracker, @"10 F1.jpg");
        loadFromImage(tracker, @"10 F2.jpg");
        loadFromImage(tracker, @"10 F3.jpg");
        loadFromImage(tracker, @"10 F4.jpg");
        loadFromImage(tracker, @"10 F5.jpg");
        loadFromImage(tracker, @"10 F6.jpg");
        loadFromImage(tracker, @"10 F7.jpg");
//        loadFromImage(tracker, @"10 F8.jpg");
//        loadFromImage(tracker, @"10 F9.jpg");
//        loadFromImage(tracker, @"10 F10.jpg");
//        loadFromImage(tracker, @"10 F11.jpg");
//
        loadFromImage(tracker, @"50 B1.jpg");
        loadFromImage(tracker, @"50 B2.jpg");
        loadFromImage(tracker, @"50 B3.jpg");
        loadFromImage(tracker, @"50 B4.jpg");
        loadFromImage(tracker, @"50 B5.jpg");
        loadFromImage(tracker, @"50 B6.jpg");
        loadFromImage(tracker, @"50 B7.jpg");
//        loadFromImage(tracker, @"50 B8.jpg");
//        loadFromImage(tracker, @"50 B9.jpg");
//        loadFromImage(tracker, @"50 B10.jpg");
//        loadFromImage(tracker, @"50 B11.jpg");
        loadFromImage(tracker, @"50 F1.jpg");
        loadFromImage(tracker, @"50 F2.jpg");
        loadFromImage(tracker, @"50 F3.jpg");
        loadFromImage(tracker, @"50 F4.jpg");
        loadFromImage(tracker, @"50 F5.jpg");
        loadFromImage(tracker, @"50 F6.jpg");
        loadFromImage(tracker, @"50 F7.jpg");
//        loadFromImage(tracker, @"50 F8.jpg");
//        loadFromImage(tracker, @"50 F9.jpg");
//        loadFromImage(tracker, @"50 F10.jpg");
//        loadFromImage(tracker, @"50 F11.jpg");
//
        loadFromImage(tracker, @"100 B1.jpg");
        loadFromImage(tracker, @"100 B2.jpg");
        loadFromImage(tracker, @"100 B3.jpg");
        loadFromImage(tracker, @"100 B4.jpg");
        loadFromImage(tracker, @"100 B5.jpg");
        loadFromImage(tracker, @"100 B6.jpg");
        loadFromImage(tracker, @"100 B7.jpg");
//        loadFromImage(tracker, @"100 B8.jpg");
//        loadFromImage(tracker, @"100 B9.jpg");
//        loadFromImage(tracker, @"100 B10.jpg");
//        loadFromImage(tracker, @"100 B11.jpg");
        loadFromImage(tracker, @"100 F1.jpg");
        loadFromImage(tracker, @"100 F2.jpg");
        loadFromImage(tracker, @"100 F3.jpg");
        loadFromImage(tracker, @"100 F4.jpg");
        loadFromImage(tracker, @"100 F5.jpg");
        loadFromImage(tracker, @"100 F6.jpg");
        loadFromImage(tracker, @"100 F7.jpg");
//        loadFromImage(tracker, @"100 F8.jpg");
//        loadFromImage(tracker, @"100 F9.jpg");
//        loadFromImage(tracker, @"100 F10.jpg");
//        loadFromImage(tracker, @"100 F11.jpg");
//
        loadFromImage(tracker, @"500 B1.jpg");
        loadFromImage(tracker, @"500 B2.jpg");
        loadFromImage(tracker, @"500 B3.jpg");
        loadFromImage(tracker, @"500 B4.jpg");
        loadFromImage(tracker, @"500 B5.jpg");
        loadFromImage(tracker, @"500 B6.jpg");
        loadFromImage(tracker, @"500 B7.jpg");
//        loadFromImage(tracker, @"500 B8.jpg");
//        loadFromImage(tracker, @"500 B9.jpg");
//        loadFromImage(tracker, @"500 B10.jpg");
//        loadFromImage(tracker, @"500 B11.jpg");
        loadFromImage(tracker, @"500 F1.jpg");
        loadFromImage(tracker, @"500 F2.jpg");
        loadFromImage(tracker, @"500 F3.jpg");
        loadFromImage(tracker, @"500 F4.jpg");
        loadFromImage(tracker, @"500 F5.jpg");
        loadFromImage(tracker, @"500 F6.jpg");
        loadFromImage(tracker, @"500 F7.jpg");
//        loadFromImage(tracker, @"500 F8.jpg");
//        loadFromImage(tracker, @"500 F9.jpg");
//        loadFromImage(tracker, @"500 F10.jpg");
//        loadFromImage(tracker, @"500 F11.jpg");
    });
}



BOOL initialize()
{
    /*Iitialization for real notes detection mode*/
    fakeTrackerArray = [[NSMutableArray alloc] initWithCapacity:8];
    fakeTrackerNoteTypeArray = [[NSMutableSet alloc]initWithCapacity:2];
    
    camera = [easyar_CameraDevice create];
    streamer = [easyar_CameraFrameStreamer create];
    [streamer attachCamera:camera];
    
    bool status = true;
    status &= [camera open:easyar_CameraDeviceType_Default];
    [camera setSize:[easyar_Vec2I create:@[@1280, @720]]];

    if (!status) { return status; }
    
    tracker1 = [easyar_ImageTracker create];
    tracker2 = [easyar_ImageTracker create];

    tracker7 = [easyar_ImageTracker create];
    tracker8 = [easyar_ImageTracker create];

//    easyar_ImageTracker * tracker1 = [easyar_ImageTracker create];
    
    [tracker1 attachStreamer:streamer];
    [tracker2 attachStreamer:streamer];

    [tracker7 attachStreamer:streamer];
    [tracker8 attachStreamer:streamer];

    [tracker1 setSimultaneousNum:1]; //TO SCAN ONLY ONE PIECE AT A TIME
    [tracker2 setSimultaneousNum:1]; //TO SCAN ONLY ONE PIECE AT A TIME

    [tracker7 setSimultaneousNum:5]; //TO SCAN 5 PIECES AT A TIME
    [tracker8 setSimultaneousNum:5]; //TO SCAN 5 PIECES AT A TIME

    trackers = [[NSMutableArray<easyar_ImageTracker *> alloc] init];
    
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
        setTrackingObject(tracker1, tracker2);
        [trackers addObject:tracker1];
        [trackers addObject:tracker2];
    
//    changes dot technologies
//        setFakeRealTrackingObject(tracker1, tracker2);
//    });
    
    return status;
}

void finalize()
{
    [trackers removeAllObjects];
    box_renderer = nil;
    videobg_renderer = nil;
    streamer = nil;
    camera = nil;
}

BOOL start()
{
    /* Intialization for multiple mode*/
    array = [[NSMutableArray alloc] init];
    //    sumOfAmount = 0; //don't do it here, it can change it's camera in middle of calculation - by hassan :)
    /**/
    
    
    bool status = true;
    status &= (camera != nil) && [camera start];
    status &= (streamer != nil) && [streamer start];
    [camera setFocusMode:easyar_CameraDeviceFocusMode_Continousauto];
    
    for (easyar_ImageTracker * tracker in trackers) {
        
        status &= [tracker start];
        
        NSLog(@"target name %@",[[tracker targets].firstObject name]);
        NSLog(@"target status %d",status);
    }
    
    return status;
}

BOOL stop()
{
    bool status = true;
    for (easyar_ImageTracker * tracker in trackers) {
        status &= [tracker stop];
    }
    status &= (streamer != nil) && [streamer stop];
    status &= (camera != nil) && [camera stop];
    return status;
}

void initGL()
{
    videobg_renderer = [easyar_Renderer create];
    box_renderer = [BoxRenderer alloc];
    [box_renderer init_];
}

void resizeGL(int width, int height)
{
    view_size[0] = width;
    view_size[1] = height;
    viewport_changed = true;
}

void updateViewport()
{
    easyar_CameraCalibration * calib = camera != nil ? [camera cameraCalibration] : nil;
    int rotation = calib != nil ? [calib rotation] : 0;
    if (rotation != view_rotation) {
        view_rotation = rotation;
        viewport_changed = true;
    }
    if (viewport_changed) {
        int size[] = {1, 1};
        if (camera && [camera isOpened]) {
            size[0] = [[[camera size].data objectAtIndex:0] intValue];
            size[1] = [[[camera size].data objectAtIndex:1] intValue];
        }
        if (rotation == 90 || rotation == 270) {
            int t = size[0];
            size[0] = size[1];
            size[1] = t;
        }
        float scaleRatio = MAX((float)view_size[0] / (float)size[0], (float)view_size[1] / (float)size[1]);
        int viewport_size[] = {(int)roundf(size[0] * scaleRatio), (int)roundf(size[1] * scaleRatio)};
        int viewport_new[] = {(view_size[0] - viewport_size[0]) / 2, (view_size[1] - viewport_size[1]) / 2, viewport_size[0], viewport_size[1]};
        memcpy(&viewport[0], &viewport_new[0], 4 * sizeof(int));
        
        if (camera && [camera isOpened])
            viewport_changed = false;
    }
}

void render()
{
    glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (videobg_renderer != nil) {
        int default_viewport[] = {0, 0, view_size[0], view_size[1]};
        easyar_Vec4I * oc_default_viewport = [easyar_Vec4I create:@[[NSNumber numberWithInt:default_viewport[0]], [NSNumber numberWithInt:default_viewport[1]], [NSNumber numberWithInt:default_viewport[2]], [NSNumber numberWithInt:default_viewport[3]]]];
        glViewport(default_viewport[0], default_viewport[1], default_viewport[2], default_viewport[3]);
        if ([videobg_renderer renderErrorMessage:oc_default_viewport]) {
            return;
        }
    }

    if (streamer == nil) { return; }
    easyar_Frame *frame = [streamer peek];
    updateViewport();
    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

    if (videobg_renderer != nil) {
        [videobg_renderer render:frame viewport:[easyar_Vec4I create:@[[NSNumber numberWithInt:viewport[0]], [NSNumber numberWithInt:viewport[1]], [NSNumber numberWithInt:viewport[2]], [NSNumber numberWithInt:viewport[3]]]]];
    }
    
    //hassan changes
    if ([frame targetInstances].count == 0)
    {
        isSameNote = NO;
    }
    //end
    
    for (easyar_TargetInstance * targetInstance in [frame targetInstances])
    {
      //  printf("target count = %lu",(unsigned long)[frame targetInstances].count);
        easyar_TargetStatus status = [targetInstance status];
        if (status == easyar_TargetStatus_Tracked) {
            easyar_Target * target = [targetInstance target];
            //printf("\n runtime is = %d \n",[target runtimeID]);
            easyar_ImageTarget * imagetarget = [target isKindOfClass:[easyar_ImageTarget class]] ? (easyar_ImageTarget *)target : nil;
            if (imagetarget == nil) {
                continue;
            }
            
            NSString* text = [target name];
            if ([AppUtils getAppMode] == MRScanModeSingle)
            {
                [AppUtils postImageDetectNotificationWithText:text];
            }
            else if ([AppUtils getAppMode] == MRScanModeMultiple)
            {
                NSLog(@"Frames : %@", [frame targetInstances]);
//                double delayInSeconds = 3.0;
//                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                    NSLog(@"Do some work");
                      [box_renderer render:[camera projectionGL:0.2f farPlane:500.f] cameraview:[targetInstance poseGL] size:[imagetarget size]];
                if (isSameNote == NO)
                {
                    isSameNote = YES;
                    if (![array containsObject: [NSNumber numberWithInt:[target runtimeID]]])
                    {
                        
                        sumOfAmount += [text integerValue];
                        [array addObject:[NSNumber numberWithInt:[target runtimeID]]];
                        //printf("sum of amount = %d",sumOfAmount);
                        //hassan changes
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                        NSURL *tone = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tone" ofType:@"m4a"]];
                        audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:tone error:NULL];
                        audioPlayer.volume = 1;
                        [audioPlayer play];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [array removeObject:[NSNumber numberWithInt:[target runtimeID]]];
                        });
                        //end
                    }
                }
                
              
//                });
            }
            else
            {
                if (![fakeTrackerArray containsObject: [NSNumber numberWithInt:[target runtimeID]]])
                {
                    
                    printf("runtimeID = %d",[target runtimeID]);
                    
                    NSLog(@"target name = %@",[target name]);
                    if (detectedNote.length == 0)
                    {
                        detectedNote = [text componentsSeparatedByString:@" "].firstObject;
                    }
                    
                    if ([detectedNote isEqualToString: [text componentsSeparatedByString:@" "].firstObject])
                    {
                       NSString* noteSide = [text componentsSeparatedByString:@" "].lastObject;
                        if (([text containsString:@"Front"]) || ([text containsString:@"Back"]))
                        {
                            if ([text containsString:@"Front"])
                            {
                                int count = fakeTrackerNoteTypeArray.count;
                                [fakeTrackerNoteTypeArray addObject:@"Front"];
                                if (count != fakeTrackerNoteTypeArray.count)
                                {
                                    [fakeTrackerArray addObject:[NSNumber numberWithInt:[target runtimeID]]];
                                }
                            }
                                else if ([text containsString:@"Back"])
                                {
                                    int count = fakeTrackerNoteTypeArray.count;

                                    [fakeTrackerNoteTypeArray addObject:@"Back"];
                                    if (count != fakeTrackerNoteTypeArray.count)
                                    {
                                        [fakeTrackerArray addObject:[NSNumber numberWithInt:[target runtimeID]]];
                                    }
                                }
                        }
                    }
                    else
                    {
                        [fakeTrackerArray removeAllObjects];
                        [fakeTrackerNoteTypeArray removeAllObjects];

                    }
                    
                    if (fakeTrackerArray.count == 1 && [detectedNote isEqualToString: [text componentsSeparatedByString:@" "].firstObject])
                    {
                        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:text,@"side",@(1),@"count", nil];
                        detectedNote = [text componentsSeparatedByString:@" "].firstObject;
//                        [AppUtils postRealNoteDetectedNotification:dic];
                        
                        if (any == YES) {
                            any = NO;
                            [AppUtils postRealNoteDetectedNotification:dic];
                        }
                        
                    }
                    else if (fakeTrackerArray.count >= 2 && [detectedNote isEqualToString: [text componentsSeparatedByString:@" "].firstObject])
                    {
                        
                        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:text,@"side",@(2),@"count", nil];
                        
                        [fakeTrackerArray removeAllObjects];
                        [fakeTrackerNoteTypeArray removeAllObjects];

                        //hassan commented and took one step up this line for after one note detection complition
                        
                        [AppUtils postRealNoteDetectedNotification:dic];
                        any = YES;
                    }
                }
                else
                {
//                    if (any == YES) {
//                        any = NO;
////                        [AppUtils postRealNoteDetectedNotification:dic];
//                    
//                          printf("Other side");
//
//                    }
                }
                
                detectedNote = [text componentsSeparatedByString:@" "].firstObject;
                [box_renderer render:[camera projectionGL:0.2f farPlane:500.f] cameraview:[targetInstance poseGL] size:[imagetarget size]];
            }
        }
    }
}

   

NSString* getSum(){
    return [NSString stringWithFormat:@"%.1f",sumOfAmount]; //hassan changes
}
void setTotalSumToZero(){
    sumOfAmount = 0 ;
}
void removeTrackingIDs(){
    [array removeAllObjects];
}

void switchCamera(easyar_CameraDeviceType cameraType){
    
    stop();
    [camera open:cameraType];
    start();
}

void setTargetForRealNoteDetection()
{
    
//    stop();
//
//    easyar_ImageTracker * tracker3 = [easyar_ImageTracker create];
//
//    [tracker3 attachStreamer:streamer];
//
//    [tracker3 setSimultaneousNum:5];
//
////    dispatch_async(dispatch_get_main_queue(), ^(void){
////
////    for (easyar_ImageTracker * tracker in trackers) {
////        for (easyar_Target * target in [tracker targets]) {
////            [tracker unloadTargetBlocked:target];
////        }
////    }
////
////    });
//
//
//    setFakeRealTrackingObject(tracker3);
//
//    [trackers removeAllObjects];
//
//
////    [trackers addObject:tracker1];
////    [trackers addObject:tracker2];
//    [trackers addObject:tracker3];
//
//    start();
    
    //hassan did it later to prevent reloading images for trackers
    stop();
    [fakeTrackerArray removeAllObjects];
    [fakeTrackerNoteTypeArray removeAllObjects];
    [trackers removeAllObjects];
    // changes done dot technologies
    start();

        double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Do some work");
    
    [trackers addObject:tracker1];   // tracker 7
    [trackers addObject:tracker2];  // tracker 8
        start();

    });

}

void resetTarget()
{
//    stop();
//    easyar_ImageTracker * tracker1 = [easyar_ImageTracker create];
//
//    [tracker1 attachStreamer:streamer];
//
//    [tracker1 setSimultaneousNum:1];
//
//    for (easyar_ImageTracker * tracker in trackers) {
//        for (easyar_Target * target in [tracker targets]) {
//            [tracker unloadTargetBlocked:target];
//        }
//
//    }
//
//    [trackers removeAllObjects];
//
//    setTrackingObject(tracker1);
//
//    [trackers addObject:tracker1];
//    start();
//
//    [fakeTrackerArray removeAllObjects];
    
    
    
    //hassan did it later to prevent reloading images for trackers
    stop();
    [fakeTrackerArray removeAllObjects];
    [fakeTrackerNoteTypeArray removeAllObjects];

    [trackers removeAllObjects];
    start();

    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Do some work");
        
    [trackers addObject:tracker1];
    [trackers addObject:tracker2];
    start();
        
    });
}
