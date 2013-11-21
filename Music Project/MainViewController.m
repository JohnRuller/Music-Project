//
//  MainViewController.m
//  Music Project
//
//  Created by John Ruller on 2013-11-20.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize viewLogo;
@synthesize createRoomButton;
@synthesize joinRoomButton;
@synthesize editProfileButton;
@synthesize helpButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Music720";
    
    UIImage *logoImage = [UIImage imageNamed:@"Music720"];
	viewLogo.image = logoImage;
}

@end
