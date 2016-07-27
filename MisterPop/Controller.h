
#import <UIKit/UIKit.h>
#import "RadioShow.h"

#define MISTER_POP_SCHEDULE_URL         @"http://www.misterpop.fm/appdata/schedule.json"
#define MISTER_POP_BACKGROUND_IMG_URL   @"http://www.misterpop.fm/appdata/background_images.json"

@interface Controller : NSObject

+ (Controller*) getInstance;

- (void) getRadioSchedule;
- (void) getBackgroundImages;
- (void) updateCurrentRadioShow;

@property (nonatomic, retain) NSMutableArray *imagesArray;
@property (nonatomic, retain) NSMutableArray *schedule;
@property (nonatomic, retain) RadioShow *currentShow;

@end
