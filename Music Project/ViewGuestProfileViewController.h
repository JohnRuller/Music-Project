//
//  ViewGuestProfileViewController.h
//  Music Project
//
//  Created by John Ruller on 2014-03-16.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewGuestProfileViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *taglineLabel;
- (IBAction)back:(id)sender;

@end
