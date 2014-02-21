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
@synthesize viewButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Music720";
    
    UIImage *logoImage = [UIImage imageNamed:@"Music720"];
	viewLogo.image = logoImage;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //self.roomName = self.myTextField.text;
    //_isHost = @"YES";
    MyManager *sharedManager = [MyManager sharedManager];
    sharedManager.someProperty = @"NO";
    
    /*if([segue.identifier isEqualToString:@"showDetailSegue"]){
     //CreateRoomViewController *controller = (CreateRoomViewController *)segue.destinationViewController;
     //controller.thisRoomName = self.roomName;
     UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
     ConnectionsViewController *controller = (ConnectionsViewController *)navController.topViewController;
     controller.isHost = @"YES";
     }*/
}

@end
