//
//  ProfileViewController.m
//  Music Project
//
//  Created by John Ruller on 2013-11-21.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import "ProfileViewController.h"
#import "EditProfileViewController.h"
#import "profileManager.h"
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPMediaItemCollection.h>

@interface ProfileViewController ()

@end

@implementation ProfileViewController

profileManager *userProfile;

//labels
@synthesize nameLabel;
@synthesize taglineLabel;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //try to fix the nav bar height: http://stackoverflow.com/questions/18737186/position-of-navigation-bar-for-modal-view-ios7
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        self.navBar.frame = CGRectMake(self.navBar.frame.origin.x, self.navBar.frame.origin.y, self.navBar.frame.size.width, 64);
    }
    
    //labels
    nameLabel.text = [NSString stringWithFormat:@"%@",userProfile.name];
    taglineLabel.text = [NSString stringWithFormat:@"%@",userProfile.tagline];
    
    //image
    UIImage *image = [UIImage imageWithData:userProfile.profilePhoto];
    self.imageView.image = image;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    userProfile = [[profileManager alloc] init];
    
    //labels
    nameLabel.text = [NSString stringWithFormat:@"%@",userProfile.name];
    taglineLabel.text = [NSString stringWithFormat:@"%@",userProfile.tagline];
    
    //image
    UIImage *image = [UIImage imageWithData:userProfile.profilePhoto];
    self.imageView.image = image;
    // set image layer circular
    CALayer * l = [self.imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:45.0];
    
    
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
/*
 //passing profile managedObject to edit profile view
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 
 if ([[segue identifier] isEqualToString:@"UpdateProfile"] && [self.profiles count] != 0) {
 NSManagedObject *selectedProfile = [self.profiles objectAtIndex:0];
 EditProfileViewController *destViewController = segue.destinationViewController;
 destViewController.profile = selectedProfile;
 }
 }
 */

#pragma mark - Artists

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userProfile.artistsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistsCell"];
    
    NSString *artistTitle = userProfile.artistsArray[indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ArtistsCell"];
    }
    
    cell.textLabel.text = artistTitle;
    return cell;
}


@end