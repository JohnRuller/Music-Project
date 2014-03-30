//
//  ViewGuestProfileViewController.m
//  Music Project
//
//  Created by John Ruller on 2014-03-16.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "ViewGuestProfileViewController.h"

@interface ViewGuestProfileViewController ()



@end

@implementation ViewGuestProfileViewController

NSArray *guestArtists;

@synthesize guestDictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //labels
    _nameLabel.text = [guestDictionary objectForKey:@"name"];
    _taglineLabel.text = [guestDictionary objectForKey:@"tagline"];
    
    //image
    UIImage *image = [guestDictionary objectForKey:@"image"];
    self.profileImage.image = image;
    // set image layer circular
    CALayer * l = [self.profileImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:45.0];
    
    guestArtists = [[NSArray alloc] init];
    guestArtists = [guestDictionary objectForKey:@"artists"];
    NSLog(@"Guest Artists array count in gues profile view: %lu", (unsigned long)[guestArtists count]);
    
    //setup table
    [self.artistTableView setDelegate:self];
    [self.artistTableView setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Artists

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [guestArtists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistsCell"];
    
    NSString *artistTitle = guestArtists[indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ArtistsCell"];
    }
    
    //[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    
    cell.textLabel.text = artistTitle;
    return cell;
}
@end
