//
//  User.m
//  twitter
//
//  Created by lucjia on 7/1/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profilePicURL = dictionary[@"profile_image_url_https"];
        // Initialize any other properties
    }
    return self;
}

@end
