//
//  ProfileViewController.h
//  Music Project
//
//  Created by John Ruller on 2013-11-21.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

//camera functionality propertires
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

//buttons
- (IBAction)back:(id)sender;

//navigation bar
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

//labels
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;

@end
