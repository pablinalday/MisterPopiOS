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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [backgroundIV setAnimationImages:[[Controller getInstance] imagesArray]];
    [backgroundIV setAnimationDuration:5];
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
}

- (void) showSchedule
{
    [UIView transitionWithView:scheduleView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [scheduleView setHidden:FALSE];
    }  completion:nil];
}


- (void) hideSchedule
{
    [UIView transitionWithView:scheduleView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [scheduleView setHidden:TRUE];
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
    }
    else if ([streamer isPaused])
    {
        [playbackStatusLbl setText:@"PAUSED"];
    }
    else if ([streamer isIdle])
    {
        [self destroyStreamer];
        [playbackStatusLbl setText:@"STOPPED"];
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
    
    ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
    
    if (cell == nil)
    {
        cell = [[ScheduleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ScheduleTableViewCell"];
    }
    
    [cell updateCell:[[[Controller getInstance] schedule] objectAtIndex:[indexPath row]]];
    
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
    return 60.0;
}

//------------------------------------------------------------------------------


- (void)dealloc
{
    [self destroyStreamer];
    [super dealloc];
}

@end
