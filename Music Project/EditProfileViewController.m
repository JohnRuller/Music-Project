//
//  EditProfileViewController.m
//  Music Project
//
//  Created by John Ruller on 2014-02-10.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

//managed object for core data
@synthesize profile;

//managed object for core data
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.profile) {
        [self.nameTextField setText:[self.profile valueForKey:@"name"]];
        [self.taglineTextField setText:[self.profile valueForKey:@"tagline"]];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//buttons
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //either set data for existing object, or create new one
    if(self.profile) {
        //update existing profile
        [self.profile setValue:self.nameTextField.text forKey:@"name"];
        [self.profile setValue:self.taglineTextField.text forKey:@"tagline"];
    } else {
        // Create a new managed object
        NSManagedObject *newProfile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context];
        [newProfile setValue:self.nameTextField.text forKey:@"name"];
        [newProfile setValue:self.taglineTextField.text forKey:@"tagline"];
        
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
