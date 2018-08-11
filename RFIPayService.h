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

@interface RFIPayService : NSObject {
    NSString * _key;
    NSString * _secret;
    NSString * _serviceId;
}

@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * secret;
@property (nonatomic) NSString * serviceId;

// OLD
//- (id) initWithKey: (NSString *)key;
- (id) initWithServiceId: (NSString *)serviceId andSecret: (NSString *)secret;

// Иницировать платеж с аутентификацией по serviceId
- (void)paymentInit:(RFIPaymentRequest *)paymentRequest
       successBlock:(serviceSuccessBlock)success
            failure:(errorBlock)failure;

// Иницировать платеж с аутентификацией по ключу
- (void)paymentInitWithRequest:(RFIPaymentRequest *)paymentRequest
                        andKey:(NSString *)key
                  successBlock:(serviceSuccessBlock)success
                       failure:(errorBlock)failure;

// Получение статуса транзакции
- (void)transactionDetails:(NSString *)transactionId
              successBlock:(transactionSuccessBlock)success
                   failure:(errorBlock)failure;

// TODO CLASS RFIRefundRequest
// Запрос на проведение возврата
//- (id) refundResponse: (RFIRefundRequest *)refundRequest;

// Создание токена для оплаты
- (void)createCardToken:(RFICardTokenRequest *)request
                 isTest:(BOOL)isTest
           successBlock:(cardTokenSuccessBlock)success
                failure:(errorBlock)failure;

// Подпись Version 2.0
- (NSString *) generateCheck: (NSDictionary *)requestParams;

// Подпись Version 1.0 1.1 1.2
//- (NSString *) generateCheckOldVersion;

// Генерация строки запроса на сервер банка из переданных параметров
+ (NSString *) generateUrlForRequest: (RFIPaymentRequest *)paymentRequest;

@end
