//
//  metroStation.m
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import "MetroStation.h"

@implementation MetroStation
-(instancetype)initWithName:(NSString*)name openDate1:(NSDate*)opendate1 closeDate1:(NSDate*)closedate1 openDate2:(NSDate*)opendate2 closeDate2:(NSDate*)closedate2
{
    self.stationName = name;
    self.openTime1 = opendate1;
    self.closeTime1 = closedate1;
    self.openTime2 = opendate2;
    self.closeTime2 = closedate2;
    return self;
}
@end
