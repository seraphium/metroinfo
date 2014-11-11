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
@property (nonatomic,copy) NSString* openTime1;
@property (nonatomic,copy) NSString* closeTime1;
@property (nonatomic,copy) NSString* openTime2;
@property (nonatomic,copy) NSString* closeTime2;
-(instancetype)initWithName:(NSString*)name openDate1:(NSString*)opendate1 closeDate1:(NSString*)closedate1 openDate2:(NSString*)opendate2 closeDate2:(NSString*)closedate2;
//-(void)setMetroStation;
@end
