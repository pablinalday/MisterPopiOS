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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:TRUE];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[Controller getInstance] getRadioSchedule];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [[Controller getInstance] getBackgroundImages];
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    PlayerVC * nextVC = [[PlayerVC alloc] initWithNibName:@"PlayerVC" bundle:nil];
                    [[self navigationController] pushViewController:nextVC animated:TRUE];
                    RELEASE_SAFE(nextVC);
                });
            });
        });
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
