//
//  MainViewController.h
//  Music Project
//
//  Created by John Ruller on 2013-11-20.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myManager.h"

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *viewLogo;
@property (weak, nonatomic) IBOutlet UIButton *createRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *joinRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;

- (IBAction)createRoom:(id)sender;
- (IBAction)joinRoom:(id)sender;


@end
