//
//  PlayerVC.m
//  MisterPop
//
//  Created by Pablo on 7/13/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import "PlayerVC.h"

#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@interface PlayerVC ()

@end

@implementation PlayerVC

@synthesize backgroundIV;
@synthesize streamer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [backgroundIV setAnimationImages:[self createImagesArray]];
    [backgroundIV setAnimationDuration:5];
    [backgroundIV setAnimationRepeatCount:0];
    [backgroundIV startAnimating];
    
    [[self navigationController] setNavigationBarHidden:TRUE];
    
    
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPRemoteCommand *pauseCommand = [rcc stopCommand];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTarget:self action:@selector(createStreamer)];
    //
    MPRemoteCommand *playCommand = [rcc playCommand];
    [playCommand setEnabled:YES];
    [playCommand addTarget:self action:@selector(createStreamer)];
}

- (void)createStreamer
{

    if (streamer)
    {
        return;
    }
    
    
    NSString *escapedValue =
    [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                         nil,
                                                         (CFStringRef)@"http://cdn.instream.audio:8150/",
                                                         NULL,
                                                         NULL,
                                                         kCFStringEncodingUTF8)
     autorelease];
    
    NSURL *url = [NSURL URLWithString:escapedValue];
    streamer = [[AudioStreamer alloc] initWithURL:url];
    
    [streamer start];
    
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
    
        // Allocating images with imageWithContentsOfFile makes images to do not cache.
        UIImage *image = [UIImage imageNamed:imageName];
        
        [array addObject:image];
    }
    
    return array;
}

@end
