//
//  RadioShow.m
//  MisterPop
//
//  Created by Pablo on 7/26/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import "RadioShow.h"

@implementation RadioShow

@synthesize name;
@synthesize days;
@synthesize time;
@synthesize start;
@synthesize end;
@synthesize daysArray;

- (void) fillShowDays:(NSString*) daysString
{
    daysArray = [[NSArray alloc] initWithArray:[daysString componentsSeparatedByString:@", "]];
}

- (void) dealloc
{
    RELEASE_SAFE(daysArray);
    [super dealloc];
}

@end
