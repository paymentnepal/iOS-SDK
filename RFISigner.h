//
//  RFISigner.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 14.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFISigner : NSObject //{
//    NSString * _url;
//    NSString * _method;
//}
//
//
//@property (nonatomic, copy) NSString * url;
//@property (nonatomic, copy) NSString * method;

+ (NSString *) sign: (NSString *)method url: (NSString *)url requestParams: (NSDictionary *)requestParams secretKey: (NSString *) secretKey;


@end
