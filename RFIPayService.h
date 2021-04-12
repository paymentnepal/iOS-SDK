//
//  RFIPayService.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 07.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFIPay.h"
#import "RFIPaymentRequest.h"
#import "RFIPaymentResponse.h"
#import "RFICardTokenRequest.h"
#import "RFICardTokenResponse.h"

@class RFITransactionDetails;

typedef void(^serviceSuccessBlock)(RFIPaymentResponse *response);
typedef void(^cardTokenSuccessBlock)(RFICardTokenResponse *response);
typedef void(^transactionSuccessBlock)(RFITransactionDetails *response);
typedef void(^cancelationSuccessBlock)(void);
typedef void(^errorBlock)(NSDictionary *error);

@interface RFIPayService : NSObject

- (instancetype)initWithServiceId:(NSString *)serviceId andSecret:(NSString *)secret;
- (instancetype)initWithServiceId:(NSString *)serviceId andKey:(NSString *)key;

// Init payment
- (void)paymentInit:(RFIPaymentRequest *)paymentRequest
       successBlock:(serviceSuccessBlock)success
            failure:(errorBlock)failure;

// Get transaction state
- (void)transactionDetailsWithSessionKey:(NSString *)sessionKey
                            successBlock:(transactionSuccessBlock)success
                                 failure:(errorBlock)failure;

// TODO CLASS RFIRefundRequest
// Init refund request
//- (id) refundResponse: (RFIRefundRequest *)refundRequest;

// Create payment token
- (void)createCardToken:(RFICardTokenRequest *)request
                 isTest:(BOOL)isTest
           successBlock:(cardTokenSuccessBlock)success
                failure:(errorBlock)failure;

// Sign Version 2.0
- (NSString *) generateCheck: (NSDictionary *)requestParams;

// Sign Version 1.0 1.1 1.2
//- (NSString *) generateCheckOldVersion;

// Generate request string to gateway server from params provided
+ (NSString *) generateUrlForRequest: (RFIPaymentRequest *)paymentRequest;

// Cancel recurrent payment
- (void)cancelRecurrentPaymentWithOrderId:(NSString *)orderId
                             successBlock:(cancelationSuccessBlock)success
                                  failure:(errorBlock)failure;

@end
