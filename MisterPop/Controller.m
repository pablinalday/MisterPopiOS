
#import "Controller.h"

@interface Controller ()

@end

@implementation Controller

static Controller *sharedInstance = nil;

@synthesize imagesArray;
@synthesize schedule;
@synthesize currentShow;

-(id) init
{
    imagesArray = [[NSMutableArray alloc] init];
    schedule = [[NSMutableArray alloc] init];
    
    return [super init];
}

+ (Controller*) getInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[Controller alloc] init];
    });
    
    return sharedInstance;
}

+ (id) alloc
{
    @synchronized([Controller class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}

- (void) getRadioSchedule
{
    NSError* error = nil;
    
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[[[NSURL alloc] initWithString:MISTER_POP_SCHEDULE_URL] autorelease] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    
    NSData* jsonData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:&error];
    
    if(jsonData == nil || error != nil)
    {
        return;
    }
    
    NSError *jsonError;
    if(jsonData != nil)
    {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
        
        schedule = [[self parseRadioSchedule:jsonResult] retain];
    }
}


- (NSMutableArray *) parseRadioSchedule:(NSDictionary *) dict
{
    NSMutableArray * scheduleArray = [[NSMutableArray alloc] init];
    
    NSDictionary * items = [dict objectForKey:@"schedule"];
    for (NSDictionary * shows in items)
    {
        RadioShow * show = [[RadioShow alloc] init];
        [show setName:[shows objectForKey:@"nombre"]];
        [show setDays:[shows objectForKey:@"dias"]];
        [show setTime:[shows objectForKey:@"horario"]];
        [show setStart:[[shows objectForKey:@"comienzo"] intValue]];
        [show setEnd:[[shows objectForKey:@"final"] intValue]];
        
        [scheduleArray addObject:show];
        
        RELEASE_SAFE(show);
    }
    
    NSLog(@"%d", [self getCurrentHour]);
    return [scheduleArray autorelease];
}


- (void) getBackgroundImages
{
    NSError* error = nil;
    
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[[[NSURL alloc] initWithString:MISTER_POP_BACKGROUND_IMG_URL] autorelease] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    
    NSData* jsonData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:&error];
    
    if(jsonData == nil || error != nil)
    {
        return;
    }
    
    NSError *jsonError;
    if(jsonData != nil)
    {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
        
        NSDictionary * items = [jsonResult objectForKey:@"images"];
        int i = 0;
        for (NSDictionary * images in items)
        {
            NSString * imageName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.%@", i++, [[images objectForKey:@"path"] pathExtension]]];
            
            if(![[NSFileManager defaultManager] fileExistsAtPath:imageName])
            {
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[images objectForKey:@"path"]]];
                [data writeToFile:imageName atomically:TRUE];
            }
        }
        [self loadImages];
    }
}

- (void) loadImages {
    imagesArray = [[NSMutableArray alloc] init];
    for(int i=0; i<5; i++)
    {
        NSString * imageName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.%@", i, @"jpg"]];
        
        UIImage * result = [UIImage imageWithContentsOfFile:imageName];
        [imagesArray addObject:result];
    }
}

- (Boolean) isDayOfTheWeek
{
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    int day = CFAbsoluteTimeGetDayOfWeek(at, tz);
    return  (day > 0 && day < 6);
}

- (int) getCurrentHour
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    return (int)[components hour];
}

- (void) updateCurrentRadioShow
{
    int hour = [self getCurrentHour];
    for (RadioShow * show in schedule) {
        if(hour >= [show start] && hour < [show end])
        {
            [self setCurrentShow:show];
            break;
        }
    }
}

@end
