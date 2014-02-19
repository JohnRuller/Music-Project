//
//  ProfileViewController.h
//  Music Project
//
//  Created by John Ruller on 2013-11-21.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <MobileCoreServices/MobileCoreServices.h>

@interface ProfileViewController : UIViewController //<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/*

//camera functionality propertires
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;
 
*/

- (IBAction)back:(id)sender;

//labels
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;

@end
