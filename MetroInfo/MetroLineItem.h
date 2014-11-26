//
//  MetroLineItem.h
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "metroStation.h"

@interface MetroLineItem : NSObject
@property (nonatomic, assign) NSInteger lineId;
@property (nonatomic, copy) NSString *lineName;
@property (nonatomic, retain) NSMutableArray *stationArray;
-(instancetype)initWithName:(NSString*)lineName lineId:(NSInteger)line_id Stations:(NSMutableArray*)stationArray;
-(void)addStation:(MetroStation *)station;
@end
