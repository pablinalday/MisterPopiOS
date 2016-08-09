//
//  SplashVC.h
//  MisterPop
//
//  Created by Pablo on 7/26/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface SplashVC : UIViewController


@property (nonatomic, retain) IBOutlet UIView * playerView;
@property (nonatomic, retain) IBOutlet UILabel * downloadingLabel;
@property (nonatomic, assign) Boolean videoDidFinish;
@property (nonatomic, assign) Boolean downloadDidFinish;

@end
