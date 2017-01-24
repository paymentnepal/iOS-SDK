Библиотека для работы c Alba
=============

Инициализация сервиса:

      RFIPayService * payService = [[RFIPayService alloc]
                                  initWithServiceId: @"12345"
                                  andSecret: @"abcd1234"];

Для проведения оплаты банковской картой с вводом карточных данных необходимо сначала создать токен содержащий данные,
а затем использовать его для инициации платежа. Данные, необходимые для создания токена, содержатся в RFICardTokenRequest.
Если карта требует проведения 3-D Secure проверку, то paymentResponse.card3ds будет содержать данные
для POST запроса на сайт банка-эмитента.

Получение токена карты:

        RFICardTokenRequest * cardTokenRequest = [[RFICardTokenRequest alloc] initWithServiceId:payService.serviceId andCard: @"<Номер карты>" andExpMonth: @"<Месяц>" andExpYear:@"<Год>" andCvc:@"<CVC>" andCardHolder: @"<Владелец карты>"];
        RFICardTokenResponse * cardTokenResponse = [payService createCardToken:cardTokenRequest isTest:YES];
                                  
Если cardTokenResponse.hasErrors == NO, инициализируем транзакцию:

        // Генерируем запрос на оплату
        RFIPaymentRequest * paymentRequest = [[RFIPaymentRequest alloc] init];

        // Собираем необходимые параметры для платежа
        paymentRequest.paymentType = @"spg_test";     // Варинаты: mc, qiwi, spg, spg_test
        paymentRequest.email = @"<Email>";            // Может быть обязательным, в зависисмости от настроек сервиса
        paymentRequest.cost = @"<Сумма>";             // в целых
        paymentRequest.name = @"<Название платежа>";        
        paymentRequest.phone = @"<Номер телефона>";   // Обязательно, если канал оплаты mc, qiwi
        paymentRequest.orderId = @"<Номер заказа>";   // Номер заказа должен быть уникальным. Необязательное поле
        paymentRequest.background = @"1";             // Всегда ставим 1
        paymentRequest.cardToken = cardTokenResponse.token;       // В случае, если канал оплаты spg или spg_test        
        paymentRequest.comment = @"<Комментарий>";    // Необязательное поле

Получаем ответ от Банка:

        RFIPaymentResponse * paymentResponse = [payService paymentInit:paymentRequest];

Если paymentResponse.hasErrors не содержит ошибок, получаем ID транзакции

        NSString * transactionId = paymentResponse.transactionId;

Получаем статус инициализации транзакции:

        NSString * status = paymentResponse.status;
            
Получаем дополнительный текст по оплате (mc):

        NSString * help = paymentResponse.help;

Если требуется обработка 3DS:

        if(paymentResponse.card3ds) {
            //Обработка 3DS
        }

Если 3-D secure требуется, то необходимо сделать POST запрос на адрес paymentResponse.card3ds.ACSUrl с параметрами:

        PaReq - с значением paymentResponse.card3ds.PaReq
        MD - с значением paymentResponse.card3ds.MD
        TermUrl - URL обработчика, на вашем сайте. На него будет возвращён пользователь после прохождения 3DS авторизации       
                
        Для проверки прохождения 3DS авторизации следует вызвать POST запросом API https://partner.rficb.ru/alba/ack3ds/ , передав туда:
        service_id;
        tid или order_id;
        emitent_response - данные, пришедшие от банка-эмитента в виде JSON-encoded словаря (Содержатся в paymentResponse.card3ds)
        check - подпись запроса
        version=2.0 - версия протокола
                
Пример для подписи запроса:

        NSString * check = [RFISigner sign:@"строка для подписи"
                                       url:@"URL куда отправляем запрос"
                             requestParams: @{}
                                 secretKey: payService.secret];
                
Также есть возможность воспользоваться готовым termUrl, для этого достаточно указать:

        https://secure.rficb.ru/acquire?sid=<ID-Сервиса>&oid=<ID-Транзакции>&op=pay
                
Или в случае тестовой оплаты:

        https://test.rficb.ru/acquire?sid=<ID-Сервиса>&oid=<ID-Транзакции>&op=pay
          
Получение информации о транзакции:

        RFITransactionDetails * transactionDetails = [payService transactionDetails: transactionId];

Статус инициализации транзакции. success - успех

        NSString * transactionStatus = transactionDetails.status;

Статус проведения платежа. open, error, payed, success

        NSString * transactionPayStatus = transactionDetails.transactionStatus;



Метод проверки статуса 3DS

- (void) check3DSStatusForService: (NSString *) serviceId
                          orderId: (NSNumber *) orderId
                  emitentResponse: (NSDictionary *) emitentResponse
                     andSecretKey: (NSString *) secretKey
{
    
    NSString *checkURL = @"https://partner.rficb.ru/alba/ack3ds";
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:emitentResponse
                                                       options:0
                                                         error:&error];
    
    NSString *emitentResponseJSON;
   
    emitentResponseJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *paymentParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                         @"service_id": serviceId,
                                                                                         @"tid": [orderId stringValue],
                                                                                         @"emitent_response": emitentResponseJSON,
                                                                                         @"version": @"2.0"
                                                                                         }];
    
    RFIRestRequester *requester = [[RFIRestRequester alloc] init];
    
        [requester request:checkURL andMethod:@"post" andParams: paymentParams andSecret:secretKey];

        NSLog(@"Ответ 3ds: %@",requester.responseJSONData);  
}


Получение статуса транзакции:

       TransactionDetails details = service.transactionDetails(response.getSessionKey());
       if (details.getStatus() == TransactionStatus.PAYED || details.getStatus() == TransactionStatus.SUCCESS) {
          // транзакция оплачена
       } else {
          // транзакция не оплачена
       }


