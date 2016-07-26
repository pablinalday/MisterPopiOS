//
//  ScheduleTableViewCell.h
//  MisterPop
//
//  Created by Pablo on 7/25/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioShow.h"

@interface ScheduleTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel * name;
@property (nonatomic, retain) IBOutlet UILabel * days;
@property (nonatomic, retain) IBOutlet UILabel * time;
@property (nonatomic, retain) IBOutlet UILabel * start;

- (void) updateCell:(RadioShow*) show;

@end
