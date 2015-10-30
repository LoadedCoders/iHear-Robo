//
//  Query.m
//  iHRobo
//
//  Created by Pradyumna Doddala on 10/30/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import "Query.h"

@implementation Query

- (NSString *)description {
    return [NSString stringWithFormat:@"(%@, %@, %@)", _subject, _predicate, _object];
}
@end
