//
//  ProfileTests.m
//  Music Project
//
//  Created by John Ruller on 2014-03-04.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "profileManager.h"

@interface ProfileTests : XCTestCase {
    profileManager *profile;
    
}

@end

@implementation ProfileTests

- (void)setUp
{
    profile = [[profileManager alloc] init];
}

- (void)tearDown
{
    profile = nil;
}

- (void)testThatProfileClassExists {
    XCTAssertNotNil(profile, @"should be able to create a profile instance.");
}

- (void)testThatProfileDataExists {
    bool profileData = profile.hasProfileData;
    XCTAssertTrue(profileData, @"should have profile data.");
    
}

@end
