//
//  MetroListViewController.h
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroListTableView.h"
#import "BMapKit.h"
#import "CityViewController.h"
#import "City.h"

@interface MetroListViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UISearchBarDelegate, UISearchDisplayDelegate,
BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate>

@property (nonatomic) IBOutlet MetroListTableView *tvMetroListView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cityButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nearbyButton;
@property (strong, nonatomic) BMKLocationService *locationService;
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIView *metroListView;

@property (strong, nonatomic) IBOutlet BMKMapView *bmkMapView;
@property (weak, nonatomic) IBOutlet UISearchBar *metroSearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *metroSearchController;
@property (nonatomic, retain) City *selectedCity;
@end
