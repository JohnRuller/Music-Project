//
//  myManager.h
//  Music Project
//
//  Created by Ryan Fraser on 2/20/2014.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface hostManager : NSObject {
    NSString *isHost;
}

@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedManager;

@end