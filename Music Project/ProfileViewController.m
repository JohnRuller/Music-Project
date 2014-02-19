//
//  ProfileViewController.m
//  Music Project
//
//  Created by John Ruller on 2013-11-21.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import "ProfileViewController.h"
#import "EditProfileViewController.h"

@interface ProfileViewController ()

//array to store managedObjects for core data
@property (strong) NSMutableArray *profiles;

@end

@implementation ProfileViewController

//labels
@synthesize nameLabel;
@synthesize taglineLabel;

//managedObject for core data
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Profile"];
    self.profiles = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    //set the name/tagline/image with data from the model
    if([self.profiles count] != 0)
    {
        NSManagedObject *profile = [self.profiles objectAtIndex:0];
        
        //labels
        nameLabel.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"name"]];
        taglineLabel.text = [NSString stringWithFormat:@"%@",[profile valueForKey:@"tagline"]];
        
        //image
        UIImage *image = [UIImage imageWithData:[profile valueForKey:@"photo"]];
        self.imageView.image = image;
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.title = @"Profile";
    
    //error handler for when device does not have camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//back button
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segue

//passing profile managedObject to edit profile view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"UpdateProfile"] && [self.profiles count] != 0) {
        NSManagedObject *selectedProfile = [self.profiles objectAtIndex:0];
        EditProfileViewController *destViewController = segue.destinationViewController;
        destViewController.profile = selectedProfile;
    }
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
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    
    //storing photo in core data
    NSManagedObject *imageProfile = [self.profiles objectAtIndex:0];
    [imageProfile setValue:imageData forKey:@"photo"];
    
    //this would set the image view to the chosen imgae
    //self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
