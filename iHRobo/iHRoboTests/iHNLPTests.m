//
//  iHNLPTests.m
//  iHRobo
//
//  Created by Pradyumna Doddala on 10/30/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "iHNLP.h"

@interface iHNLPTests : XCTestCase {
    iHNLP *nlp;
}
@end

@implementation iHNLPTests

- (void)setUp {
    [super setUp];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    nlp = [[iHNLP alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSchemes {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSArray *schemes = [nlp showAvailableSchemes];
    NSLog(@"%@", schemes);
    XCTAssertGreaterThan([schemes count], 1);
}

- (void)testSentenceTagging {
    
    [nlp showTagsForText:@"My name is Prad" WithScheme:NSLinguisticTagSchemeLexicalClass];
}
@end
