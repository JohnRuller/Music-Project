//
//  EditProfileViewController.h
//  Music Project
//
//  Created by John Ruller on 2014-02-10.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *taglineTextField;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
