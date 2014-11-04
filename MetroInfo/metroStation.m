//
//  metroStation.m
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import "MetroStation.h"

@implementation MetroStation
-(instancetype)initWithName:(NSString*)name openDate:(NSDate*)opendate closeDate:(NSDate*)closedate
{
    self.stationName = name;
    self.openTime = opendate;
    self.closeTime = closedate;
    return self;
}
@end
