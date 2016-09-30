//
//  APIServices.m
//  iHRobo
//
//  Created by Pradyumna Doddala on 11/18/15.
//  Copyright © 2015 Pradyumna Doddala. All rights reserved.
//

#import "APIServices.h"
#import "AFNetworking.h"

@implementation APIServices

+ (void)weatherWithOption: (NSString *)option WithSuccess:(void (^)(id response))success failure:(void (^)(NSError *error))failure {
    NSString *string = @"https://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20%3D%202430683&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys";
    
    if ([option containsString:@"inside"]) {
            string = @"https://api.mongolab.com/api/1/databases/getsensordata/collections/temperature?apiKey=LUfrwtaIQRZG-upMjETJnyJVS643iMEA";
    }
    
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([option containsString:@"inside"]) {
            NSString *temp = [[responseObject lastObject] objectForKey:@"Temperature"];
            float temperature = [temp floatValue] * 1.8 + 32.0;
            
            if (success != NULL) {
                success([NSString stringWithFormat:@"%f", temperature]);
            }
        } else {
            NSDictionary *results = [[responseObject objectForKey:@"query"] objectForKey:@"results"];
            NSDictionary *weather= [[[results objectForKey:@"channel"] objectForKey:@"item"] objectForKey:@"condition"];
            NSString *temp = [weather objectForKey:@"temp"];
            NSLog(@"%@", weather);
            if (success != NULL) {
                success(temp);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        if (failure != NULL) {
            failure(error);
        }
    }];
    [operation start];
}

+ (void)humidityWithOption: (NSString *)option WithSuccess:(void (^)(id response))success failure:(void (^)(NSError *error))failure {
    NSString *string = @"http://api.openweathermap.org/data/2.5/weather?q=Kansas%20City,MO&appid=2de143494c0b295cca9337e1e96b00e0";
    
    if ([option containsString:@"inside"]) {
        string = @"https://api.mongolab.com/api/1/databases/getsensordata/collections/humidity?apiKey=LUfrwtaIQRZG-upMjETJnyJVS643iMEA";
    }
    
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([option containsString:@"inside"]) {
            NSString* humidity = [[responseObject lastObject] objectForKey:@"humidity"];
            //        NSLog(@"%@", responseObject);
            success(humidity);
        } else {
            NSString* humidity = [[responseObject objectForKey:@"main"] objectForKey:@"Humidity"];
            //        NSLog(@"%@", responseObject);
            success(humidity);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        failure(error);
    }];
    [operation start];
}

@end
