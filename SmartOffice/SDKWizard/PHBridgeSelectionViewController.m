/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHBridgeSelectionViewController.h"
#import "IndoorMapViewController.h"
#import "AppDelegate.h"

@interface PHBridgeSelectionViewController ()
{
    IndoorMapViewController *view;
}

@end

@implementation PHBridgeSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil bridges:(NSDictionary *)bridges delegate:(id<PHBridgeSelectionViewControllerDelegate>)delegate {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Make it a form on iPad
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        
        self.delegate = delegate;
        self.bridgesFound = bridges;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.bridgesFound = [def objectForKey:@"bridgesFound"];
    // Set title of screen
    self.title = @"Available SmartBridges";
    
    //[self removeLoadingView];
    
    //[self showLoadingViewWithText:NSLocalizedString(@"Searching...", @"Searching for bridges text")];
    
    [SVProgressHUD dismiss];
    
    //[SVProgressHUD showWithStatus:@"Connecting..."];
    
    // Refresh button
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                             target:self
                                             action:@selector(refreshButtonClicked:)];
	self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    view = [[IndoorMapViewController alloc] init];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if ([self.bridgesFound count]==0) {
        
        NSLog(@"view.bridgesFound:%@",view.bridgesFound);
        
        if ([view.bridgesFound count]==0) {
            
            [self searchForBridgeLocal];
            
        } else {
            
            self.bridgesFound = view.bridgesFound;
            
            [self.tableView reloadData];
            
        }
        
    }
    
}

- (void)searchForBridgeLocal {
    
    [self removeLoadingView];
    
    // Show search screen
   // [self showLoadingViewWithText:NSLocalizedString(@"Searching...", @"Searching for bridges text")];
    
    //[SVProgressHUD showWithStatus:@"Connecting..."];
    
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    
    // Start search
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAddressSearch:YES];
    
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        // Done with search, remove loading view
        //[self removeLoadingView];
        
        [SVProgressHUD dismiss];
        
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
        if (bridgesFound.count > 0) {
            
            self.bridgesFound = bridgesFound;
            
            [self.tableView reloadData];
        }
        
    }];
}


- (IBAction)refreshButtonClicked:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [view searchForBridgeLocal];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"self.bridgesFound:%@",self.bridgesFound);
    
    return self.bridgesFound.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Sort bridges by bridge id
    NSArray *sortedKeys = [self.bridgesFound.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // Get mac address and ip address of selected bridge
    NSString *bridgeId = [sortedKeys objectAtIndex:indexPath.row];
    NSString *ip = [self.bridgesFound objectForKey:bridgeId];
    
    // Update cell
    cell.textLabel.text = bridgeId;
    cell.detailTextLabel.text = ip;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Please select a SmartBridge to use for this application";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Sort bridges by bridge id
    NSArray *sortedKeys = [self.bridgesFound.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    /***************************************************
     The choice of bridge to use is made, store the bridge id
     and ip address for this bridge
     *****************************************************/
    
    // Get bridge id and ip address of selected bridge
    NSString *bridgeId = [sortedKeys objectAtIndex:indexPath.row];
    NSString *ip = [self.bridgesFound objectForKey:bridgeId];
    
    [self dismissViewControllerAnimated:YES completion:^{
        //[self.delegate bridgeSelectedWithIpAddress:ip andBridgeId:bridgeId];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:bridgeId forKey:@"selectedBridgeId"];
        [defaults setObject:ip forKey:@"ip"];
        [defaults setBool:YES forKey:@"bridgeSelected"];
        
        [defaults synchronize];
        

    }];
    // Inform delegate
}

#pragma mark - Loading view

/**
 Shows an overlay over the whole screen with a black box with spinner and loading text in the middle
 @param text The text to display under the spinner
 */
- (void)showLoadingViewWithText:(NSString *)text {
    // First remove
    [self removeLoadingView];
    
    // Then add new
    self.loadingView = [[PHLoadingViewController alloc] initWithNibName:@"PHLoadingViewController" bundle:[NSBundle mainBundle]];
    self.loadingView.view.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:self.loadingView.view];
    self.loadingView.loadingLabel.text = text;
}

/**
 Removes the full screen loading overlay.
 */
- (void)removeLoadingView {
    if (self.loadingView != nil) {
        [self.loadingView.view removeFromSuperview];
        self.loadingView = nil;
    }
}


@end
