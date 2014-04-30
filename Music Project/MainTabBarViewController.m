//
//  MainTabBarViewController.m
//  Music Project
//
//  Created by John Ruller on 2014-03-13.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "myManager.h"

@interface MainTabBarViewController ()
-(void)loadTabs;
-(void)enableGuestTabs;
@end

@implementation MainTabBarViewController

UITabBarController *tabBarController;

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
    tabBarController = (UITabBarController *)self;
    
    [self loadTabs];
    
    //setup mymanager
    MyManager *sharedManager = [MyManager sharedManager];
    if (![sharedManager.someProperty isEqualToString:@"YES"])
    {
        NSLog(@"Disable tabs for guest.");
        
        [[[[tabBarController tabBar]items]objectAtIndex:1]setEnabled:FALSE];
        [[[[tabBarController tabBar]items]objectAtIndex:2]setEnabled:FALSE];
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTabs {
    //load the playlist view
    UIViewController *playlistView = [tabBarController.viewControllers objectAtIndex:1];
    [playlistView loadView];
    
    // load the chat view
    UIViewController *chatView = [tabBarController.viewControllers objectAtIndex:2];
    [chatView loadView];
}

- (void)enableGuestTabs {
    [[[[tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
    [[[[tabBarController tabBar]items]objectAtIndex:2]setEnabled:TRUE];
}

@end
