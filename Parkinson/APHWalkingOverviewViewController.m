//
//  APHWalkingOverviewViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import "APHWalkingOverviewViewController.h"
#import "APHConfirmationView.h"
//#import "APHWalkingStepsViewController.h"

static  NSString  *kControllerTitle = @"Timed Walking";

static  CGFloat  kCornerRadius = 8.0;

@interface APHWalkingOverviewViewController () <RKTaskViewControllerDelegate>

@property  (nonatomic, weak)  IBOutlet  UIView               *morningView;
@property  (nonatomic, weak)  IBOutlet  APHConfirmationView  *morningViewConfirm;
@property  (nonatomic, weak)  IBOutlet  UILabel              *morningMessage;

@property  (nonatomic, weak)  IBOutlet  UIView               *afternoonView;
@property  (nonatomic, weak)  IBOutlet  APHConfirmationView  *afternoonViewConfirm;
@property  (nonatomic, weak)  IBOutlet  UILabel              *afternoonMessage;

@property  (nonatomic, weak)  IBOutlet  UIView               *eveningView;
@property  (nonatomic, weak)  IBOutlet  APHConfirmationView  *eveningViewConfirm;
@property  (nonatomic, weak)  IBOutlet  UILabel              *eveningMessage;

@end

@implementation APHWalkingOverviewViewController

#pragma  mark  -  Action Methods

#pragma  mark  -  View Controller Methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationItem.title = kControllerTitle;
}

- (void)makeRoundCorners:(UIView *)view
{
    CALayer  *layer = view.layer;
    layer.cornerRadius = kCornerRadius;
    layer.masksToBounds = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeRoundCorners:self.morningView];
    [self makeRoundCorners:self.afternoonView];
    [self makeRoundCorners:self.eveningView];
    
    self.delegate = self.taskViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
