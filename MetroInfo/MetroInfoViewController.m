//
//  MetroInfoViewController.m
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import "MetroInfoViewController.h"

@implementation MetroInfoViewController
-(void)viewDidLoad
{
    self.lbLine.text = self.lineName;
    self.lbStation.text = self.metroStation.stationName;
    self.lbOpenDate.text = self.metroStation.openTime.description;
    self.lbCloseDate.text = self.metroStation.closeTime.description;
}



@end
