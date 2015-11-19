//
//  APIServices.h
//  iHRobo
//
//  Created by Pradyumna Doddala on 11/18/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIServices : NSObject

+ (void)weatherWithOption:(NSString *)option
              WithSuccess:(void (^)(id response))success
                  failure:(void (^)(NSError *error))failure;

+ (void)humidityWithOption:(NSString *)option
               WithSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError *error))failure;
@end