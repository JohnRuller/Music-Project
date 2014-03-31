//
//  MatchingArtistsViewController.m
//  Music Project
//
//  Created by John Ruller on 2014-03-30.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "MatchingArtistsViewController.h"
#import "profileManager.h"

@interface MatchingArtistsViewController ()

@end

@implementation MatchingArtistsViewController

@synthesize matchingArtists;




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
    
    
     if([matchingArtists count] == 0) {
         NSArray *noArtists = [[NSArray alloc] initWithObjects:@"There are no matching artists.", nil];
         matchingArtists = [noArtists copy];
     }
    
    //setup table
    [self.artistsTable setDelegate:self];
    [self.artistsTable setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - Artists

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [matchingArtists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistsCell"];
    
    NSString *artistTitle = matchingArtists[indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ArtistsCell"];
    }
    
    cell.textLabel.text = artistTitle;
    
    return cell;
}

@end
