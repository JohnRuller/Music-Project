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
        
        [self setupArtistsArray];
        
        //set default profile data is none already exists
        if (![self hasProfileData]) {
            
            NSLog(@"Creating a default profile for user");
            
            //setup default image
            UIImage *defaultImage = [UIImage imageNamed:@"defaultProfile.png"];
            
            // Create a new managed object
            NSManagedObjectContext *context = [self managedObjectContext];
            [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context];
            
            //using setters
            [self setName:[UIDevice currentDevice].name];
            [self setTagline:@"Music is cool!"];
            [self setProfilePhoto:defaultImage];
            
            [self saveData];
            
            //manual setting
            //[newProfile setValue:[UIDevice currentDevice].name forKey:@"name"];
            //[newProfile setValue:@"I like music!" forKey:@"tagline"];
            //[newProfile setValue:imageData forKey:@"photo"];
            
            }
        
        else {
            
            NSLog(@"Update existing profile data");
            
            //update profiles
            [self fetchArray];
            
            NSManagedObject *profile = [self.profiles objectAtIndex:0];
           
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

-(NSString*)name {
    
    return name;
}

-(NSString*)tagline {
    return tagline;
}

-(NSData*)profilePhoto {
    return profilePhoto;
}

-(NSArray*)artistsArray {
    return artistsArray;
}

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
-(void) setProfilePhoto:(UIImage *)newProfilePhoto {
    
    NSData *imageData = UIImagePNGRepresentation(newProfilePhoto);
    profilePhoto = imageData;
    
    //update profiles
    [self fetchArray];
    
    if([profiles count] != 0) {
        
        NSManagedObject *profile = [self.profiles objectAtIndex:0];
        [profile setValue:imageData forKey:@"photo"];
        [self saveData];

    }
    
}

-(NSDictionary*)getProfileDictionary {
    NSDictionary *nsd = [[NSDictionary alloc] init];
    return nsd;
}

-(void) saveData {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

#pragma mark - Artist array functions

-(void) setArtistsArray:(NSArray *)newArtistsArray {
    
    //don't acutally ever want to manually set the artists array
    
}

-(void) setupArtistsArray {
    
    //artists table stuff
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    artistsArray = artistsQuery.collections;
    
    /*if([artistsArray count] == 0) {
        NSMutableArray *emptyArtists = [[NSMutableArray alloc] init];
        [emptyArtists addObject:@"There are no artists on this device"];
        artistsArray = emptyArtists;
    }*/
    
}

-(int) getCompatabilityInt:(NSArray *)guestArtists {
    
    int count = 0;
    
    [self setupArtistsArray];
    
    for(int i=0; i<[artistsArray count]; i++)
    {
        for(int j=0; j<[guestArtists count]; j++)
        {
            if([[artistsArray objectAtIndex:i] isEqualToString:[guestArtists objectAtIndex:j]]) {
                count++;
            }
            
        }
    }
    
    NSLog(@"artists count = %d", count);
    return count;
}

-(NSString *) getCompatabilityRating:(NSArray *)guestArtists {
    
    float percentage = 0;
    int matchingArtists = [self getCompatabilityInt:guestArtists];
    int totalArtists = [artistsArray count] + [guestArtists count] - matchingArtists;
    
    percentage = matchingArtists/totalArtists;
    
    if(percentage >= 0 && percentage <= .25)
        return @"Low compatability";
    return @"test";
}

@end
