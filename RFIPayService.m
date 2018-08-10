//
//  RFIPayService.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 07.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFIPayService.h"
#import "RFIPaymentResponse.h"
#import "RFIHelpers.h"
#import "RFISigner.h"
#import "RFIRestRequester.h"
#import "RFIConnectionProfile.h"
#import "RFITransactionDetails.h"
#import "RFIReccurentParams.h"

@implementation RFIPayService


// Version 2.0
- (NSString *) generateCheck: (NSDictionary *)requestParams {
    
    //
    NSString * string = @"";
    string = [string stringByAppendingFormat: @"%@%@", _serviceId, _secret];
    string = [string md5];
    
    return string;
}

- (id) initWithKey: (NSString *)key {
    
    if(self = [super init]) {
        self.key = key;
    }
    
    return self;
}

- (id) initWithServiceId: (NSString *)serviceId andSecret : (NSString *)secret {
    
    if(self = [super init]) {
        _secret = secret;
        _serviceId = serviceId;
    }
    
    return self;
}


// TODO надо ли дедать?
+ (NSString *) generateUrlForRequest: (RFIPaymentRequest *)paymentRequest {
    
    return @"";
}

//
// Иницировать платеж с аутентификацией по serviceId
//

- (id)paymentInit:(RFIPaymentRequest *)paymentRequest {
    
    NSDictionary *params = @{@"version": @"2.0",
                             @"service_id": _serviceId};
    
    return [self paymentInitWithRequest:paymentRequest andParams:params];
}

//
// Иницировать платеж с аутентификацией по ключу
//

- (id)paymentInitWithRequest:(RFIPaymentRequest *)paymentRequest andKey:(NSString *)key
{
    NSDictionary *params = @{@"key": key};
    
    return [self paymentInitWithRequest:paymentRequest andParams:params];
}

//
// Иницировать платеж с параметрами
//

- (id)paymentInitWithRequest:(RFIPaymentRequest *)paymentRequest andParams:(NSDictionary *)params
{
    NSMutableDictionary * requestMutableParams = [params mutableCopy];
    
    requestMutableParams[@"payment_type"] = paymentRequest.paymentType;
    requestMutableParams[@"cost"] = paymentRequest.cost;
    requestMutableParams[@"name"] = paymentRequest.name;
    
    if (paymentRequest.email) {
        requestMutableParams[@"email"] = paymentRequest.email;
    }
    
    if (paymentRequest.phone) {
        requestMutableParams[@"phone_number"] = paymentRequest.phone;
    }
    
    if (paymentRequest.orderId) {
        requestMutableParams[@"order_id"] = paymentRequest.orderId;
    }
    
    if (paymentRequest.cardToken) {
        requestMutableParams[@"card_token"] = paymentRequest.cardToken;
    }
    
    if (paymentRequest.comment) {
        requestMutableParams[@"comment"] = paymentRequest.comment;
    }
    
    NSString *background = paymentRequest.background ? paymentRequest.background : @"0";
    requestMutableParams[@"background"] = background;
    
    if (paymentRequest.commissionMode) {
        requestMutableParams[@"commission"] = paymentRequest.commissionMode;
    }
    
    if (paymentRequest.reccurentParams) {
        if (paymentRequest.reccurentParams.type == RFIReccurentTypeFirst) {
            requestMutableParams[@"reccurent_type"] = @"first";
            requestMutableParams[@"reccurent_comment"] = paymentRequest.reccurentParams.comment;
            requestMutableParams[@"reccurent_url"] = paymentRequest.reccurentParams.url;
            requestMutableParams[@"reccurent_period"] = paymentRequest.reccurentParams.period;
        } else {
            if (!paymentRequest.background) {
                NSLog(@"Error! When recurrent_type is \"next\" then background should be \"1\"");
            }
            requestMutableParams[@"reccurent_type"] = @"next";
            requestMutableParams[@"recurrent_order_id"] = paymentRequest.reccurentParams.orderId;
        }
    }
    
    // Инициализация платежа
    
    NSDictionary *requestParams = [requestMutableParams copy];
    
    @try {
        NSString *hostUrl =  [[RFIConnectionProfile alloc] baseUrl];
        NSString *url = [hostUrl stringByAppendingString:@"alba/input"];
        
        NSDictionary *restRequest = [[RFIRestRequester alloc] request: url
                                                            andMethod: @"POST"
                                                            andParams: requestParams
                                                            andSecret:_secret];
        
        RFIPaymentResponse * paymentResponse = [[RFIPaymentResponse alloc] initWithRequest:restRequest];
        return paymentResponse;
        
    } @catch (NSException *exception) {
        NSLog (@"Обнаружена ошибка с именем %@ и по причине %@.", [exception name], [exception reason]);
    }
}

//
// Получить токен карты
//

- (RFICardTokenResponse *) createCardToken: (RFICardTokenRequest *)request isTest: (BOOL) isTest {
    
    NSDictionary * requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"2.0", @"version",
                                    request.card, @"card",
                                    _serviceId, @"service_id",
                                    request.expMonth, @"exp_month",
                                    request.expYear, @"exp_year",
                                    request.cvc, @"cvc",
                                    @"1", @"background",
                                    nil];
    
    @try {
        NSString * hostUrl = @"";
        if(isTest) {
            hostUrl = [hostUrl stringByAppendingString: [[RFIConnectionProfile alloc] cardTokenTestUrl]];
        } else {
            hostUrl = [hostUrl stringByAppendingString: [[RFIConnectionProfile alloc] cardTokenUrl]];
        }
        
        NSString * url = [hostUrl stringByAppendingString:@"create"];
        
        NSDictionary * restRequest = [[RFIRestRequester alloc] request: url
                                                             andMethod: @"POST"
                                                             andParams: requestParams
                                                             andSecret:_secret];
        // NSLog(@"restRequest is %@", restRequest);
        
        RFICardTokenResponse * cardTokenResponse = [[RFICardTokenResponse alloc] initWithRequest:restRequest];
        return cardTokenResponse;
        
    } @catch (NSException *exception) {
        NSLog (@"Обнаружена ошибка с именем %@ и по причине %@.", [exception name], [exception reason]);
    }
}

//
// Получить детали транзакции
//

- (id) transactionDetails: (NSString *) transactionId {
    
    RFITransactionDetails * transactionDetails = [RFITransactionDetails alloc];
    
    NSDictionary * requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"2.0", @"version",
                                    [NSString stringWithFormat:@"%@",transactionId], @"tid",
                                    _serviceId, @"service_id",
                                    nil];
    
    @try {
        NSString * hostUrl = [[RFIConnectionProfile alloc] baseUrl];
        
        NSString * url = [hostUrl stringByAppendingString:@"alba/details"];
        
        NSDictionary * restRequest = [[RFIRestRequester alloc] request: url
                                                             andMethod: @"POST"
                                                             andParams: requestParams
                                                             andSecret:_secret];
//        NSLog(@"restRequest is %@", restRequest);
        
        transactionDetails = [transactionDetails initWithReponse:restRequest];
        
        
    } @catch (NSException *exception) {
        NSLog (@"Обнаружена ошибка с именем %@ и по причине %@.", [exception name], [exception reason]);
    }
    
    return transactionDetails;
}

@end
