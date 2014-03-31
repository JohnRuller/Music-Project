//
//  ViewGuestProfileViewController.m
//  Music Project
//
//  Created by John Ruller on 2014-03-16.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "ViewGuestProfileViewController.h"
#import "profileManager.h"
#import "MatchingArtistsViewController.h"


@interface ViewGuestProfileViewController ()



@end

@implementation ViewGuestProfileViewController

//local vars
profileManager *userProfile;
NSArray *guestArtists;
NSArray *matchingArtists;

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
    
    //init
    userProfile = [[profileManager alloc] init];

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
    
    //set compatability
    [_compLabel setText:[guestDictionary objectForKey:@"rating"]];
    _compImageView.image = [guestDictionary objectForKey:@"compBarImage"];
    
    guestArtists = [[NSArray alloc] init];
    guestArtists = [userProfile getUpdatedGuestArtists:[guestDictionary objectForKey:@"artists"]];
    //guestArtists = [guestDictionary objectForKey:@"artists"];
    NSLog(@"Guest Artists array count in gues profile view: %lu", (unsigned long)[guestArtists count]);
    
    matchingArtists = [userProfile getMatchingArtists:[guestDictionary objectForKey:@"artists"]];
    [_matchingLabel setText:[NSString stringWithFormat:@"You have %lu matching artists.", (unsigned long)[matchingArtists count]]];
    
    //setup table
    [self.artistTableView setDelegate:self];
    [self.artistTableView setDataSource:self];
    [self.artistTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ViewMatchingArtists"]) {
        

            
        //send guest profile data over to next view controller
        MatchingArtistsViewController *destViewController = segue.destinationViewController;
        destViewController.matchingArtists = matchingArtists;
        
    }
}

#pragma mark - Artists

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [guestArtists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistsCell"];
    
    NSString *artistTitle = [guestArtists[indexPath.row] objectForKey:@"artist"];
    NSString *isMatching = [guestArtists[indexPath.row] objectForKey:@"isMatching"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ArtistsCell"];
    }
    
    //[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    
    cell.textLabel.text = artistTitle;
    
    /*
    if([isMatching isEqualToString:@"YES"]) {
        NSLog(@"HIGHLIGHT ROW.");

        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor greenColor];
        bgColorView.layer.cornerRadius = 7;
        bgColorView.layer.masksToBounds = YES;
        [cell setBackgroundView:bgColorView];

    }*/

    return cell;
}
@end
