//
//  PlayerVC.h
//  MisterPop
//
//  Created by Pablo on 7/13/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@interface PlayerVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIImageView * backgroundIV;
@property (nonatomic, retain) IBOutlet UIButton * playbackBtn;
@property (nonatomic, retain) IBOutlet UILabel * playbackStatusLbl;
@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic, retain) MPRemoteCommandCenter *rcc;
@property (nonatomic, retain) IBOutlet UIView *scheduleView;
@property (nonatomic, retain) IBOutlet UIButton *scheduleButton;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

@end
