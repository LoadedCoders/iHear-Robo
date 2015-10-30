//
//  iHNLP.m
//  iHRobo
//
//  Created by Pradyumna Doddala on 10/30/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import "iHNLP.h"

@implementation iHNLP

- (NSArray *)showAvailableSchemes {
    
    NSArray *schemes;
    
    schemes = [NSLinguisticTagger availableTagSchemesForLanguage:@"en"];
    
//    NSLog(@"schemes for en:%@", schemes);
    return schemes;
}

- (void)showTagsForText: (NSString *)text WithScheme:(NSString *)scheme {
    
    NSArray *schemes = @[scheme];
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:schemes
                                                                        options:0];
    
    NSString *targetText = text;
    [tagger setString:targetText];
    
    [tagger enumerateTagsInRange:NSMakeRange(0, targetText.length)
                          scheme:scheme
                         options:0
                      usingBlock:
     ^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
         NSString *word = [targetText substringWithRange:tokenRange];
         NSLog(@"%@ - %@", word, tag);
     }];
}

- (void)showTagsForText: (NSString *)text {
    [self showTagsForText:text WithScheme:NSLinguisticTagSchemeLexicalClass];
}

@end
