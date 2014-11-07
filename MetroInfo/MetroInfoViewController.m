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
    self.lbOpenDate1.text = self.metroStation.openTime1.description;
    self.lbCloseDate1.text = self.metroStation.closeTime1.description;
    self.lbOpenDate2.text = self.metroStation.openTime2.description;
    self.lbCloseDate2.text = self.metroStation.closeTime2.description;

}



@end
