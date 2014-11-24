//
//  APHPhonationTaskViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHPhonationTaskViewController.h"
#import "APHPhonationIntroViewController.h"
#import "APHCommonTaskSummaryViewController.h"

#import <objc/message.h>
#import <AVFoundation/AVFoundation.h>
#import "APHAudioRecorderConfiguration.h"
#import "APHAudioRecorder.h"
#import "APHPhonationMeteringView.h"

#import <ResearchKit/ResearchKit_Private.h>

static  NSString       *MainStudyIdentifier        = @"com.parkinsons.phonation";

static  NSString       *kPhonationStep101Key       = @"Phonation_Step_101";

static  NSString       *kGetReadyStep              = @"Get Ready";
static  NSTimeInterval  kGetReadyCountDownInterval = 5.0;

static  NSString       *kPhonationStep102Key       = @"Phonation_Step_102";
static  NSTimeInterval  kGetSoundingAaahhhInterval = 10.0;

static  NSString       *kPhonationStep103Key       = @"Phonation_Step_103";

static  NSString       *kTaskViewControllerTitle   = @"Sustained Phonation";

static  CGFloat         kMeteringDisplayWidth      = 180.0;

@interface APHPhonationTaskViewController ()

@property (strong, nonatomic)   RKSTDataArchive                *taskArchive;

    //
    //    metering-related stuff
    //
@property  (nonatomic, weak)    APHPhonationMeteringView       *meteringDisplay;
@property  (nonatomic, strong)  NSTimer                        *meteringTimer;

@property  (nonatomic, strong)  APHAudioRecorderConfiguration  *audioConfiguration;
@property  (nonatomic, strong)  AVAudioRecorder                *audioRecorder;

@end

@implementation APHPhonationTaskViewController

#pragma  mark  -  Initialisation

+ (RKSTOrderedTask *)createTask:(APCScheduledTask*) scheduledTask
{
    
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        RKSTInstructionStep  *step = [[RKSTInstructionStep alloc] initWithIdentifier:kPhonationStep101Key];
        step.title = @"Tests Speech Difficulties";
        step.text = @"";
        step.detailText = @"In the next screen you will be asked to say “Aaaahhh” for 10 seconds.";
        [steps addObject:step];
    }
    
    {
        //Introduction to fitness test
        RKSTActiveStep  *step = [[RKSTActiveStep alloc] initWithIdentifier:kGetReadyStep];
        step.title = NSLocalizedString(@"Sustained Phonation", @"");
        step.text = NSLocalizedString(@"Get Ready!", @"");
        step.countDownInterval = kGetReadyCountDownInterval;
        step.shouldStartTimerAutomatically = YES;
        step.shouldUseNextAsSkipButton = NO;
        step.shouldPlaySoundOnStart = YES;
        step.shouldSpeakCountDown = YES;
        
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep  *step = [[RKSTActiveStep alloc] initWithIdentifier:kPhonationStep102Key];
        step.text = @"Please say “Aaaahhh” for 10 seconds";
        step.countDownInterval = kGetSoundingAaahhhInterval;
        step.shouldStartTimerAutomatically = YES;
        step.shouldPlaySoundOnStart = YES;
        step.shouldVibrateOnStart = YES;
        step.recorderConfigurations = @[[[APHAudioRecorderConfiguration alloc] initWithRecorderSettings:@{ AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                                                                            AVNumberOfChannelsKey : @(1),
                                                                                                            AVSampleRateKey: @(44100.0)
                                                                                                            }]];
        [steps addObject:step];
    }
    
    {
        RKSTInstructionStep  *step = [[RKSTInstructionStep alloc] initWithIdentifier:kPhonationStep103Key];
        step.title = @"Great Job!";
        [steps addObject:step];
    }
    
    RKSTOrderedTask  *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"Phonation Task" steps:steps];
    
    return  task;
}

#pragma  mark  -  Task View Controller Delegate Methods

- (BOOL)taskViewController:(RKSTTaskViewController *)taskViewController shouldPresentStepViewController:(RKSTStepViewController *)stepViewController
{
    return  YES;
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController willPresentStepViewController:(RKSTStepViewController *)stepViewController
{
    stepViewController.cancelButton = nil;
    stepViewController.backButton = nil;
    stepViewController.continueButton = nil;
}

- (RKSTStepViewController *)taskViewController:(RKSTTaskViewController *)taskViewController viewControllerForStep:(RKSTStep *)step
{
    NSDictionary  *controllers = @{
                                   kPhonationStep101Key : [APHPhonationIntroViewController class],
                                   kGetReadyStep : [APCActiveStepViewController class],
                                   kPhonationStep102Key : [APCActiveStepViewController class],
                                   kPhonationStep103Key : [APHCommonTaskSummaryViewController class]
                                   };
    Class  aClass = [controllers objectForKey:step.identifier];
    APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.title = @"Sustained Phonation";
    controller.step = step;
    return  controller;
}

#pragma  mark  - View Controller methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.topItem.title = NSLocalizedString(kTaskViewControllerTitle, nil);
    
//    self.stepsToAutomaticallyAdvanceOnTimer = @[ kGetReadyStep, kPhonationStep102Key ];
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (void)taskViewControllerDidFail: (RKSTTaskViewController *)taskViewController withError:(NSError*)error
{
    
    [self.taskArchive resetContent];
    self.taskArchive = nil;
}

/*********************************************************************************/
#pragma mark - Audio Recorder Notification Method
/*********************************************************************************/

- (void)audioRecorderDidStart:(NSNotification *)notification
{
    NSDictionary  *info = [notification userInfo];
    RKSTAudioRecorder  *recorder = [info objectForKey:APHAudioRecorderInstanceKey];
    self.audioRecorder = recorder.audioRecorder;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APHAudioRecorderDidStartKey object:nil];
    
    self.audioRecorder.meteringEnabled = YES;
    [self setupTimer];
}

/*********************************************************************************/
#pragma mark - StepViewController Delegate Methods
/*********************************************************************************/

- (void)stepViewControllerWillAppear:(RKSTStepViewController *)viewController
{
    [super stepViewControllerWillAppear:viewController];
    viewController.skipButton = nil;
    viewController.continueButton = nil;

    if ([viewController.step.identifier isEqualToString:kPhonationStep102Key] == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRecorderDidStart:) name:APHAudioRecorderDidStartKey object:nil];
        RKSTActiveStep  *activeStep = (RKSTActiveStep *)viewController.step;
        self.audioConfiguration = [activeStep.recorderConfigurations firstObject];
        
        [self addMeteringStuff:(APCStepViewController *)viewController];
    }
}

- (void)stepViewControllerDidFinish:(RKSTStepViewController *)stepViewController navigationDirection:(RKSTStepViewControllerNavigationDirection)direction
{
    [super stepViewControllerDidFinish:stepViewController navigationDirection:direction];
    
    if ([stepViewController.step.identifier isEqualToString:kPhonationStep102Key] == YES) {
        [self.meteringTimer invalidate];
        self.meteringTimer = nil;
        self.audioRecorder = nil;
    }
    stepViewController.continueButton = nil;
}

/*********************************************************************************/
#pragma mark - Metering Logic (if you stretch the term 'logic') . . .
/*********************************************************************************/

- (void)addMeteringStuff:(APCStepViewController *)viewController
{
    APHPhonationMeteringView  *meterologist = [[APHPhonationMeteringView alloc] initWithFrame:CGRectMake(0.0, 0.0, kMeteringDisplayWidth, kMeteringDisplayWidth)];
    self.meteringDisplay = meterologist;
    
    NSArray  *vc1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(==180.0)]" options:0 metrics:nil views:@{@"c":meterologist}];
    [meterologist addConstraints:vc1];
    NSArray  *vc2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(==180.0)]" options:0 metrics:nil views:@{@"c":meterologist}];
    [meterologist addConstraints:vc2];
    
    [viewController.view addSubview:meterologist];
    [meterologist setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    NSArray  *constraints = @[
                              [NSLayoutConstraint constraintWithItem:viewController.view
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:meterologist
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:10.0],
                              [NSLayoutConstraint constraintWithItem:viewController.view
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:meterologist
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0]
                              ];
    
    [viewController.view addConstraints:constraints];
//    [viewController.view layoutSubviews];
    [viewController.view bringSubviewToFront:meterologist];
}

- (void)setupTimer
{
    self.meteringTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(meteringTimerDidFire:)
                                                        userInfo:nil
                                                         repeats:YES];
}

static  float  kMinimumPowerOffsetFromBase = 60.0;
static  float  kMaximumPowerOffsetFromFull =  2.5;

- (void)meteringTimerDidFire:(NSTimer *)timer
{
    [self.audioRecorder updateMeters];
    
    float  averagePowerForChannelOne = [self.audioRecorder averagePowerForChannel:0];
    NSLog(@"averagePowerForChannelOne before %.2f", averagePowerForChannelOne);
    averagePowerForChannelOne = averagePowerForChannelOne + kMinimumPowerOffsetFromBase;
    if (averagePowerForChannelOne < 0.0) {
        averagePowerForChannelOne = 0.0;
    }
    if (averagePowerForChannelOne > (kMinimumPowerOffsetFromBase - kMaximumPowerOffsetFromFull)) {
        averagePowerForChannelOne = (kMinimumPowerOffsetFromBase - kMaximumPowerOffsetFromFull);
    }
    averagePowerForChannelOne = averagePowerForChannelOne / (kMinimumPowerOffsetFromBase - kMaximumPowerOffsetFromFull);
    self.meteringDisplay.powerLevel = averagePowerForChannelOne;
    [self.meteringDisplay setNeedsDisplay];
    NSLog(@"averagePowerForChannelOne after %.2f", averagePowerForChannelOne);
}

@end
