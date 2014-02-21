//
//  CreateRoomMenuViewController.h
//  Music Project
//
//  Created by Ryan Fraser on 1/24/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CreateRoomViewController.h"
#import "ConnectionsViewController.h"
#import "myManager.h"

@interface CreateRoomMenuViewController : UIViewController
@property (nonatomic, weak) NSString *roomName;
@property (weak, nonatomic) NSString *isHost;
@end
