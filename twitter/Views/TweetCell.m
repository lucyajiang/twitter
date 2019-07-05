//
//  TweetCell.m
//  twitter
//
//  Created by lucjia on 7/1/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "DateTools.h"
#import "Tweet.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    self.authorLabel.text = self.tweet.user.name;
    NSString *atSymbol = @"@";
    NSString *screenNameString = [atSymbol stringByAppendingString:self.tweet.user.screenName];
    self.handleLabel.text = screenNameString;
    NSDate *timeAgoDate = [NSDate dateWithString:tweet.createdAtString formatString:@"MM/dd/yy"];
    NSLog(@"%@", tweet.createdAtString);
    NSLog(@"%@", timeAgoDate);
    self.dateLabel.text = timeAgoDate.shortTimeAgoSinceNow;
    self.tweetLabel.text = tweet.text;
    
    NSString *profilePictureString = self.tweet.user.profilePicURL;
    NSURL *profilePictureURL = [NSURL URLWithString:profilePictureString];
    [self.profileImageView setImageWithURL:profilePictureURL];
    
    self.retweets = [NSString stringWithFormat:@"%i", tweet.retweetCount];
    self.retweetLabel.text = self.retweets;
    self.favorites = [NSString stringWithFormat:@"%i", tweet.favoriteCount];
    self.favoriteLabel.text = self.favorites;
    
    if (self.tweet.retweeted) {
        self.retweetButton.selected = YES;
    }
    if (self.tweet.favorited) {
        self.favoriteButton.selected = YES;
    }
    
    [self refreshData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)hideLabels {
    if (self.retweets.integerValue == 0) {
        self.retweetLabel.hidden = YES;
    } else {
        self.retweetLabel.hidden = NO;
    }
    
    if (self.favorites.integerValue == 0) {
        self.favoriteLabel.hidden = YES;
    } else {
        self.favoriteLabel.hidden = NO;
    }
}

- (IBAction)didTapFavorite:(id)sender {
    // TODO: Update the local tweet model
    // TODO: Update cell UI
    // TODO: Send a POST request to the POST favorites/create endpoint
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
        [self hideLabels];
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
        [self hideLabels];
    }
    [self refreshData];
}

- (IBAction)didTapRetweet:(id)sender {
    // TODO: Update the local tweet model
    // TODO: Update cell UI
    // TODO: Send a POST request to the POST retweet/create endpoint
    self.tweet.retweeted = YES;
    [sender setSelected:YES];
    self.tweet.retweetCount += 1;
    self.retweetLabel.hidden = NO;
    
    [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
        } else {
            NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
        }
    }];
    
    [self refreshData];
}

- (void)refreshData {
    NSString* retweets = [NSString stringWithFormat:@"%i", self.tweet.retweetCount];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateSelected];
    self.retweetLabel.text = retweets;
    NSString* favorites = [NSString stringWithFormat:@"%i", self.tweet.favoriteCount];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateSelected];
    self.favoriteLabel.text = favorites;
}

@end
