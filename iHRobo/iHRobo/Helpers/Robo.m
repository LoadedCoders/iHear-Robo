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
    LxDBAnyVar(roboDetails);
}

- (void)process: (NSString *)text {
    NSString *scheme = NSLinguisticTagSchemeLexicalClass;
    NSArray *schemes = @[scheme];
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:schemes
                                                                        options:0];
    
    NSString *targetText = text;
    [tagger setString:targetText];
    
    
    Query *q = [Query new];
    
    [tagger enumerateTagsInRange:NSMakeRange(0, targetText.length)
                          scheme:scheme
                         options:NSLinguisticTaggerOmitWhitespace
                      usingBlock:
     ^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
         NSString *word = [targetText substringWithRange:tokenRange];
         NSLog(@"%@ - %@", word, tag);
         
         if (tag == NSLinguisticTagVerb) {
             q.predicate = word;
         }
         
         if (tag == NSLinguisticTagDeterminer) {
             if ([word isEqualToString:@"your"]) {
                 q.subject = @"my";
             } else {
                 q.subject = @"unknown";
             }
         }
         if (tag == NSLinguisticTagNoun) {
            q.object = word;
         }
         
     }];
    
    LxDBAnyVar(q);
    
    [self processQuery:q];
}

- (void)processQuery:(Query *)q {
    if ([q.subject isEqualToString:@"my"]) {
        if([[roboDetails allKeys] containsObject:q.object]) {
            q.response = [NSString stringWithFormat:@"%@ %@ %@ %@",q.subject, q.object, q.predicate, [roboDetails valueForKey:q.object]];
        } else {
            q.response = [NSString stringWithFormat:@"I don't know %@ %@",q.subject, q.object];
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
