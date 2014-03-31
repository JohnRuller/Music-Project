//
//  EditProfileViewController.h
//  Music Project
//
//  Created by John Ruller on 2014-02-10.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreData/CoreData.h>

@interface EditProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

//text fields
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *taglineTextField;
//navigation bar
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

//camera functionality propertires
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;
@property (nonatomic, strong) IBOutlet UIButton *takePhotoButton;

//buttons
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)clear:(id)sender;


@end
