//
//  AppDelegate.h
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *navigationController;
    BMKMapManager* _mapManager;

}
@property (strong, nonatomic) UIWindow *window;


@end
