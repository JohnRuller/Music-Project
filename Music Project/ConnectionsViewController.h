//
//  ConnectionsViewController.h
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "myManager.h"


@interface ConnectionsViewController : UIViewController <MCBrowserViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblConnectedDevices;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;
@property (nonatomic, strong) NSString *hostName;



- (IBAction)browseForDevices:(id)sender;
//- (IBAction)toggleVisibility:(id)sender;
- (IBAction)disconnect:(id)sender;



@end
