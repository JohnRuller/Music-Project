//
//  ConnectionsViewController.h
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "hostManager.h"


@interface ConnectionsViewController : UIViewController <MCBrowserViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblConnectedDevices;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;

- (IBAction)browseForDevices:(id)sender;
- (IBAction)disconnect:(id)sender;
-(void)setupDisconnect;

-(void)disconnectFunc;


@end
