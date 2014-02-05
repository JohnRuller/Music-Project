//
//  ProfileViewController.m
//  Music Project
//
//  Created by John Ruller on 2013-11-21.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import "ProfileViewController.h"
@interface ProfileViewController (CameraDelegateMethods)

@end

@implementation ProfileViewController


@synthesize fileURL = _fileURL;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Profile";
    
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.fileURL = [[urls lastObject] URLByAppendingPathComponent:@"Test"];
    
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

-(IBAction)writeArchivedData:(id)sender {
    
    NSMutableArray *items = [NSMutableArray array];
    
    [items addObject:@"Hello"];
    [items addObject:[NSDate date]];
    [items addObject:[NSNumber numberWithFloat:12.0]];
    
    
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:items];
    [fileData writeToURL:self.fileURL atomically:YES];
}

-(IBAction)readArchivedData:(id)sender {
	NSData *data = [NSData dataWithContentsOfURL:self.fileURL];
	NSMutableArray *items = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSLog(@"%@", items);
}


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

//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
