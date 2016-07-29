//
//  ScheduleTableViewCell.m
//  MisterPop
//
//  Created by Pablo on 7/25/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import "ScheduleTableViewCell.h"

@implementation ScheduleTableViewCell

@synthesize name;
@synthesize days;
@synthesize time;
@synthesize start;

//------------------------------------------------------------------------------

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        
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

- (void) updateCell:(RadioShow*) show isCurrent:(Boolean) isCurrent
{
    UIColor *normalColor = [UIColor whiteColor];
    UIColor *liveColor = [UIColor redColor];
    UIFont *font = [UIFont systemFontOfSize:10 weight:10];
    NSDictionary *normalAttributes = @{ NSForegroundColorAttributeName:normalColor};
    NSDictionary *liveAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:liveColor};
    
    NSAttributedString *normalText = [[NSAttributedString alloc] initWithString:[show name] attributes:normalAttributes];
   
    NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:normalText];
    
    RELEASE_SAFE(normalText);
    
    if(isCurrent)
    {
         NSAttributedString *highlightedText = [[NSAttributedString alloc] initWithString:@"  LIVE" attributes:liveAttributes];
        [finalAttributedString appendAttributedString:highlightedText];
        RELEASE_SAFE(highlightedText);
        [start setTextColor:liveColor];
    }
    [name setAttributedText:finalAttributedString];
    RELEASE_SAFE(finalAttributedString);
    [days setText:[show days]];
    [time setText:[show time]];
    [start setText:[NSString stringWithFormat:@"%d:00", [show start]]];
}

@end
