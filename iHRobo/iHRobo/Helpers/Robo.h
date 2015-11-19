//
//  Robo.h
//  iHRobo
//
//  Created by Pradyumna Doddala on 10/30/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Query;

@interface Robo : NSObject

+ (id)sharedManager;
- (id)init;

- (void)info;
- (void)process:(NSString *)text;
- (void)processQuery:(Query *)q;

- (void)updateKBKey:(NSString *)key value:(NSString *)value;
@end
