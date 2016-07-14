//
//  PlayerVC.m
//  MisterPop
//
//  Created by Pablo on 7/13/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import "PlayerVC.h"

@interface PlayerVC ()

@end

@implementation PlayerVC

@synthesize backgroundIV;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [backgroundIV setAnimationImages:[self createImagesArray]];
    [backgroundIV setAnimationDuration:5];
    [backgroundIV setAnimationRepeatCount:0];
    [backgroundIV startAnimating];
    
    [[self navigationController] setNavigationBarHidden:TRUE];
    
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
