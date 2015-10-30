//
//  iHNLP.h
//  iHRobo
//
//  Created by Pradyumna Doddala on 10/30/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iHNLP : NSObject

- (NSArray *)showAvailableSchemes;
- (void)showTagsForText: (NSString *)text WithScheme:(NSString *)scheme;
- (void)showTagsForText: (NSString *)text;
@end
