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
    self.dateLabel.text = tweet.createdAtString;
    self.tweetLabel.text = tweet.text;
    
    NSString *profilePictureString = self.tweet.user.profilePicURL;
    NSURL *profilePictureURL = [NSURL URLWithString:profilePictureString];
    [self.profileImageView setImageWithURL:profilePictureURL];
    
    NSString* retweets = [NSString stringWithFormat:@"%i", tweet.retweetCount];
    self.retweetLabel.text = retweets;
    NSString* favorites = [NSString stringWithFormat:@"%i", tweet.favoriteCount];
    self.favoriteLabel.text = favorites;
    
    self.retweetButton.selected = self.tweet.retweeted;
    self.favoriteButton.selected = self.tweet.favorited;
    
    if (retweets.integerValue == 0) {
        self.retweetLabel.hidden = YES;
    }
    
    if (favorites.integerValue == 0) {
        self.favoriteLabel.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapFavorite:(id)sender {
    // TODO: Update the local tweet model
    // TODO: Update cell UI
    // TODO: Send a POST request to the POST favorites/create endpoint
    self.tweet.favorited = YES;
    [sender setSelected:YES];
    self.tweet.favoriteCount += 1;
    self.favoriteLabel.hidden = NO;
    
    [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
        } else {
            NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
        }
    }];
    
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
