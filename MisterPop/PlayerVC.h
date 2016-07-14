//
//  PlayerVC.h
//  MisterPop
//
//  Created by Pablo on 7/13/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioStreamer.h"

@interface PlayerVC : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView * backgroundIV;
@property (nonatomic, retain) AudioStreamer *streamer;


@end
