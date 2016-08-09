//
//  SplashVC.m
//  MisterPop
//
//  Created by Pablo on 7/26/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import "SplashVC.h"
#import "Controller.h"
#import "PlayerVC.h"

@interface SplashVC ()


@end

@implementation SplashVC

MPMoviePlayerController * moviePlayer;

@synthesize playerView;
@synthesize videoDidFinish;
@synthesize downloadDidFinish;
@synthesize downloadingLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    videoDidFinish = FALSE;
    downloadDidFinish = FALSE;
    
    [[self navigationController] setNavigationBarHidden:TRUE];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[Controller getInstance] getRadioSchedule];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [[Controller getInstance] cacheImages];
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    downloadDidFinish = TRUE;
                    [self shouldGoToNextVC];
                });
            });
        });
    });
}

- (void) viewDidAppear:(BOOL)animated
{
    [self playVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) playVideo
{
    NSURL*theurl=[[NSBundle mainBundle] URLForResource:@"splash" withExtension:@"mp4"];
    
    moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:theurl];
    moviePlayer.controlStyle = MPMovieControlStyleNone;

    [moviePlayer.view setFrame:CGRectMake(0, 0, playerView.frame.size.width, playerView.frame.size.height)];
    [moviePlayer setScalingMode:MPMovieScalingModeFill];
    
    [moviePlayer setShouldAutoplay:TRUE];
    [self.view addSubview:moviePlayer.view];
    [moviePlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    
}


- (void) moviePlayerDidFinish:(id) player
{
    NSLog(@"finish");
    videoDidFinish = TRUE;
    [downloadingLabel setHidden:FALSE];
    [self performSelector:@selector(shouldGoToNextVC) withObject:nil afterDelay:1];
}

- (void)  shouldGoToNextVC
{
    if(videoDidFinish && downloadDidFinish)
    {
        PlayerVC * nextVC = [[PlayerVC alloc] initWithNibName:@"PlayerVC" bundle:nil];
        [[self navigationController] pushViewController:nextVC animated:TRUE];
        RELEASE_SAFE(nextVC);
        RELEASE_SAFE(moviePlayer);
    }
}

@end
