//
//  MainViewController.m
//  Music Project
//
//  Created by John Ruller on 2013-11-20.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import "MainViewController.h"
#import "profileManager.h"

@implementation MainViewController

@synthesize viewLogo;
@synthesize createRoomButton;
@synthesize joinRoomButton;
@synthesize editProfileButton;
@synthesize helpButton;
@synthesize viewButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Music720";
    
    UIImage *logoImage = [UIImage imageNamed:@"Music720"];
	viewLogo.image = logoImage;
    
    profileManager *profile;
    profile = [[profileManager alloc] init];
}

- (IBAction)createRoom:(id)sender
{
    
}

- (void)joinRoom:(id)sender
{

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createRoom"])
    {
        NSLog(@"User chose to be host.");
        hostManager *sharedManager = [hostManager sharedManager];
        sharedManager.someProperty = @"YES";
    }
    
    if ([segue.identifier isEqualToString:@"joinRoom"])
    {
        NSLog(@"User chose to be guest.");
        hostManager *sharedManager = [hostManager sharedManager];
        sharedManager.someProperty = @"NO";
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {

        NSLog(@":%@",[[alertView textFieldAtIndex:0] text]);
    }
}

@end
