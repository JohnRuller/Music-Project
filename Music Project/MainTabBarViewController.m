//
//  MainTabBarViewController.m
//  Music Project
//
//  Created by John Ruller on 2014-03-13.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

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
    NSLog(@"Load tab bar view controller.");
    
    //setup tabbarcontroller
    UITabBarController *tabBarController = (UITabBarController *)self;
    
    //load the playlist view
    UIViewController *playlistView = [tabBarController.viewControllers objectAtIndex:1];
    [playlistView loadView];
    
    // load the chat view
    UIViewController *chatView = [tabBarController.viewControllers objectAtIndex:2];
    [chatView loadView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
