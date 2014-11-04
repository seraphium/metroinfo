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
@property (nonatomic,copy) NSDate* openTime;
@property (nonatomic,copy) NSDate* closeTime;
-(instancetype)initWithName:(NSString*)name openDate:(NSDate*)opendate closeDate:(NSDate*)closedate;
//-(void)setMetroStation;
@end
