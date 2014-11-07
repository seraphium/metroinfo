//
//  metroStation.h
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetroStation : NSObject
@property (nonatomic,copy) NSString *stationName;
@property (nonatomic,copy) NSDate* openTime1;
@property (nonatomic,copy) NSDate* closeTime1;
@property (nonatomic,copy) NSDate* openTime2;
@property (nonatomic,copy) NSDate* closeTime2;
-(instancetype)initWithName:(NSString*)name openDate1:(NSDate*)opendate1 closeDate1:(NSDate*)closedate1 openDate2:(NSDate*)opendate2 closeDate2:(NSDate*)closedate2;
//-(void)setMetroStation;
@end
