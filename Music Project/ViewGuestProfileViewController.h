//
//  ViewGuestProfileViewController.h
//  Music Project
//
//  Created by John Ruller on 2014-03-16.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewGuestProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *taglineLabel;
@property (strong, nonatomic) IBOutlet UILabel *matchingLabel;
@property (strong, nonatomic) IBOutlet UILabel *compLabel;
@property (strong, nonatomic) IBOutlet UIImageView *compImageView;
- (IBAction)back:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *artistTableView;

@property (strong) NSDictionary *guestDictionary;

@end
