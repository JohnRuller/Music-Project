//
//  profileManager.m
//  Music Project
//
//  Created by John Ruller on 2014-03-03.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "profileManager.h"

@implementation profileManager

@synthesize name;
@synthesize tagline;
@synthesize profilePhoto;
@synthesize artistsArray;
@synthesize profiles;

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

-(void)fetchArray
{
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Profile"];
    profiles = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

- (id)init {
    if (self = [super init]) {
        
        //inits
        name = [[NSString alloc] init];
        tagline = [[NSString alloc] init];
        profilePhoto = [[NSData alloc] init];
        artistsArray = [[NSArray alloc] init];
        profiles = [[NSMutableArray alloc] init];
        
        //get artists from local device
        [self setupArtistsArray];
        
        //set default profile data if none already exists
        if (![self hasProfileData]) {
            
            NSLog(@"Creating a default profile for user.");
            
            //setup default image
            UIImage *defaultImage = [UIImage imageNamed:@"defaultProfile.png"];
            
            // Create a new managed object
            NSManagedObjectContext *context = [self managedObjectContext];
            [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context];
            
            //using setters
            [self setName:[UIDevice currentDevice].name];
            [self setTagline:@"Music is cool!"];
            NSData *imageData = UIImagePNGRepresentation(defaultImage);
            [self setProfilePhoto:imageData];
            
            [self saveData];
            
            //manual setting
            //[newProfile setValue:[UIDevice currentDevice].name forKey:@"name"];
            //[newProfile setValue:@"I like music!" forKey:@"tagline"];
            //[newProfile setValue:imageData forKey:@"photo"];
            
        }
        
        else {
            
            NSLog(@"Update existing profile data.");
            
            //update profiles
            [self fetchArray];
            
            //get existing profile
            NSManagedObject *profile = [self.profiles objectAtIndex:0];
            
            //set class variables equal to existing profile data
            name = [profile valueForKey:@"name"];
            tagline = [profile valueForKey:@"tagline"];
            profilePhoto = [profile valueForKey:@"photo"];
            
            /*
             [self setName:[profile valueForKey:@"name"]];
             [self setTagline:[profile valueForKey:@"tagline"]];
             [self setProfilePhoto:[profile valueForKey:@"photo"]];
             */
            
        }
        
        
    }
    return self;
}

#pragma mark - Helpers

-(bool) hasProfileData {
    
    //update profiles
    [self fetchArray];
    
    if([profiles count] != 0)
    {
        return YES;
        
    }
    else {
        return NO;
    }
}

-(void) saveData {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

#pragma mark - Getters

-(NSString*)name {
    
    return name;
}

-(NSString*)tagline {
    return tagline;
}

-(NSData*)profilePhoto {
    return profilePhoto;
}

#pragma mark - Setters

-(void) setName:(NSString *)newName {
    
    name = newName;
    
    //update profiles
    [self fetchArray];
    
    if([profiles count] != 0) {
        
        NSManagedObject *profile = [self.profiles objectAtIndex:0];
        [profile setValue:name forKey:@"name"];
        [self saveData];
    }
}

-(void) setTagline:(NSString *)newTagline {
    
    tagline = newTagline;
    
    //update profiles
    [self fetchArray];
    
    if([profiles count] != 0) {
        
        NSManagedObject *profile = [self.profiles objectAtIndex:0];
        [profile setValue:tagline forKey:@"tagline"];
        [self saveData];
        
    }
    
}
-(void) setProfilePhoto:(NSData *)imageData {
    
    profilePhoto = imageData;
    
    //update profiles
    [self fetchArray];
    
    if([profiles count] != 0) {
        
        NSManagedObject *profile = [self.profiles objectAtIndex:0];
        [profile setValue:imageData forKey:@"photo"];
        [self saveData];
        
    }
    
}

#pragma mark - Artist array functions

-(NSArray*)artistsArray {
    
    [self setupArtistsArray];
    
    return artistsArray;
}

-(void) setArtistsArray:(NSArray *)newArtistsArray {
    
    //don't acutally ever want to manually set the artists array
    
}

-(void) setupArtistsArray {
    
    //artists table stuff
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    artistsArray = artistsQuery.collections;
    
    [self artistsArrayToString];
    
    //check how big array is
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:[artistsArray copy]];
    NSLog(@"The size of the archived artists array is %lu.", (unsigned long)[dataToSend length]);
    
    /*if([artistsArray count] == 0) {
     NSMutableArray *emptyArtists = [[NSMutableArray alloc] init];
     [emptyArtists addObject:@"There are no artists on this device"];
     artistsArray = emptyArtists;
     }*/
    
}

-(void) artistsArrayToString {
    
    NSMutableArray *stringArtistsArray = [[NSMutableArray alloc] init];
    
    //convert from mpmediaitem to string
    for(int i=0; i<[artistsArray count]; i++)
    {
        MPMediaItemCollection *artistCollection = artistsArray[i];
        NSString *artistTitle = [[artistCollection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        [stringArtistsArray addObject:artistTitle];
    }
    
    if([stringArtistsArray count] == 0) {
        NSLog(@"Artist array is empty.");
        [stringArtistsArray addObject:@"No artists on user's device."];

    }
    
    artistsArray = stringArtistsArray;

    
}

-(NSArray*)getMatchingArtists:(NSArray *)guestArtists {
    NSMutableArray *matchingArtists = [[NSMutableArray alloc] init];

    //find matching artists
    for(int i=0; i<[artistsArray count]; i++)
    {
        NSString *artistTitle = artistsArray[i];
        
        for(int j=0; j<[guestArtists count]; j++)
        {
            NSString *guestArtistTitle = guestArtists[j];
            
            if([artistTitle isEqualToString:guestArtistTitle]) {
                
                [matchingArtists addObject:artistTitle];
                
            }
        }
    }
    
    
    
    return matchingArtists;
}

-(NSArray*)getUpdatedGuestArtists:(NSArray *)guestArtists {
    NSMutableArray *updatedGuestArtists = [[NSMutableArray alloc] init];

    NSString *isMatching;
    
    //find matching artists
    for(int i=0; i<[guestArtists count]; i++)
    {
        NSString *guestArtistTitle = guestArtists[i];
        NSDictionary *artistAtIndex = [[NSDictionary alloc] init];

        
        for(int j=0; j<[artistsArray count]; j++)
        {
            
            NSString *artistTitle = artistsArray[j];
            
            if([artistTitle isEqualToString:guestArtistTitle]) {
                
                isMatching = @"YES";
                //artistAtIndex = [NSDictionary dictionaryWithObjectsAndKeys:guestArtistTitle, @"artist", @"YES", @"isMatching", nil];
            }
            else {
                isMatching = @"NO";
                //artistAtIndex = [NSDictionary dictionaryWithObjectsAndKeys:guestArtistTitle, @"artist", @"NO", @"isMatching", nil];

            }
            
            
        }
        
        NSLog(@"Adding guest artist.");
        artistAtIndex = [NSDictionary dictionaryWithObjectsAndKeys:guestArtistTitle, @"artist", isMatching, @"isMatching", nil];
        
        [updatedGuestArtists addObject:artistAtIndex];
    }
    
    return updatedGuestArtists;
}

-(NSDictionary*)getArtistsDictionary:(NSArray *)guestArtists {
    
    NSLog(@"Getting compatability dictionary.");

    //setup
    NSDictionary *compatabilityDictionary = [[NSDictionary alloc] init];
    NSArray *matchingArtists = [self getMatchingArtists:guestArtists];
    
    //refresh artists
    [self setupArtistsArray];
    
  
    
    //determine percentage
    float percentage = 0;
    float numMatchingArtists = [matchingArtists count];
    
    percentage = numMatchingArtists/[artistsArray count];
    
    NSLog(@"numMatchingArtists = %f", numMatchingArtists);
    NSLog(@"percentage = %f", percentage);
    
    //set compatability ratings
    NSString *compatabilityRating = [[NSString alloc] init];
    UIImage *compBar = [[UIImage alloc] init];
    
    if(percentage > 0 && percentage <= .33) {
       compatabilityRating = @"Low compatability";
        compBar = [UIImage imageNamed:@"LowComp.png"];
    }
    else if(percentage > .33 && percentage <= .66) {
        compatabilityRating = @"Medium compatability";
        compBar = [UIImage imageNamed:@"MediumComp.png"];
    }
    else if(percentage > .66 && percentage <= 1.00) {
        compatabilityRating = @"High compatability";
        compBar = [UIImage imageNamed:@"HighComp.png"];
    }
    else if (percentage == 0) {
        compatabilityRating = @"No matching artists";
        compBar = [UIImage imageNamed:@"NoComp.png"];
    }
    else {
        compatabilityRating = @"Rating could not be determined";
        compBar = [UIImage imageNamed:@"NoComp.png"];
    }
    
    //set dictionary values
    compatabilityDictionary = [NSDictionary dictionaryWithObjectsAndKeys: matchingArtists, @"artists", compatabilityRating, @"rating", compBar, @"compBar", nil];
    
    return compatabilityDictionary;
}

@end