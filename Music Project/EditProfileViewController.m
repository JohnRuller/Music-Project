//
//  EditProfileViewController.m
//  Music Project
//
//  Created by John Ruller on 2014-02-10.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "EditProfileViewController.h"
#import "profileManager.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

profileManager *userProfile;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    userProfile = [[profileManager alloc] init];
    
    //error handler for when device does not have camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
        //hide take photo button if camera doesn't exist on device
        _takePhotoButton.enabled = NO;
        _takePhotoButton.hidden = YES;
        
    }
    
    //set text fields
    [self.nameTextField setText:userProfile.name];
    [self.taglineTextField setText:userProfile.tagline];
    
    //set image
    UIImage *image = [UIImage imageWithData:userProfile.profilePhoto];
    self.imageView.image = image;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {

    [userProfile setName:self.nameTextField.text];
    [userProfile setTagline:self.taglineTextField.text];
    [userProfile setProfilePhoto:self.imageView.image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Camera

//uses camera to take photo
- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

//uses photo from library
- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

//camera delegate functions
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    //this would set the image view to the chosen imgae
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end
