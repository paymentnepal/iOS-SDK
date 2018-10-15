//
//  RFIInvoiceData.h
//  test
//
//  Created by Alexander Nazarov on 9/6/18.
//  Copyright © 2018 forkode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFIInvoiceItem : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *unit;
@property (nonatomic, copy) NSString *vatMode;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *quantity;
@property (nonatomic, strong) NSNumber *sum;
@property (nonatomic, strong) NSNumber *vatAmount;
@property (nonatomic, strong) NSNumber *discountRate;
@property (nonatomic, strong) NSNumber *discountAmount;

@end

@interface RFIInvoiceData : NSObject

@property (nonatomic, strong) NSNumber *vatTotal;
@property (nonatomic, strong) NSNumber *discountTotal;
@property (nonatomic, strong) NSArray<RFIInvoiceItem *> *items;

+ (instancetype)invoiceDataWithVatTotal:(NSNumber *)vatTotal
                          discountTotal:(NSNumber *)discountTotal
                           invoiceItems:(NSArray<RFIInvoiceItem *> *)items;

- (NSString *)parameters;

@end
