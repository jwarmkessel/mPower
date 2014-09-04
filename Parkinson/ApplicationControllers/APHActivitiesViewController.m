//
//  APHActivitiesViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import "APHActivitiesViewController.h"

#import "APHWalkingOverviewViewController.h"

#import "APHWalkingStepsViewController.h"
#import "APHWalkingResultsViewController.h"

#import "APHWalkingTaskViewController.h"

#import "APHPhonationOverviewViewController.h"
#import "APHSleepQualityOverviewViewController.h"
#import "APHChangedMedsOverviewViewController.h"
#import "APHIntervalOverviewViewController.h"
#import "APHTracingOverviewViewController.h"

#import "APHActivitiesTableViewCell.h"
#import "NSString+CustomMethods.h"
#import "APHStepDictionaryKeys.h"

#import <ResearchKit/ResearchKit.h>

static  NSInteger  kNumberOfSectionsInTableView = 1;

static  NSString   *kTableCellReuseIdentifier = @"ActivitiesTableViewCell";
static  NSString   *kViewControllerTitle      = @"Activities";

@interface APHActivitiesViewController () <UITableViewDataSource, UITableViewDelegate, RKTaskViewControllerDelegate, RKStepViewControllerDelegate>

@property  (nonatomic, strong)  IBOutlet  UITableView            *tabulator;

@property  (nonatomic, strong)            NSArray                *rowTitles;
@property  (nonatomic, strong)            NSArray                *rowSubTitles;

@property  (nonatomic, strong)            NSIndexPath            *selectedIndexPath;

@end

@implementation APHActivitiesViewController

#pragma  mark  -  Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  kNumberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.rowTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APHActivitiesTableViewCell  *cell = (APHActivitiesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kTableCellReuseIdentifier];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.title.text = self.rowTitles[indexPath.row];
    if ([self.rowTitles[indexPath.row] hasContent] == YES) {
        cell.subTitle.text = self.rowSubTitles[indexPath.row];
    }
    if (indexPath.row == 4) {
        cell.completed = YES;
    }
    
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  44.0;
}

#pragma  mark  -  Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    NSArray  *controllerClasses = @[
                                    [APHWalkingTaskViewController      class],
                                    [APHPhonationOverviewViewController    class],
                                    [APHSleepQualityOverviewViewController class],
                                    [APHChangedMedsOverviewViewController  class],
                                    [APHIntervalOverviewViewController     class],
                                    [APHTracingOverviewViewController      class]
                                ];
    if (indexPath.row < [controllerClasses count]) {
        Class  class = controllerClasses[indexPath.row];
        if (class != [NSNull class]) {
            RKTaskViewController  *controller = [class customTaskViewController];
            
            [self presentViewController:controller animated:YES completion:^{
                NSLog(@"task Presented");
            }];
        }
    }
}

#pragma  mark  -  View Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Activities";
    
    self.rowTitles = @[
                       @"Timed Walking",
                       @"Sustained Phonation",
                       @"Did you sleep well last night?",
                       @"Have you recently changed medications?",
                       @"Interval Tapping",
                       @"Tracing Objects"
                       ];
    
    self.rowSubTitles = @[
                       @"Afternoon and Evening Remaining",
                       @"Evening Remaining",
                       @"",
                       @"",
                       @"Morning, Evening and Night Completed",
                       @"Completed"
                       ];
    
    UINib  *tableCellNib = [UINib nibWithNibName:@"APHActivitiesTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tabulator registerNib:tableCellNib forCellReuseIdentifier:kTableCellReuseIdentifier ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.selectedIndexPath != nil) {
        [self.tabulator deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
        self.selectedIndexPath = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
