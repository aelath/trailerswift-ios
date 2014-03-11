//
//  TSMainViewController.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/7/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import "TSMainViewController.h"
#import "TSGeoLocManager.h"

@interface TSMainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *myButton;
- (IBAction)newLocation:(UIButton *)sender;

@end

@implementation TSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newLocation:(UIButton *)sender {
    TSGeoLocManager *glocMan = [[TSGeoLocManager alloc] init];
    [glocMan getLocation];
}
@end
