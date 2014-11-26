//
//  MetroListViewController.m
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/1.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import "MetroListViewController.h"
#import "MetroLineItem.h"
#import "MetroStation.h"
#import "MetroInfoViewController.h"
#import "sqlite3.h"
#import "SearchInfo.h"

#define DBNAME @"metroinfo.sqlite"
#define TABLENAME @"METROINFO"

@interface MetroListViewController()
{
    sqlite3 *db;
    BMKPoiSearch *_searcher;
    NSString *_uid;
    BOOL isAnnotation;
}
@property (nonatomic, retain) NSMutableArray * metroArray;
@property (nonatomic, retain) NSMutableArray * showArray;
@property (nonatomic, retain) NSMutableArray * poiArray;
@property (nonatomic, retain) NSMutableArray * annotationArray;
@property (nonatomic) BOOL isStation;
@property (nonatomic, assign) int iSelectedLine;
@property (nonatomic, assign) int iSelectedStation;
@property (nonatomic, assign) BMKUserLocation * curLocation;
//for searchbar
@property (nonatomic, retain) NSMutableArray * searchedArray;
@property (nonatomic) BOOL isLocateAvail;

@end

@implementation MetroListViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.cityButton.title = @"城市";
    [self initialData];
    self.isStation = NO;
    self.showArray = self.metroArray;
    self.tvMetroListView.delegate = self;
    self.tvMetroListView.dataSource = self;
    [self.tvMetroListView reloadData];
    
    self.metroSearchBar.delegate = self;
    
    //initialize baidu map and location service
    self.isLocateAvail = NO;
    self.locationService = [[BMKLocationService alloc] init];
    
    [self.locationService startUserLocationService];
    self.bmkMapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 376)];

    self.bmkMapView.showsUserLocation = NO;
    self.bmkMapView.userTrackingMode = BMKUserTrackingModeNone;
    self.bmkMapView.showsUserLocation = YES;
    
    [self.mapView addSubview:self.bmkMapView];
    _searcher = [[BMKPoiSearch alloc] init];
    _searcher.delegate = self;
    
    
}
#pragma mark location updated
-(void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    self.curLocation = userLocation;
    [self.bmkMapView updateLocationData:userLocation];
  // [self.bmkMapView setCenterCoordinate:userLocation.location.coordinate animated:YES];

    [self.bmkMapView setRegion: BMKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1000, 1000)animated:YES];
    
   
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.bmkMapView viewWillAppear];
    self.bmkMapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locationService.delegate = self;
    NSString* city = [[NSUserDefaults standardUserDefaults] stringForKey:@"city"];
#pragma mark first time in
    if (!city && !self.selectedCity)
    {
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *myView = [story instantiateViewControllerWithIdentifier:@"cityNavigator"];
        [self presentViewController:myView animated:YES completion:nil];
    }
    else
    {   if (!self.selectedCity)
        {
            City * newCity = [[City alloc] init];
            newCity.cityName = city;
            self.selectedCity = newCity;
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:self.selectedCity.cityName forKey:@"city"];
        }
        
    }

}


-(void) viewWillDisappear:(BOOL)animated
{
    [self.bmkMapView viewWillDisappear];
    self.bmkMapView.delegate = nil;
    self.locationService.delegate = nil;
    _searcher.delegate = nil;
    
}
-(void)viewDidAppear:(BOOL)animated
{
    if (self.selectedCity)
    {
        NSString *title = [[NSString alloc] initWithFormat:@"%@%@", self.selectedCity.cityName, @"地铁线路"];
        self.navigationItem.title = title;
    }
}

-(void)Alert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark data initialization
-(void)initialData
{

    self.metroArray = [NSMutableArray arrayWithCapacity:50];
    self.searchedArray = [NSMutableArray arrayWithCapacity:50];
//load data from sqlte db
    NSString *database_path = [[NSBundle mainBundle] pathForResource:@"metroinfo" ofType:@"sqlite"];
    NSLog(database_path);
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK)
    {
        sqlite3_close(db);
        NSLog(@"database open error");
        [self Alert:@"数据库打开异常"];
        exit(-1);
    }
    
    //get all the line names
    NSString *sqlQuery = [[NSString alloc] initWithFormat:@"select * from %@", TABLENAME];
    sqlite3_stmt *statement;

    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1,  &statement, nil) != SQLITE_OK)
    {
        sqlite3_close(db);
        NSLog(@"database open error");
        [self Alert:@"数据库读取异常"];
    }
    else
    {
     while (sqlite3_step(statement) == SQLITE_ROW)
     {
         char *line = (char*)sqlite3_column_text(statement, 1);
         NSString *lineName = [[NSString alloc] initWithUTF8String:line];
         char *station = (char*)sqlite3_column_text(statement, 2);
         NSString *stationName = [[NSString alloc] initWithUTF8String:station];
         const unsigned char *open1 = sqlite3_column_text(statement, 3);
         NSString *openDate1 = [[NSString alloc] initWithUTF8String:(const char*)open1];
         const unsigned char *open2 = sqlite3_column_text(statement, 4);
         NSString *openDate2 = [[NSString alloc] initWithUTF8String:(const char*)open2];
         const unsigned char *close1 = sqlite3_column_text(statement, 5);
         NSString *closeDate1 = [[NSString alloc] initWithUTF8String:(const char*)close1];
         const unsigned char *close2 = sqlite3_column_text(statement, 6);
         NSString *closeDate2 = [[NSString alloc] initWithUTF8String:(const char*)close2];
         int lineId = sqlite3_column_int(statement, 7);
         MetroStation* stationItem = [[MetroStation alloc] initWithName:stationName openDate1:openDate1 closeDate1:closeDate1 openDate2:openDate2 closeDate2:closeDate2];
         
         //if not exists ,create new array
         NSUInteger indexOfLine = [self.metroArray indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
         {
             MetroLineItem *item = (MetroLineItem*)obj;
             return [item.lineName isEqualToString:lineName];
         }];
        if (indexOfLine == NSNotFound)
        {
            MetroLineItem *line = [[MetroLineItem alloc] initWithName:lineName lineId:lineId Stations:nil];
            [line addStation:stationItem];
            [self.metroArray addObject:line];
        }
        else
        {
            [[self.metroArray objectAtIndex:indexOfLine] addStation:stationItem];
        }

     }
    }
    
    
    sqlite3_close(db);
    
    self.poiArray = [[NSMutableArray alloc] initWithCapacity:50];
    isAnnotation = NO;
    self.annotationArray = [[NSMutableArray alloc] initWithCapacity:50];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section
    if ([tableView isEqual:self.metroSearchController.searchResultsTableView])
    {    //searched result
        return [self.searchedArray count];
    }
    else
        return [self.showArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([tableView isEqual:self.metroSearchController.searchResultsTableView])
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        if ([self.searchedArray count] > 0)
        {
            SearchInfo *info = [self.searchedArray objectAtIndex:indexPath.row];
            cell.textLabel.text = info.mixedString;
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"metroLineTableCell" forIndexPath:indexPath];
        if (self.isStation)
        {
            cell.textLabel.text = [self.showArray objectAtIndex:indexPath.row];
            NSString *imageString = [NSString stringWithFormat:@"icon_metro_line%d", self.iSelectedLine];
            cell.imageView.image = [UIImage imageNamed:imageString];
        }
        else
        {
            MetroLineItem *item = [self.showArray objectAtIndex:indexPath.row];
            cell.textLabel.text = item.lineName;
            NSString *imageString = [NSString stringWithFormat:@"icon_metro_line%d", (int)item.lineId];
            cell.imageView.image = [UIImage imageNamed:imageString];
        }
    }

    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:UIBarButtonItem.class])
    {
        
    }
    else
    {
        UINavigationController *navigationController = segue.destinationViewController;
        
        MetroInfoViewController *vcMetroInfoController = [navigationController.viewControllers objectAtIndex:0];
    
        NSUInteger indexOfLine = [self.metroArray indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                                  {
                                      MetroLineItem *item = (MetroLineItem*)obj;
                                      return item.lineId == self.iSelectedLine;
                                  }];
        MetroLineItem *item = [self.metroArray objectAtIndex:indexOfLine];
        MetroStation *station = [item.stationArray objectAtIndex:self.iSelectedStation];

        vcMetroInfoController.lineName = item.lineName;
        vcMetroInfoController.metroStation = station;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //select the result row
    if ([tableView isEqual:self.metroSearchController.searchResultsTableView])
    {
        SearchInfo *info = [self.searchedArray objectAtIndex:indexPath.row];
        self.iSelectedLine = info.lineNum;
        self.iSelectedStation = info.stationNum;
        [self performSegueWithIdentifier:@"sequeStation" sender:tableView];

    }
    else
    {
        if (!self.isStation)
        {
            MetroLineItem *item = [self.metroArray objectAtIndex:indexPath.row];
            NSMutableArray* array = [item stationArray];
            self.showArray = [array valueForKey:@"stationName"];
            self.isStation = YES;
            self.iSelectedLine = item.lineId;
            [self.tvMetroListView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];

            self.cityButton.title = @"后退";
        }
        else
        {
            self.iSelectedStation = indexPath.row;
            [self performSegueWithIdentifier:@"sequeStation" sender:self];
        
        }
    }
}

- (IBAction)didSelectCityBackBtn:(id)sender {
    
    if (self.isStation)
    {
        self.showArray = self.metroArray;
        self.isStation = NO;
        [self.tvMetroListView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        self.cityButton.title = @"城市";
    }
    else
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *myView = [story instantiateViewControllerWithIdentifier:@"cityNavigator"];
        [self presentViewController:myView animated:YES completion:nil];
    }
}


#pragma mark search logic
- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd]%@", searchText];

    for (MetroLineItem *item in self.metroArray)
    {
        int stationNum = 0;
        for (MetroStation *station in item.stationArray)
        {
            if ([resultPredicate evaluateWithObject:station.stationName])
            {
                SearchInfo *info = [[SearchInfo alloc] init];
                info.mixedString = [NSString stringWithFormat:@"%@ - %@", item.lineName, station.stationName];
                info.lineNum = item.lineId;
                info.stationNum = stationNum;
                [self.searchedArray addObject:info];
            }
            stationNum++;
        }

    }
    
}

-(IBAction)unwindSegueFromCitySelect:(UIStoryboardSegue*)segue
{
    CityViewController *controller = [[segue.sourceViewController viewControllers] objectAtIndex:0];
    self.selectedCity = controller.selectedCity;
  }

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];

    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self.searchedArray removeAllObjects];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{

}

-(IBAction)unwindSegueFromMetroInfo:(UIStoryboardSegue*)segue
{
    if (self.isStation)
    {
        self.cityButton.title = @"后退";
    }
}

#pragma mark annotation

-(void)onGetPoiDetailResult:(BMKPoiSearch *)searcher result:(BMKPoiDetailResult *)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode == BMK_SEARCH_NO_ERROR)
    {
        BMKPoiDetailResult* result = poiDetailResult;
        
    }
}

-(void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode == BMK_SEARCH_NO_ERROR)
    {
        NSArray *infos = [poiResult poiInfoList];
        self.poiArray = infos;
        
        for (BMKPoiInfo *info in infos)
        {
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
            annotation.coordinate = info.pt;
            annotation.title = info.name;
            [self.bmkMapView addAnnotation:annotation];
            [self.annotationArray addObject:annotation];
            _uid = info.uid;
            BMKPoiDetailSearchOption *option = [[BMKPoiDetailSearchOption alloc] init];
            option.poiUid = _uid;
            BOOL flag = [_searcher poiDetailSearch:option];
            if (flag)
            {
                BMKMapPoint point1 = BMKMapPointForCoordinate(self.curLocation.location.coordinate);
                BMKMapPoint point2 = BMKMapPointForCoordinate(info.pt);
                CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
                NSLog(@"distance of %@:%f", info.name, distance);
            }
            else
            {
                
            }
        }
        
        
        
    }
    else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD)
    {
        NSLog(@"结果有歧义");
    }
    else
    {
        NSLog(@"未找到结果");
    }
}


- (BMKAnnotationView *)_mapView:(BMKMapView *)_mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

- (IBAction)btnSearchNearby:(id)sender
{
    if (!isAnnotation)
    {
        [self.poiArray removeAllObjects];
        BMKNearbySearchOption *nearOption = [[BMKNearbySearchOption alloc] init];
        nearOption.pageIndex = 0;
        nearOption.pageCapacity = 10;
        nearOption.radius = 1000;
        nearOption.location = self.curLocation.location.coordinate;
        nearOption.keyword = @"餐馆";
        BOOL flag = [_searcher poiSearchNearBy:nearOption];
        if (flag)
        {
            
        }
        else
        {
            
        }
        self.nearbyButton.title = @"清除";
        isAnnotation = YES;
    }
    else
    {
        [self.poiArray removeAllObjects];

        if ([self.annotationArray count] > 0)
        {
                [self.bmkMapView removeAnnotations:self.annotationArray];
        }
        self.nearbyButton.title = @"附近";
        isAnnotation = NO;

    }

  }

@end
