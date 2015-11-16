//
//  Query.h
//  iHRobo
//
//  Created by Pradyumna Doddala on 10/30/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Query : NSObject

@property (nonatomic, strong) NSString *determiner;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *object;
@property (nonatomic, strong) NSString *predicate;

@property (nonatomic, strong) NSString *response;
@property (nonatomic, assign) BOOL *processed;
@property (nonatomic, assign) NSString *type;
@end
