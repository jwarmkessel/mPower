//
//  YMLWalkingResultsViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import "YMLWalkingResultsViewController.h"

@interface YMLWalkingResultsViewController ()

@end

@implementation YMLWalkingResultsViewController

#pragma  mark  -  Action Methods

- (IBAction)goBackToOverview:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma  mark  -  View Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
