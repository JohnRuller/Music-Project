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
        profilePhoto = [[UIImage alloc] init];
        artistsArray = [[NSArray alloc] init];
        profiles = [[NSMutableArray alloc] init];
        
        //set default profile data is none already exists
        if (![self hasProfileData]) {
            
            //setup default image
            UIImage *defaultImage = [UIImage imageNamed:@"defaultProfile.png"];
            
            // Create a new managed object
            NSManagedObjectContext *context = [self managedObjectContext];
            [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context];
            
            //using setters
            [self setName:[UIDevice currentDevice].name];
            [self setTagline:@"Music is cool!"];
            [self setProfilePhoto:defaultImage];
            
            //manual setting
            //[newProfile setValue:[UIDevice currentDevice].name forKey:@"name"];
            //[newProfile setValue:@"I like music!" forKey:@"tagline"];
            //[newProfile setValue:imageData forKey:@"photo"];
            
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

-(UIImage*)profilePhoto {
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
    }
}

-(void) setTagline:(NSString *)newTagline {
    
    tagline = newTagline;
    
    //update profiles
    [self fetchArray];
    
    if([profiles count] != 0) {
        
        NSManagedObject *profile = [self.profiles objectAtIndex:0];
        [profile setValue:tagline forKey:@"tagline"];
    }
    
}
-(void) setProfilePhoto:(UIImage *)newProfilePhoto {
    
    profilePhoto = newProfilePhoto;
    
    //update profiles
    [self fetchArray];
    
    if([profiles count] != 0) {
        
        NSManagedObject *profile = [self.profiles objectAtIndex:0];
        NSData *imageData = UIImagePNGRepresentation(newProfilePhoto);
        [profile setValue:imageData forKey:@"photo"];
    }
    
}
-(void) setArtistsArray:(NSArray *)newArtistsArray {
    
    //don't acutally ever want to manually set the artists array
    
}

-(void) setupArtistsArray {
    
    //artists table stuff
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    artistsArray = artistsQuery.collections;
    
    if([artistsArray count] == 0) {
        NSMutableArray *emptyArtists = [[NSMutableArray alloc] init];
        [emptyArtists addObject:@"There are no artists on this device"];
        artistsArray = emptyArtists;
    }
    
}

-(NSDictionary*)getProfileDictionary {
    NSDictionary *nsd = [[NSDictionary alloc] init];
    return nsd;
}


@end
