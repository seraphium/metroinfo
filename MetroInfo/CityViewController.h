//
//  CityViewController.h
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/11.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "City.h"

@interface CityViewController : UITableViewController
@property (nonatomic,retain) NSMutableArray *cityArray;
@property (nonatomic,retain) City *selectedCity;
@end
