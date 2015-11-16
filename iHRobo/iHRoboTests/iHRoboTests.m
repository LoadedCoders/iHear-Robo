//
//  iHRoboTests.m
//  iHRoboTests
//
//  Created by Pradyumna Doddala on 10/20/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Robo.h"

@interface iHRoboTests : XCTestCase

@end

@implementation iHRoboTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProcess {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    Robo *robo = [[Robo alloc] init];
    [robo process:@"Are you sitting on a chair ?"];
    [robo process:@"Is the light on ?"];
    [robo process:@"Is the room dark ?"];
    [robo process:@"Are you gonna run tomorrow ?"];
     [robo process:@"What is your name ?"];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
