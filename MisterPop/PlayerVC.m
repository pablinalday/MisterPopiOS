//
//  PlayerVC.m
//  MisterPop
//
//  Created by Pablo on 7/13/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import "PlayerVC.h"
#import "ScheduleTableViewCell.h"



@interface PlayerVC ()

@end

@implementation PlayerVC

@synthesize backgroundIV;
@synthesize streamer;
@synthesize playbackStatusLbl;
@synthesize playbackBtn;
@synthesize rcc;
@synthesize scheduleView;
@synthesize scheduleButton;
@synthesize closeButton;
@synthesize scheduleMaskView;
@synthesize currentShow;
@synthesize scheduleTV;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [backgroundIV setAnimationImages:[[Controller getInstance] imagesArray]];
    [backgroundIV setAnimationDuration:15];
    [backgroundIV setAnimationRepeatCount:0];
    [backgroundIV startAnimating];
    
    [[self navigationController] setNavigationBarHidden:TRUE];
    
    [playbackBtn addTarget:self action:@selector(playStreamer) forControlEvents:UIControlEventTouchUpInside];
    
    [self createStreamer];
    
    rcc = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPRemoteCommand *playCommand = [rcc playCommand];
    [playCommand setEnabled:YES];
    [playCommand addTarget:self action:@selector(playStreamer)];
    
    MPRemoteCommand *pauseCommand = [rcc pauseCommand];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTarget:self action:@selector(stopStreamer)];
    
    MPRemoteCommand *ffCommand = [rcc seekForwardCommand];
    [ffCommand setEnabled:NO];

    MPRemoteCommand *rwCommand = [rcc seekBackwardCommand];
    [rwCommand setEnabled:NO];
    
    [playbackStatusLbl setText:@"STOPPED"];
    
    [scheduleButton addTarget:self action:@selector(showSchedule) forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton addTarget:self action:@selector(hideSchedule) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateCurrentShow];
    
    if([[Controller getInstance] shouldLoadNewImages])
    {
        [self downloadNewBackgrounds];
    }
    
    [self playStreamer];
    
}

- (void) showSchedule
{
    [self updateCurrentShow];
    [scheduleTV reloadData];
    [UIView transitionWithView:scheduleView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [scheduleView setHidden:FALSE];
        [scheduleMaskView setHidden:FALSE];
    }  completion:nil];
}


- (void) hideSchedule
{
    [self updateCurrentShow];
    [UIView transitionWithView:scheduleView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [scheduleView setHidden:TRUE];
        [scheduleMaskView setHidden:TRUE];
    }  completion:nil];
}

- (void) createStreamer
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
    
    if (streamer)
    {
        [streamer stop];
        [streamer release];
        streamer = nil;
    }
    
    NSString *escapedValue = [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                         nil,
                                                         (CFStringRef)@"http://cdn.instream.audio:8150/",
                                                         NULL,
                                                         NULL,
                                                         kCFStringEncodingUTF8)
                              autorelease];
    
    NSURL *url = [NSURL URLWithString:escapedValue];
    streamer = [[AudioStreamer alloc] initWithURL:url];
    [streamer setShouldDisplayAlertOnError:TRUE];
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
    if ([streamer isWaiting])
    {
        [playbackStatusLbl setText:@"BUFFERING ..."];
    }
    else if ([streamer isPlaying])
    {
        [playbackStatusLbl setText:@"PLAYING"];
        [self updateCurrentShow];
    }
    else if ([streamer isPaused])
    {
        [playbackStatusLbl setText:@"PAUSED"];
    }
    else if ([streamer isIdle])
    {
        [self stopStreamer];
        [self destroyStreamer];
        [playbackStatusLbl setText:@"STOPPED"];
        [self updateCurrentShow];
    }
}

- (void)destroyStreamer
{
    if (streamer)
    {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
        
        [streamer stop];
        RELEASE_SAFE(streamer);
    }
}

- (void) playStreamer
{
    if(!streamer)
    {
        [self createStreamer];
    }
    [streamer start];
    [playbackBtn addTarget:self action:@selector(stopStreamer) forControlEvents:UIControlEventTouchUpInside];
    [playbackBtn setBackgroundImage:[UIImage imageNamed:@"pause_btn"] forState:UIControlStateNormal];
    [rcc togglePlayPauseCommand];
}

- (void) stopStreamer
{
    [streamer stop];
    [playbackBtn addTarget:self action:@selector(playStreamer) forControlEvents:UIControlEventTouchUpInside];
    [playbackBtn setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [rcc togglePlayPauseCommand];
}

- (void) updateCurrentShow
{
    [[Controller getInstance] updateCurrentRadioShow];
    [currentShow setText:[[[Controller getInstance] currentShow] name]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSArray *)createImagesArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger index = 1; index <= 4; index++)
    {
        NSString *imageName = [NSString stringWithFormat:@"image%ld.jpeg", (long)index];
    
        UIImage *image = [UIImage imageNamed:imageName];
        
        [array addObject:image];
    }
    
    return array;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioShow * show = [[[Controller getInstance] schedule] objectAtIndex:[indexPath row]];
    ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
    
    if (cell == nil)
    {
        if([[show name] containsString:@"\n"])
        cell = [[ScheduleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ScheduleTableViewCellLarge"];
        else
            cell = [[ScheduleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ScheduleTableViewCell"];
    }
    
    
    [cell updateCell:show isCurrent:[[show name] isEqualToString:[[[Controller getInstance] currentShow] name]] && [[show time] isEqualToString:[[[Controller getInstance] currentShow] time]] && [[show days] isEqualToString:[[[Controller getInstance] currentShow] days]]];
    

    return cell;
}

//------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[Controller getInstance] schedule] count];
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadioShow * show = [[[Controller getInstance] schedule] objectAtIndex:[indexPath row]];
    if([[show name] containsString:@"\n"])
        return 75.0;
    else
        return 60.0;
}

//------------------------------------------------------------------------------


- (void)dealloc
{
    [self destroyStreamer];
    [super dealloc];
}

- (void) downloadNewBackgrounds
{
    dispatch_async( dispatch_get_main_queue(), ^{
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[Controller getInstance] getBackgroundImages];
            NSLog(@"downloading images");
            
            dispatch_async( dispatch_get_main_queue(), ^{
                [[Controller getInstance] loadLocalImages];
                [backgroundIV setAnimationImages:[[Controller getInstance] imagesArray]];
                [backgroundIV setAnimationDuration:5];
                [backgroundIV setAnimationRepeatCount:0];
                [backgroundIV startAnimating];
                NSLog(@"done");
            });
        });
    });
}

@end
