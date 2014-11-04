//
//  MetroLineItem.m
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import "MetroLineItem.h"
#import "MetroStation.h"

@implementation MetroLineItem
-(instancetype)initWithName:(NSString*)lineName Stations:(NSMutableArray*)stationArray
{
    self.lineName = lineName;
    if (stationArray)
    {
        self.stationArray = stationArray;
    }
    else
    {
        self.stationArray = [[NSMutableArray alloc]initWithCapacity:50];
        
    }
    return self;
}

-(void)addStation:(MetroStation *)station
{
    [self.stationArray addObject:station];
}
@end
