//
//  ScheduleTableViewCell.m
//  MisterPop
//
//  Created by Pablo on 7/25/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import "ScheduleTableViewCell.h"

@implementation ScheduleTableViewCell

//------------------------------------------------------------------------------

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ScheduleTableViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UITableViewCell class]])
        {
            return nil;
        }
        
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}


@end
