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

@interface TimelineViewController ()

@property (strong, nonatomic) NSArray *tweetArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    // Set UITableViewDataSource methods
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            NSLog(@"%@", tweets);
            for (NSDictionary *dictionary in tweets) {
//                NSString *text = dictionary[@"_text"];
            }
            self.tweetArray = tweets;
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Identifies number of rows to return
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetArray.count;
}

// Determines which cell is at each row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    Tweet *tweets = self.tweetArray[indexPath.row];
    User *user = tweets.user;
    
    cell.authorLabel.text = user.name;
    cell.handleLabel.text = user.screenName;
    cell.dateLabel.text = tweets.createdAtString;
    cell.tweetLabel.text = tweets.text;
    
    NSString *profilePictureString = user.profilePicURL;
    NSURL *profilePictureURL = [NSURL URLWithString:profilePictureString];
    [cell.profileImageView setImageWithURL:profilePictureURL];
    
    NSString* retweets = [NSString stringWithFormat:@"%i", tweets.retweetCount];
    cell.retweetLabel.text = retweets;
    NSString* favorites = [NSString stringWithFormat:@"%i", tweets.favoriteCount];
    cell.favoriteLabel.text = favorites;
    
    
    return cell;
}

// Makes a network request to get updated data
// Updates the tableView with the new data
// Hides the RefreshControl
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    
    // Create NSURL and NSURLRequest
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                // ... Use the new data to update the data source ...
                // Reload the tableView now that there is new data
                    [self.tableView reloadData];
                                                
                // Tell the refreshControl to stop spinning
                    [refreshControl endRefreshing];
        }];
    [task resume];
}

@end
