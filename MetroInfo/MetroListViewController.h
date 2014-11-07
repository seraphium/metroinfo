//
//  MetroListViewController.h
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroListTableView.h"
#import "Mapkit/MapKit.h"
#import "CoreLocation/CoreLocation.h"

@interface MetroListViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
MKMapViewDelegate, CLLocationManagerDelegate,
UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic) IBOutlet MetroListTableView *tvMetroListView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cityButton;
@property (strong, nonatomic) IBOutlet MKMapView *metroMapView;
@property (strong, nonatomic) CLLocationManager *metroLocationManager;

@property (weak, nonatomic) IBOutlet UISearchBar *metroSearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *metroSearchController;

@end
