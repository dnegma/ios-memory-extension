//
//  SCUserRequest.m
//  Challenge
//
//  Created by D Gren on 4/25/15.
//  Copyright (c) 2015 D Gren. All rights reserved.
//

#import "SCUserRequest.h"

@implementation SCUserRequest

+ (instancetype)newTracksListRequestForUserId:(NSNumber *)userId completion:(SCRequestCompletion)completion {
  NSString *path = [NSString stringWithFormat:@"users/%@/tracks", userId];
  return [self newRequestGETWithPath:path params:nil completion:completion];
}

@end
