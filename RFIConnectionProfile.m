//
//  RFIConnectionProfile.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 16.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFIConnectionProfile.h"

static NSString * const baseUrl = @"https://pay.paymentnepal.com/alba/";
static NSString * const cardTokenUrl = @"https://secure.paymentnepal.com/cardtoken/";
// static NSString * const cardTokenTestUrl = @"https://test.rficb.ru/cardtoken/";

@implementation RFIConnectionProfile

+ (NSString *)baseUrl {
    return baseUrl;
}

+ (NSString *)cardTokenUrl {
    return cardTokenUrl;
}

+ (NSString *)cardTokenTestUrl {
    return cardTokenTestUrl;
}

@end
