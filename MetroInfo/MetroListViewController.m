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
}
@property (nonatomic, retain) NSMutableArray * metroArray;
@property (nonatomic, retain) NSMutableArray * showArray;
@property (nonatomic) BOOL isStation;
@property (nonatomic, assign) int iSelectedLine;
@property (nonatomic, assign) int iSelectedStation;
@property (nonatomic, assign) CLLocationCoordinate2D curLocation;
//for searchbar
@property (nonatomic, retain) NSMutableArray * searchedArray;
@property (nonatomic) BOOL isLocateAvail;
@end

@implementation MetroListViewController

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"location=%@", newLocation.description);
    self.isLocateAvail = YES;
    self.curLocation = newLocation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.curLocation, span);
    MKCoordinateRegion adjustedRegion = [self.metroMapView regionThatFits:viewRegion];
    [self.metroMapView setRegion:adjustedRegion animated:YES];

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"failed to get user location:%@", error);
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([manager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [manager requestAlwaysAuthorization];
            }
            break;
            
        default:
            break;
    }
}
-(void)initLocation
{
    if ([CLLocationManager locationServicesEnabled])
    {
        self.metroLocationManager = [[CLLocationManager alloc] init];
        self.metroLocationManager.delegate = self;
        [self.metroLocationManager requestAlwaysAuthorization];
        self.metroLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.metroLocationManager.distanceFilter = 10.0f;
        [self.metroLocationManager startUpdatingLocation];
        NSLog(@"Location service started");
    }
    else{
        NSLog(@"Location service not enabled.");
    }
}


-(void)viewDidLoad
{
    self.cityButton.title = @"城市";
    [self initialData];
    self.isStation = NO;
    self.showArray = [self.metroArray valueForKey:@"lineName"];
    self.tvMetroListView.delegate = self;
    self.tvMetroListView.dataSource = self;
    [self.tvMetroListView reloadData];
    
    self.metroSearchBar.delegate = self;
    self.isLocateAvail = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self initLocation];
  
}

-(void)Alert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

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
   // NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS METROINFO (id INTEGER PRIMARY KEY AUTOINCREMENT,LINENAME TEXT, STATIONNAME TEXT, OPENDATE TIME_STAMP, CLOSEDATE TIME_STAMP)";
    //NSMutableDictionary * lineMap = [[NSMutableDictionary alloc] initWithCapacity:50];
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
         const char *open1 = sqlite3_column_text(statement, 3);
         NSString *openDate1 = [[NSString alloc] initWithUTF8String:open1];
         const char *open2 = sqlite3_column_text(statement, 4);
         NSString *openDate2 = [[NSString alloc] initWithUTF8String:open2];
         const char *close1 = sqlite3_column_text(statement, 5);
         NSString *closeDate1 = [[NSString alloc] initWithUTF8String:close1];
         const char *close2 = sqlite3_column_text(statement, 6);
         NSString *closeDate2 = [[NSString alloc] initWithUTF8String:close2];
         
         MetroStation* stationItem = [[MetroStation alloc] initWithName:stationName openDate1:openDate1 closeDate1:closeDate1 openDate2:openDate2 closeDate2:closeDate2];
         
         //if not exists ,create new array
         NSUInteger indexOfLine = [self.metroArray indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
         {
             MetroLineItem *item = (MetroLineItem*)obj;
             return [item.lineName isEqualToString:lineName];
         }];
        if (indexOfLine == NSNotFound)
        {
            MetroLineItem *line = [[MetroLineItem alloc] initWithName:lineName Stations:nil];
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
        cell.textLabel.text = [self.showArray objectAtIndex:indexPath.row];
    }

    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = segue.destinationViewController;
    
    MetroInfoViewController *vcMetroInfoController = [navigationController.viewControllers objectAtIndex:0];

    MetroLineItem *item = [self.metroArray objectAtIndex:self.iSelectedLine];
    MetroStation *station = [item.stationArray objectAtIndex:self.iSelectedStation];

    vcMetroInfoController.lineName = item.lineName;
    vcMetroInfoController.metroStation = station;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
            NSMutableArray* array = [[self.metroArray objectAtIndex:indexPath.row] stationArray];
            self.showArray = [array valueForKey:@"stationName"];
            [self.tvMetroListView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            self.isStation = YES;
            self.iSelectedLine = indexPath.row;
            self.cityButton.title = @"后退";
        }
        else
        {
            self.iSelectedStation = indexPath.row;
            [self performSegueWithIdentifier:@"sequeStation" sender:self];
        
        }
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)seque
{
    if (self.isLocateAvail)
    {
        MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
        MKCoordinateRegion viewRegion = MKCoordinateRegionMake(self.curLocation, span);
        MKCoordinateRegion adjustedRegion = [self.metroMapView regionThatFits:viewRegion];
        [self.metroMapView setRegion:adjustedRegion animated:YES];
    }
}
- (IBAction)didSelectCityBackBtn:(id)sender {
    
    if (self.isStation)
    {
         self.showArray = [self.metroArray valueForKey:@"lineName"];
        [self.tvMetroListView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        self.isStation = NO;
        self.cityButton.title = @"城市";
    }
    else
    {

    }
}


#pragma mark search logic
- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd]%@", searchText];
    int itemNum = 0;
    for (MetroLineItem *item in self.metroArray)
    {
        int stationNum = 0;
        for (MetroStation *station in item.stationArray)
        {
            if ([resultPredicate evaluateWithObject:station.stationName])
            {
                SearchInfo *info = [[SearchInfo alloc] init];
                info.mixedString = [NSString stringWithFormat:@"%@ - %@", item.lineName, station.stationName];
                info.lineNum = itemNum;
                info.stationNum = stationNum;
                [self.searchedArray addObject:info];
            }
            stationNum++;
        }
        itemNum++;
    }
    
                
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



@end
