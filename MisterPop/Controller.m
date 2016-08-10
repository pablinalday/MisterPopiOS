
#import "Controller.h"

@interface Controller ()

@end

@implementation Controller

static Controller *sharedInstance = nil;

@synthesize imagesArray;
@synthesize schedule;
@synthesize currentShow;
@synthesize shouldLoadNewImages;

-(id) init
{
    imagesArray = [[NSMutableArray alloc] init];
    schedule = [[NSMutableArray alloc] init];
    
    return [super init];
}

- (void) dealloc
{
    RELEASE_SAFE(imagesArray);
    RELEASE_SAFE(schedule);
    RELEASE_SAFE(sharedInstance);
    [super dealloc];
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
        [show fillShowDays:[shows objectForKey:@"detalle_dias"]];
        
        [scheduleArray addObject:show];
        
        RELEASE_SAFE(show);
    }
    
    return [scheduleArray autorelease];
}

- (void) setBackgroundImagesVersion:(int) version
{
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"background_version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int) getBackgroundImagesVersion
{
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"background_version"];
}

- (void) cacheImages
{
    // si no tengo imagenes, van las default y bajo las que hay y aparecen la proxima vez que inicia la app
    // si no hay conexion, van las default
    // si tengo, chequeo la version
    // si es menos o igual, van las que estan en cache
    // si es mayor, van las que estan en cache y descargo las nuevas y aparecen la proxima vez que inicia la app
    
    shouldLoadNewImages = FALSE;
    [self loadDefaultImages];
    if(![self checkLocalImages]) {
        //TODO: sacar esto cuando esten las imagenes nuevas
        shouldLoadNewImages = TRUE;
    } else {
        [self setShouldLoadNewImages];
    }
}

- (void) setShouldLoadNewImages
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
        
        int version = [[jsonResult objectForKey:@"version"] intValue];
        if(version <= [self getBackgroundImagesVersion])
        {
            shouldLoadNewImages = FALSE;
            [self loadLocalImages];
        } else {
            shouldLoadNewImages = TRUE;
            [self setBackgroundImagesVersion:version];
        }
    }

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
        
        [self saveImagesToCache:jsonResult];
    }
}

- (void) saveImagesToCache:(NSDictionary *) dict
{
    NSDictionary * items = [dict objectForKey:@"images"];
    int i = 1;
    for (NSDictionary * images in items)
    {
        NSString * imageName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.%@", i++, [[images objectForKey:@"path"] pathExtension]]];
        
        NSLog(@"%@", imageName);
        
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[images objectForKey:@"path"]]];
        [data writeToFile:imageName atomically:TRUE];
    }

}

- (Boolean) checkLocalImages
{
    for(int i=1; i<=10; i++)
    {
        NSString * localImageName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.png", i++]];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:localImageName])
        {
            return FALSE;
        }
    }
    
    return TRUE;
}

- (void) loadLocalImages
{
    RELEASE_SAFE(imagesArray);
    imagesArray = [[NSMutableArray alloc] init];
    for(int i=1; i<=10; i++)
    {
        NSString * imageName = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.%@", i, @"png"]];
        
        UIImage * result = [UIImage imageWithContentsOfFile:imageName];
        [imagesArray addObject:result];
    }
}

- (int) getDayOfTheWeek
{
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    int day = (int)CFAbsoluteTimeGetDayOfWeek(at, tz);
    if(day == 7)
    {
        return 1;
    }
    
    return day+1;
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
    Boolean match = FALSE;
    int hour = [self getCurrentHour];
    int day = [self getDayOfTheWeek];
    
    //falta chequear que pasa si el final es mas chico que el comienzo end < start
    
    for (RadioShow * show in schedule) {
        if(hour >= [show start] && hour < [show end])
        {
            NSString *showDay = [NSString stringWithFormat:@"%d", day];
            if([[show daysArray] containsObject:showDay])
            {
                [self setCurrentShow:show];
                match = TRUE;
                break;
            }
        }
        
        if([show end] < [show start])
        {
            NSString *showDay = [NSString stringWithFormat:@"%d", day];
            if((hour >= [show start] && hour <= 24 && [[show daysArray] containsObject:showDay]) || (hour >= 0 && hour < [show end] && ([[show daysArray] containsObject:showDay])))
            {
                [self setCurrentShow:show];
                match = TRUE;
                break;
            }
        }
    }
    
    if(!match)
    {
        RadioShow * show = [[RadioShow alloc] init];
        [show setName:@"MisterPop"];
        [self setCurrentShow:show];
        RELEASE_SAFE(show);
    }
}

- (void)loadDefaultImages
{
    RELEASE_SAFE(imagesArray);
    imagesArray = [[NSMutableArray alloc] init];
    for (int index = 1; index <= 10; index++)
    {
        NSString *imageName = [NSString stringWithFormat:@"def_background_%d", index];
        
        UIImage *image = [UIImage imageNamed:imageName];
        
        [imagesArray addObject:image];
    }
}


@end
