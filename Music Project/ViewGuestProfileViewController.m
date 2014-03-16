//
//  ViewGuestProfileViewController.m
//  Music Project
//
//  Created by John Ruller on 2014-03-16.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "ViewGuestProfileViewController.h"

@interface ViewGuestProfileViewController ()

@end

@implementation ViewGuestProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
