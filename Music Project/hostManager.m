//
//  myManager.m
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "hostManager.h"

@implementation hostManager

@synthesize someProperty;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static hostManager *sharedHostManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHostManager = [[self alloc] init];
    });
    return sharedHostManager;
}

- (id)init {
    if (self = [super init]) {
        isHost = [[NSString alloc] init];
        isHost = @"NO";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end