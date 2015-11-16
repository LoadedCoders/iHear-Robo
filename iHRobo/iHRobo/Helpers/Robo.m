//
//  Robo.m
//  iHRobo
//
//  Created by Pradyumna Doddala on 10/30/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import "Robo.h"
#import "Query.h"
#import <AVFoundation/AVFoundation.h>

@interface Robo() {
    NSString *plistPath;
    NSDictionary *roboDetails;
}

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@end

@implementation Robo

+ (id)sharedManager {
    static Robo *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"RoboPropertyList" ofType:@"plist"];
        NSAssert(plistPath != NULL, @"Sorry Robo plist missing.");
        roboDetails = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
    }
    return self;
}

- (void)info {
    NSLog(@"%@", roboDetails);
}

- (void)process: (NSString *)text {
    NSString *scheme = NSLinguisticTagSchemeLexicalClass;
    NSArray *schemes = @[scheme];
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:schemes
                                                                        options:0];
    
    NSString *targetText = text;
    [tagger setString:targetText];
    
    NSArray *whPronouns = @[@"what", @"why", @"where", @"how", @"when", @"whom"];
    
    Query *q = [Query new];
    
    [tagger enumerateTagsInRange:NSMakeRange(0, targetText.length)
                          scheme:scheme
                         options:NSLinguisticTaggerOmitWhitespace
                      usingBlock:
     ^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
         NSString *word = [targetText substringWithRange:tokenRange];
         NSLog(@"%@ - %@", word, tag);
         
         if (tag == NSLinguisticTagVerb) {
             if (q.predicate) {
                 q.predicate = [NSString stringWithFormat:@"%@ %@", q.predicate, word];
             } else {
                 q.predicate = word;
             }
         }
         else if (tag == NSLinguisticTagDeterminer) {
            q.determiner = word;
         }
         else if (tag == NSLinguisticTagPronoun) {
             if ([whPronouns containsObject:[word lowercaseString]]) {
                 
             } else {
                 q.subject = word;
             }
         }
         else if (tag == NSLinguisticTagNoun) {
             if (!q.subject) {
                 if (q.determiner) {
                    q.subject = [NSString stringWithFormat:@"%@ %@", q.determiner, word];
                     q.determiner = nil;
                 } else {
                    q.subject = word;
                 }
             } else {
                 if (q.determiner) {
                     q.object = [NSString stringWithFormat:@"%@ %@", q.determiner, word];
                     q.determiner = nil;
                 } else {
                     q.object = word;
                 }
             }
         } else if (tag == NSLinguisticTagPreposition) {
             if (q.predicate) {
                 q.predicate = [NSString stringWithFormat:@"%@ %@", q.predicate, word];
             } else {
                 q.predicate = word;
             }
         }
         
     }];
    
    NSLog(@"%@", q);
    
    [self processQuery:q];
}

- (void)processQuery:(Query *)q {
    if ([q.subject containsString:@"your"]) {
        q.subject = [q.subject stringByReplacingOccurrencesOfString:@"your" withString:@"my"];
        NSArray *comps = [q.subject componentsSeparatedByString:@" "];
        NSString *prop = [comps lastObject];
        if([[roboDetails allKeys] containsObject:prop]) {
                q.response = [NSString stringWithFormat:@"%@ %@ %@",q.subject, q.predicate, [roboDetails valueForKey:prop]];
                    } else {
            q.response = [NSString stringWithFormat:@"I don't know %@", q.subject];
        }
    }
    
    [self say:q.response];
}


- (void)say:(NSString*)text {
    NSString *cmd = [text uppercaseString];
    if (_synthesizer == nil) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = nil;
    }
    
    AVSpeechUtterance *utterence = [[AVSpeechUtterance alloc] initWithString:cmd];
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    [utterence setVoice:voice];
    
    [_synthesizer speakUtterance:utterence];
}
@end
