//=============================================================================================================================
//
// Copyright (c) 2015-2017 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import <GLKit/GLKView.h>
#import <easyar/types.oc.h>

@interface OpenGLView : GLKView

@property (nonatomic) easyar_CameraDeviceType cameraType; //added by hassan

- (void)start;
- (void)stop;
- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (NSString*) getTotalSum;
- (void) setTotalSumToZer;
- (void) removeTrackingID;
- (void)switchCamera:(easyar_CameraDeviceType )cameraType;
-(void)realNoteSideDetected;
-(void)resetTrackingTarget;
-(void)startTrackingRealNote;
@end
