//
//  RadioShow.h
//  MisterPop
//
//  Created by Pablo on 7/26/16.
//  Copyright © 2016 MisterPop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RadioShow : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *days;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int end;

@end
