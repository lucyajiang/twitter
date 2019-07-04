//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "DateTools.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
// dataSource tells you: how many rows / gives back cells
// delegate tells you: touch events (but we are not using any functionality right now)

@property (strong, nonatomic) NSArray *tweetArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // get user from the APIManager
    
    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getTimeline) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    // Set UITableViewDataSource methods
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self getTimeline];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getTimeline {
    // Get timeline
    // Completion handler (always a function in the view controller)
    // Can define a function by passing a pointer to a function
    // Note: ^ indicates that a block is coming, function is called in-line with the API request
    // Pass a completion to APIManager so that it does not block the app from launching (gets APIManager to retrieve data and return it when the network request is finished), deferred execution
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            // success
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            NSLog(@"%@", tweets);
//            for (NSDictionary *dictionary in tweets) {
//                                NSString *text = dictionary[@"_text"];
//            }
            self.tweetArray = tweets;
            // reload the table view to repopulate the UI; otherwise, it will not pick up the new information
            [self.tableView reloadData];
        } else {
            // error to indicate that the network request fails
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
                NSLog(@"%@", [error localizedDescription]);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Tweets"
                                             message:@"The internet connection appears to be offline."
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
                // create a try again action
                UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                         style:UIAlertActionStyleCancel
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                                           // handle cancel response here. Doing nothing will dismiss the view.
                                                                           [self getTimeline];
                                                                       }];
                // add the cancel action to the alertController
                [alert addAction:tryAgainAction];
                
                [self presentViewController:alert animated:YES completion:^{
                    // optional code for what happens after the alert controller has finished presenting
                }];
        }
        // Tell the refreshControl to stop spinning
        [self.refreshControl endRefreshing];
    }];
    // Completion handler puts data into view controller (needs to make a DEEP COPY)
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = [segue destinationViewController];
    
    ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
    composeController.delegate = self;
}

// tableView asks dataSource for number of rows / cell for row at
// functions are called as part of reloadData

// Identifies number of rows to return from the API
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetArray.count;
}

// Determines which cell is at each row (returns an instance of the custom cell
// with reuse identifier with the data that the index asked for
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    Tweet *tweets = self.tweetArray[indexPath.row];
    User *user = tweets.user;
    cell.tweet = tweets;
    
    return cell;
}

- (void) didTweet:(Tweet *)tweet {
    self.tweetArray = [self.tweetArray arrayByAddingObject:tweet];
    [self getTimeline];
    [self.tableView reloadData];
}

- (IBAction)didTapLogOut:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    [[APIManager shared] logout];
}

@end
