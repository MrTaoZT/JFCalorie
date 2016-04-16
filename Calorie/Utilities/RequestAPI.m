//
//  RequestAPI.m
//  Request
//
//  Created by ZIYAO YANG on 24/11/2015.
//  Copyright © 2015 Pro. All rights reserved.
//

#import "RequestAPI.h"

@implementation RequestAPI

+ (void)getURL:(NSString *)request withParameters:(NSDictionary *)parameter success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    NSString *server = @"http://club.fisheep.com.cn";
    NSString *url = [NSString stringWithFormat:@"%@%@", server, request];
    NSString *decodedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    [[AppAPIClient sharedClient] GET:decodedURL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        success(responseObject);
//    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
//        failure(error);
//    }];
    
    [[AppAPIClient sharedClient]GET:decodedURL parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+ (void)postURL:(NSString *)request withParameters:(NSDictionary *)parameter success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    NSString *server = @"http://club.fisheep.com.cn";
    NSString *url = [NSString stringWithFormat:@"%@%@", server, request];
    NSString *decodedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    [[AppAPIClient sharedJSONClient] POST:decodedURL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        success(responseObject);
//    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
//        failure(error);
//    }];
    
    [[AppAPIClient sharedJSONClient] POST:decodedURL parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

@end
