//
//  DetailsViewController.m
//  twitter
//
//  Created by lucjia on 7/5/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.authorLabel.text = self.tweet.user.name;
    NSString *atSymbol = @"@";
    NSString *screenNameString = [atSymbol stringByAppendingString:self.tweet.user.screenName];
    self.handleLabel.text = screenNameString;
    self.dateLabel.text = self.tweet.createdAtString;
    self.tweetLabel.text = self.tweet.text;
    
    NSString *profilePictureString = self.tweet.user.profilePicURL;
    NSURL *profilePictureURL = [NSURL URLWithString:profilePictureString];
    [self.profileImageView setImageWithURL:profilePictureURL];
    
    self.retweetLabel.text = [NSString stringWithFormat:@"%i", self.tweet.retweetCount];
    self.favoriteLabel.text = [NSString stringWithFormat:@"%i", self.tweet.favoriteCount];
    
    if (self.tweet.retweeted) {
        self.retweetButton.selected = YES;
    } else {
        self.retweetButton.selected = NO;
    }
    if (self.tweet.favorited) {
        self.favoriteButton.selected = YES;
    } else {
        self.favoriteButton.selected = NO;
    }
    [self refreshRetweetData];
    [self refreshFavoriteData];
}

- (IBAction)didTapRetweet:(id)sender {
    if (self.tweet.retweeted) {
        self.tweet.retweeted = NO;
        [sender setSelected:NO];
        self.tweet.retweetCount -= 1;
        
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully unretweeted the following Tweet: %@", tweet.text);
            }
        }];
        self.retweetLabel.textColor = [UIColor scrollViewTexturedBackgroundColor];
    } else {
        self.tweet.retweeted = YES;
        [sender setSelected:YES];
        self.tweet.retweetCount += 1;
        
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
            }
        }];
        self.retweetLabel.textColor = [UIColor colorWithRed:(20/255.f) green:(200/255.f) blue:(50/255.f) alpha:1.0];
    }
    [self refreshRetweetData];
}

- (IBAction)didTapFavorite:(id)sender {
    if (self.tweet.favorited) {
        self.tweet.favorited = NO;
        [sender setSelected:NO];
        self.tweet.favoriteCount -= 1;
        
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error unfavoriting tweet: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
            }
        }];
        self.favoriteLabel.textColor = [UIColor scrollViewTexturedBackgroundColor];
    } else {
        self.tweet.favorited = YES;
        [sender setSelected:YES];
        self.tweet.favoriteCount += 1;
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
            }
        }];
        self.favoriteLabel.textColor = [UIColor colorWithRed:(200/255.f) green:(0/255.f) blue:(0/255.f) alpha:1.0];
    }
    [self refreshFavoriteData];
}

- (void)refreshRetweetData {
    NSString* retweets = [NSString stringWithFormat:@"%i", self.tweet.retweetCount];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateSelected];
    self.retweetLabel.text = retweets;
    
    // Changing color of text label
    if (self.tweet.retweeted) {
        self.retweetLabel.textColor = [UIColor colorWithRed:(20/255.f) green:(200/255.f) blue:(50/255.f) alpha:1.0];
    } else {
        self.retweetLabel.textColor = [UIColor scrollViewTexturedBackgroundColor];
    }
}

- (void) refreshFavoriteData {
    NSString* favorites = [NSString stringWithFormat:@"%i", self.tweet.favoriteCount];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateSelected];
    self.favoriteLabel.text = favorites;
    
    // Changing color of text label
    if (self.tweet.favorited) {
        self.favoriteLabel.textColor = [UIColor colorWithRed:(200/255.f) green:(0/255.f) blue:(0/255.f) alpha:1.0];
    } else {
        self.favoriteLabel.textColor = [UIColor scrollViewTexturedBackgroundColor];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
