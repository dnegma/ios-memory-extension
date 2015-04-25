//
//  NSURL+SCUtils.h
//  Challenge
//
//  Created by Diana Gren on 4/25/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SCUtils)

/*! Create a URL with the specified host, path and query parameters.
 @param host Host
 @param path Path that will be appended to the host
 @param params Dictionary with query paramers that will be formated into key1=value1&key2=value2 in the URL
 @return A URL of the format "host/path?queryParams"
 */
+ (instancetype)URLWithHost:(NSString *)host path:(NSString *)path queryParams:(NSDictionary *)params;

@end