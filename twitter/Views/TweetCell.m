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
//    NSDate *timeAgoDate = [NSDate dateWithString:tweet.createdAtString];
//    NSLog(@"%@", tweet.createdAtString);
//    NSLog(@"%@", timeAgoDate);
    self.dateLabel.text = tweet.createdAtString;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

- (IBAction)didTapRetweet:(id)sender {
    // TODO: Update the local tweet model
    // TODO: Update cell UI
    // TODO: Send a POST request to the POST retweet/create endpoint
    
    if (self.tweet.retweeted) {
        self.tweet.retweeted = NO;
        [sender setSelected:NO];
        self.tweet.retweetCount -= 1;
        
        if (self.tweet.retweetCount == 0) {
            self.retweetLabel.hidden = YES;
        }
        
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

@end
