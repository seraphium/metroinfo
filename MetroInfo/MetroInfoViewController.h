//
//  MetroInfoViewController.h
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroStation.h"

@interface MetroInfoViewController : UIViewController
@property (nonatomic, copy) NSString *lineName;
@property (nonatomic, retain) MetroStation *metroStation;
@property (weak, nonatomic) IBOutlet UILabel *lbLine;
@property (weak, nonatomic) IBOutlet UILabel *lbStation;
@property (weak, nonatomic) IBOutlet UILabel *lbOpenDate;
@property (weak, nonatomic) IBOutlet UILabel *lbCloseDate;

@end
