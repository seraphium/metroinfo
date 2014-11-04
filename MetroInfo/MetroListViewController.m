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
@end

@implementation MetroListViewController

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"location=%@", newLocation.description);
    if (self.metroLocationManager == nil)
    {
        self.metroMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        self.metroMapView.mapType = MKMapTypeStandard;
        self.metroMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.metroMapView.delegate = self;
       
    }
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
    
//load data from sqlte db
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSLog(documents);
    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
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
         const char *open = sqlite3_column_text(statement, 3);
         NSString *openDate = [[NSString alloc] initWithUTF8String:open];
         const char *close = sqlite3_column_text(statement, 4);
         NSString *closeDate = [[NSString alloc] initWithUTF8String:close];
         
         MetroStation* stationItem = [[MetroStation alloc] initWithName:stationName openDate:openDate closeDate:closeDate];
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
    return [self.showArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"metroLineTableCell" forIndexPath:indexPath];
    NSString *item = [self.showArray objectAtIndex:indexPath.row];
    cell.textLabel.text = item;

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
   // vcMetroInfoController.metroStation = [[MetroStation alloc] initWithName:station.stationName openDate:station.openTime closeDate:station.closeTime];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

- (IBAction)unwindToList:(UIStoryboardSegue *)seque
{
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




@end
