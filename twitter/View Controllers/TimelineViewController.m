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
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        // Tell the refreshControl to stop spinning
        [self.refreshControl endRefreshing];
    }];
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
    
    NSString *atSymbol = @"@";
    NSString *screenNameString = [atSymbol stringByAppendingString:user.screenName];
    cell.handleLabel.text = screenNameString;
    cell.dateLabel.text = tweets.createdAtString;
    cell.tweetLabel.text = tweets.text;
    
    NSString *profilePictureString = user.profilePicURL;
    NSURL *profilePictureURL = [NSURL URLWithString:profilePictureString];
    [cell.profileImageView setImageWithURL:profilePictureURL];
    
    NSString* retweets = [NSString stringWithFormat:@"%i", tweets.retweetCount];
    cell.retweetLabel.text = retweets;
    cell.retweetImageView.image = [UIImage imageNamed: @"retweet-icon"];
    NSString* favorites = [NSString stringWithFormat:@"%i", tweets.favoriteCount];
    cell.favoriteLabel.text = favorites;
    cell.favoriteImageView.image = [UIImage imageNamed: @"favor-icon"];
    
    return cell;
}

@end
