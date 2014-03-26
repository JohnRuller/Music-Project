//
//  peerPlaylist.m
//  Music Project
//
//  Created by Ryan Fraser on 3/2/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "peerPlaylist.h"

@implementation peerPlaylist

- (id)init
{
    self = [super init];
    
    NSLog(@"Init Playlist");
    
    _playlistInfo = [[NSMutableArray alloc] init];
    return  self;
    
}

- (void) addSongFromHost:(MPMediaItem *)song
{
    NSDictionary *newSong = [self makeDictionaryItem:song];
    [_playlistInfo addObject:newSong];
}

- (void)addSongFromGuest:(NSDictionary *)song
{
    [_playlistInfo addObject:song];
}

- (NSDictionary *)makeDictionaryItem:(MPMediaItem *)song
{
    NSString *songNameString = [song valueForProperty:MPMediaItemPropertyTitle] ? [song valueForProperty:MPMediaItemPropertyTitle] : @"";
    NSString *artistNameString = [song valueForProperty:MPMediaItemPropertyArtist] ? [song valueForProperty:MPMediaItemPropertyArtist] : @"";
    NSString *albumNameString = [song valueForProperty:MPMediaItemPropertyAlbumTitle] ? [song valueForProperty: MPMediaItemPropertyAlbumTitle] : @"";
    
    MPMediaItemArtwork *artz = [song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *art = NULL;
    
    
/*
    
    if (artz != nil)
    {
        art = [artz imageWithSize:CGSizeMake(90.0, 90.0)];
        
//        UIGraphicsBeginImageContext(CGSizeMake(90, 90));
//        //[artz drawInRect:CGRectMake(0,0,CGSizeMake(90, 90).width,CGSizeMake(90, 90).height)];
//        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
    }
 */
    
    if (!art) {
        NSLog(@"No ALBUM ARTWORK");
        art = [UIImage imageNamed:@"penguin.png"];
    }
    
    NSNumber *nada = [[NSNumber alloc] initWithInt:0];
    NSMutableDictionary *newSong = [[NSMutableDictionary alloc] init];
    
    [newSong removeAllObjects];
    [newSong setObject:songNameString forKey:@"songTitle"];
    [newSong setObject:artistNameString forKey:@"artistName"];
    [newSong setObject:albumNameString forKey:@"albumName"];
    //another one that gets the device name
    [newSong setObject:art forKey:@"albumArt"];
    [newSong setObject:nada forKey:@"upVotes"];
    [newSong setObject:nada forKey:@"downVotes"];
    [newSong setObject:@"newSong" forKey:@"type"];
    [newSong setObject:nada forKey:@"totalVotes"];
    [newSong setObject:@"NO" forKey:@"isPlaying"];
    
    return newSong;
}

-(void)removeSong:(NSInteger)location
{
    NSLog(@"remove song at location %ld", (long)location);
    [_playlistInfo removeObjectAtIndex:location];
}

-(NSMutableArray *)getArray
{
    NSLog(@"get array");
    return _playlistInfo;
}

-(void)updatePlaylist:(NSMutableArray *)receivedPlaylist
{
    NSLog(@"guest - update playlist with new received playlist");
    _playlistInfo = [receivedPlaylist copy];
}

- (NSInteger)countOfPlaylistInfo
{
    NSLog(@"return playlist count");
    return [_playlistInfo count];
}

- (void)addUpvote:(NSInteger)location
{
    NSLog(@"add Upvote");
    NSMutableDictionary *dic = [_playlistInfo objectAtIndex:location];
    NSNumber *upVotes = [dic objectForKey:@"upVotes"];
    NSNumber *replace = [NSNumber numberWithInt:[upVotes intValue] + 1];
    
    [dic setObject:replace forKey:@"upVotes"];
    [_playlistInfo replaceObjectAtIndex:location withObject:dic];
    
    NSLog(@"Upvote Count is: %@", replace);
}

- (void)addDownvote:(NSInteger)location
{
    NSLog(@"add downVote");
    NSMutableDictionary *dic = [_playlistInfo objectAtIndex:location];
    NSNumber *downVotes = [dic objectForKey:@"downVotes"];
    NSNumber *replace = [NSNumber numberWithInt:[downVotes intValue] + 1];
    
    [dic setObject:replace forKey:@"downVotes"];
    [_playlistInfo replaceObjectAtIndex:location withObject:dic];
    
    NSLog(@"Downvote Count is: %@", replace);
}

- (NSInteger)getUpvoteCount:(NSInteger)location
{
    NSLog(@"get upvote count");
    NSMutableDictionary *dic = [_playlistInfo objectAtIndex:location];
    NSNumber *upVotes = [dic objectForKey:@"upVotes"];
    NSInteger upVotesInt = [upVotes intValue];
    NSLog(@"Upvote Count is: %ld", (long)upVotesInt);

    return upVotesInt;
}

- (NSInteger)getDownvoteCount:(NSInteger)location
{
    NSLog(@"get downvote count");
    NSMutableDictionary *dic = [_playlistInfo objectAtIndex:location];
    NSNumber *downVotes = [dic objectForKey:@"downVotes"];
    NSInteger downVotesInt = [downVotes intValue];
    NSLog(@"Downvote Count is: %ld", (long)downVotesInt);
    return downVotesInt;
}

- (void)moveSongUpOnePosition:(NSInteger)location
{
    NSLog(@"move song up one position");
    [_playlistInfo exchangeObjectAtIndex:location withObjectAtIndex:location - 1];
}

- (void)moveSongDownOnePosition:(NSInteger)location
{
    NSLog(@"move song down one position");
    [_playlistInfo exchangeObjectAtIndex:location withObjectAtIndex:location + 1];
}

-(void)moveSongToTop:(NSInteger)location
{
    NSLog(@"moveSongToTop");
    NSInteger loc = location;
    while (loc != 1)
    {
        [self moveSongUpOnePosition:loc];
        location--;
    }
    
}

-(NSString *)getSongName:(NSInteger)location
{
    NSDictionary *dic = [_playlistInfo objectAtIndex:location];
    NSString *songName = [dic objectForKey:@"songTitle"];
    
    return songName;
}

- (void)isPlayingSwap
{
    NSLog(@"isPlayingSwap");
    NSMutableDictionary *dic = [_playlistInfo objectAtIndex:0];
    NSString *isItPlaying = [dic objectForKey:@"isPlaying"];
    
    if ([isItPlaying isEqualToString:@"NO"])
    {
        [dic setObject:@"YES" forKey:@"isPlaying"];
    }
    else
    {
        [dic setObject:@"NO" forKey:@"isPlaying"];
    }
    
    [_playlistInfo replaceObjectAtIndex:0 withObject:dic];
}






-(void)playlistUpvote:(NSInteger)loc
{
    [_playlistInfo exchangeObjectAtIndex:loc withObjectAtIndex:loc-1];
    
}

-(void)playlistDownvote:(NSInteger)loc
{
    [_playlistInfo exchangeObjectAtIndex:loc withObjectAtIndex:loc+1];
}


//will return false if it did not change the song location
//will return true if it did due to being above vote total.
- (BOOL)upvoteSongAtLocation:(NSInteger)loc :(NSInteger)peerCount
{
    NSLog(@"upvoteSongAtLocation");
    NSMutableDictionary *dic = [_playlistInfo objectAtIndex:loc];
    NSNumber *upVotes = [dic objectForKey:@"upVotes"];
    NSNumber *replace = [NSNumber numberWithInt:[upVotes intValue] + 1];
    NSInteger total = [replace integerValue];
    
    NSNumber *totalVotes = [dic objectForKey:@"totalVotes"];
    NSNumber *replace2 = [NSNumber numberWithInt:[totalVotes intValue] + 1];
    
    if (peerCount > 2)
    {
        if (total >= peerCount)
        {
            [self moveSongToTop:loc];
            return true;
        }
        else
        {
            [dic setObject:replace forKey:@"upVotes"];
            [dic setObject:replace2 forKey:@"totalVotes"];
            [_playlistInfo replaceObjectAtIndex:loc withObject:dic];
            return false;
        }
    }
    else
    {
        [dic setObject:replace forKey:@"upVotes"];
        [dic setObject:replace2 forKey:@"totalVotes"];
        [_playlistInfo replaceObjectAtIndex:loc withObject:dic];
        return false;
    }
    return false;
}

//will return false if it did not change the song location
//will return true if it did due to being above vote total.
- (BOOL)downvoteSongAtLocation:(NSInteger)loc :(NSInteger)peerCount
{
    NSLog(@"downvoteSongAtLocation");
    
    NSMutableDictionary *dic = [_playlistInfo objectAtIndex:loc];
    NSNumber *downVotes = [dic objectForKey:@"downVotes"];
    NSNumber *replace = [NSNumber numberWithInt:[downVotes intValue] + 1];
    NSInteger total = [replace integerValue];
    
    NSNumber *totalVotes = [dic objectForKey:@"totalVotes"];
    NSNumber *replace2 = [NSNumber numberWithInt:[totalVotes intValue] + 1];
    
    
    if (peerCount > 2)
    {
        if (total >= peerCount)
        {
            [self removeSong:loc];
            return true;
        }
        else
        {
            [dic setObject:replace forKey:@"downVotes"];
            [dic setObject:replace2 forKey:@"totalVotes"];
            [_playlistInfo replaceObjectAtIndex:loc withObject:dic];
            return false;
        }
    }
    else
    {
        [dic setObject:replace forKey:@"downVotes"];
        [dic setObject:replace2 forKey:@"totalVotes"];
        [_playlistInfo replaceObjectAtIndex:loc withObject:dic];
        return false;
    }
    return false;
}

/*
 -(void)moveSongToTop:(NSInteger)loc
{
    NSLog(@"moveSongToTop");
    NSInteger location = loc;
    while (loc != 1)
    {
        [self playlistUpvote:location];
        location--;
    }
}
*/


@end

