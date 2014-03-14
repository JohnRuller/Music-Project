//
//  TabBarController.m
//  Music Project
//
//  Created by John Ruller on 2014-03-13.
//  Copyright (c) 2014 John Ruller. All rights reserved.
//

#import "TabBarController.h"

@implementation TabBarController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [TabBarController.viewControllers makeObjectsPerformSelector:@selector(getView)];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
