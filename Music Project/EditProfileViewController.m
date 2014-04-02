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
    
    //try to fix the nav bar height
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        self.navBar.frame = CGRectMake(self.navBar.frame.origin.x, self.navBar.frame.origin.y, self.navBar.frame.size.width, 64);
    }
    
    //set text field delegate
    _nameTextField.delegate = self;
    _taglineTextField.delegate = self;
    
    //set the return button to "done" for text fields: http://stackoverflow.com/questions/6311015/how-do-i-programmatically-set-the-return-key-for-a-particular-uitextfield
    _nameTextField.returnKeyType = UIReturnKeyDone;
    _taglineTextField.returnKeyType = UIReturnKeyDone;

    //initiate profile class instance
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
        //_takePhotoButton.hidden = YES;
        
    }
    
    //set text fields
    [self.nameTextField setText:userProfile.name];
    [self.taglineTextField setText:userProfile.tagline];
    
    //set image
    UIImage *image = [UIImage imageWithData:userProfile.profilePhoto];
    self.imageView.image = image;
    
    // set image layer circular
    CALayer * l = [self.imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:80.0];
    [l setBorderWidth:0.25];
    [l setBorderColor:[[UIColor blackColor] CGColor]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//function to resign keyboard when background is touched: http://stackoverflow.com/questions/804563/how-to-hide-the-keyboard-when-empty-area-is-touched-on-iphone
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/*
 functions for pushing the screen up when the keyboard is brought up: http://stackoverflow.com/questions/1247113/iphone-keyboard-covers-uitextfield
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self animateTextField: textField up: YES];
    }];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self animateTextField: textField up: NO];
    }];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        const int movementDistance = 160; // tweak as needed
        const float movementDuration = 0.3f; // tweak as needed
        
        int movement = (up ? -movementDistance : movementDistance);
        
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    }];
}

#pragma mark - Buttons

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    
    //ensure there is a name set
    if([_nameTextField.text  isEqual: @""]) {
        _nameTextField.text = [UIDevice currentDevice].name;
    }
    
    //set values in core data
    [userProfile setName:self.nameTextField.text];
    [userProfile setTagline:self.taglineTextField.text];
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    [userProfile setProfilePhoto:imageData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clear:(id)sender {
    _nameTextField.text = @"";
    _taglineTextField.text = @"";
    _imageView.image = [UIImage imageNamed:@"defaultProfile2.png"];
}

#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
