//
//  HelpViewController.m
//  Music Project
//
//  Created by John Ruller on 2013-11-21.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import "HelpViewController.h"
#import "ViewHelpFileViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
{
    NSArray *helpFiles;
    NSArray *helpContent;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //initialize table data
    //helpFiles = [NSArray arrayWithObjects:@"Profile Data", @"Audio Streaming", nil];
    
    // Find out the path of recipes.plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"helpfiles" ofType:@"plist"];
    
    // Load the file content and read the data into arrays
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    helpFiles = [dict objectForKey:@"Topic"];
    helpContent = [dict objectForKey:@"File"];

    
    
    //setup table
    [_helpfilesTable setDelegate:self];
    [_helpfilesTable setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"HelpSegue"]) {
        
        NSString *helpIndex = [helpContent objectAtIndex:[[_helpfilesTable indexPathForSelectedRow] row]];
            
        //send index over to next view controller
        ViewHelpFileViewController *destViewController = segue.destinationViewController;
        destViewController.helpIndex = helpIndex;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [helpFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewCellIdentifier"];

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewCellIdentifier"];
    }
    
    cell.textLabel.text = [helpFiles objectAtIndex:indexPath.row];
    return cell;
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
