@isTest
global class iHASCOLmsRestOutboundTest {
    
    public static final String OPPORTUNITY_RT_DEFAULT_iHASCO_OPPORTUNITY = 'Default IHASCO';
    public static final Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
    public static final Id orderRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('iHASCO').getRecordTypeId();
    
    @testSetup
    static void setUp(){
        
        Id oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        Id quoteRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('IHASCO').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.BillingStreet = 'Harvey street';
        acc.BillingCity = 'Manchester';
        acc.BillingCountry = 'England';
        acc.BillingPostalCode = 'NXJ001';
        acc.Sites__c = 5.0;
        acc.FT_Employees__c = 20.0;
        acc.PT_Employees__c = 10.0;
        acc.iHASCO_Finance_Status__c = 'Active';
        acc.SBQQ__RenewalModel__c = 'Contract Based';
        insert acc;
        
        Site__c acs = new Site__c();
        acs.Account__c = acc.id;
        acs.City__c = 'test';
        acs.Name = 'test';
        insert acs;
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.AccountId = acc.Id;
        c.Phone = '01912553955';
        c.MobilePhone = '70875327792';
        c.Email = 'testcontact@email.com';
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.id;
        opp.Deposit_Payment_Method__c = 'Direct Debit';
        opp.RecordTypeId = oppRecordType;
        opp.CloseDate = Date.newInstance(2021, 09, 30);
        opp.StageName = 'In Progress';
        insert opp;
        
        Map<String,Product2> productMap = new Map<String,Product2>();
        productMap.put(Label.iHASCOUserBasedProduct, createProduct('UserBased',Label.iHASCOUserBasedProduct,true,'Annual'));
        productMap.put('AccessKEY5', createProduct('UserBased','AccessKEY5',true,'Annual'));
        productMap.put('IH-RPM-1000', createProduct('Restricted License','IH-RPM-1000',true,'Annual'));
        productMap.put(Label.iHASCOOpenLicensePricing, createProduct('Open License License',Label.iHASCOOpenLicensePricing,true,'Annual'));
        productMap.put(Label.iHASCOCreditProductCode, createProduct('Credits',Label.iHASCOCreditProductCode,true,'Annual'));
        productMap.put('AccessKEY5', createProduct('UserBased','AccessKEY5',true,'Annual'));
        productMap.put('ASDS', createProduct('DocumentStorage','ASDS',true,'Annual'));
        INSERT productMap.values();
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'iHASCO';
        pb.IsActive = True;
        insert pb;
        
        List<PricebookEntry> entries = new List<PricebookEntry>();
        For(String key: productMap.keySet()){
            product2 p = productMap.get(key);
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(Test.getStandardPricebookId(), p.Id, 1000.0, 0.0, 0.0));
            entries.add(bg_PricebookEntry_TestUtils.createPricebookEntry(pb.Id, p.Id, 1000.0, 0.0, 0.0));
        }
        insert entries; 
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId = quoteRecordType;
        quote.SBQQ__Primary__c = true;
        quote.Payment_Method__c = 'Invoice';
        quote.iHASCO_Payment_Terms__c = '30 Days';
        quote.SBQQ__StartDate__c = Date.today();
        quote.SBQQ__PrimaryContact__c = c.id;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PrimaryContact__c = c.Id;
        quote.Preferred_Payment_Date__c = '7';
        quote.Initial_Payment__c = 200;
        //quote.SBQQ__PriceBook__c = pb.Id;
        quote.Initial_Payment_Date__c = Date.today();
        quote.SBQQ__SubscriptionTerm__c = 24;
        quote.License_Model__c = 'Restricted License';
        //quote.Quotelines_Max_Term__c = 24;
        insert quote;
        
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Product__c = productMap.get('IH-RPM-1000').Id;
        ql.SBQQ__Quantity__c = 1;
        ql.Custom_Discount_Percentage__c = 10;
        ql.SBQQ__Quote__c = quote.Id;
        ql.SBQQ__StartDate__c = Date.today();
        ql.SBQQ__EndDate__c = Date.today().addYears(5);
        ql.Service_Start_Date__c = Date.today();
        
        ql.Billing_Frequency__c = 'Annual';
        ql.SBQQ__BillingFrequency__c = 'Annual';
        ql.SBQQ__NetPrice__c = 600;
        ql.SBQQ__SubscriptionTerm__c = 60;
        ql.FOC_Period__c = 'Start';
        Test.startTest();
        insert ql;
        
        User iHASCOUser = bg_User_TestUtils.createiHASCOUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        iHASCOUser.LastName = 'iHASCOLmsRestOutboundTest';
        insert iHASCOUser;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp.id;
        ocr.ContactId = c.id;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        Id contractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('iHASCO Standard Contract').getRecordTypeId();
        system.runAs(iHASCOUser){
            
            Contract con = new Contract();
            con.Name = 'Test contract';
            con.RecordTypeId = contractRecordType;
            con.StartDate =  Date.today();
            con.ContractTerm = 24;
            con.SBQQ__Quote__c = quote.Id;
            con.AccountId = acc.Id;
            con.Source_Opportunity__c = opp.Id;
            con.SBQQ__Opportunity__c =opp.Id;
            con.Status = 'Draft';
            con.Renewal_Type__c = 'Non-Auto';
            con.Initial_Payment2__c = 200;
            con.CustomerSignedId = c.id;
            con.Total_Contract_Value__c = 1000;
            insert con;
            
            Order ord = new Order();
            ord.AccountId = acc.Id;
            ord.SBQQ__Quote__c = quote.id;
            ord.EffectiveDate = System.today();
            ord.CustomerAuthorizedById = c.id;
            ord.RecordTypeId = orderRecordType;
            ord.status = 'Draft';
            ord.Pricebook2Id = pb.id;
            insert ord;
            
            OrderItem oItem = new OrderItem();
            oItem.Product2Id = productMap.get(Label.iHASCOUserBasedProduct).id;
            oItem.Quantity = 1;
            oItem.UnitPrice = 0;
            oItem.PricebookEntryId = entries[1].id;          
            oItem.OrderId = ord.id;
            insert oItem;
            
            OrderItem oItem2 = new OrderItem();
            oItem2.Product2Id = productMap.get('AccessKEY5').id;
            oItem2.Quantity = 1;
            oItem2.UnitPrice = 2000;
            oItem2.iHasco_Number_of_Users__c = 250;
            oItem2.PricebookEntryId = entries[1].id;          
            oItem2.OrderId = ord.id;
            oItem2.SBQQ__RequiredBy__c = oItem.id;
            insert oItem2;
            
            Test.stopTest();
            SBQQ__Subscription__c sb = new SBQQ__Subscription__c();
            sb.SBQQ__Contract__c = con.id;
            sb.SBQQ__Product__c = productMap.get('IH-RPM-1000').id;
            sb.SBQQ__Quantity__c = 1;
            sb.SBQQ__ListPrice__c = 2000; 
            insert sb; 
        }
        
    }
    
    @isTest static void testContract() {
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType];
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!conList.isEmpty()){
                for(Contract c : conList){
                    c.status = 'Active';
                }
                update conList;
            }
            Test.stopTest();
            System.assertEquals([select id,recordTypeId from contract].recordTypeId,contractRecordType);
        }
    }
    
    @isTest static void testContractCreditBased() {
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<product2> pList = new List<product2>();
            For(Product2 p : [select id, productcode from product2]){
                p.ProductCode = 'IHCBP';
                plist.add(p); 
            }
            update pList;
            
            List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType];
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!conList.isEmpty()){
                for(Contract c : conList){
                    c.status = 'Active';
                }
                update conList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testOrder() {
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!ordList.isEmpty()){
                for(Order c : ordList){
                    c.status = 'Activated';
                }
                update ordList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testOrderCreditBased() {
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<product2> pList = new List<product2>();
            For(Product2 p : [select id, productcode from product2]){
                p.ProductCode = 'IHCBP';
                plist.add(p); 
            }
            update pList;
            
            List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!ordList.isEmpty()){
                for(Order c : ordList){
                    c.status = 'Activated';
                }
                update ordList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testContractFailureTest() {
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType];
            MockHttpResponseGeneratorFailure mock = new MockHttpResponseGeneratorFailure();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!conList.isEmpty()){
                for(Contract c : conList){
                    c.status = 'Active';
                }
                update conList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testContractException() {
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType];
            
            MockHttpResponseGeneratorFailure mock = new MockHttpResponseGeneratorFailure();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            iHASCOLmsRestOutbound.raiseExceptionTestClass2 = true;
            if(!conList.isEmpty()){
                for(Contract c : conList){
                    c.status = 'Active';
                }
                update conList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testContractbadResponse() {
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<product2> pList = new List<product2>();
            For(Product2 p : [select id, productcode from product2]){
                p.ProductCode = 'IHCBP';
                plist.add(p); 
            }
            update pList;
            
            List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType];
            MockHttpResponseGeneratorFailure mock = new MockHttpResponseGeneratorFailure();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!conList.isEmpty()){
                for(Contract c : conList){
                    c.status = 'Active';
                }
                update conList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testContractFailure() {
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<product2> pList = new List<product2>();
            For(Product2 p : [select id, productcode from product2]){
                p.ProductCode = 'IHCBP';
                plist.add(p); 
            }
            update pList;
            
            List<Contract> conList = [SELECT id from Contract where recordTypeId = :contractRecordType];
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            iHASCOLmsRestOutbound.raiseExceptionTestClass1 = true;
            if(!conList.isEmpty()){
                for(Contract c : conList){
                    c.status = 'Active';
                }
                update conList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testOrderbadResponse() {
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
            MockHttpResponseGeneratorFailure mock = new MockHttpResponseGeneratorFailure();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!ordList.isEmpty()){
                for(Order c : ordList){
                    c.status = 'Activated';
                }
                update ordList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testOrderFailure1() {
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            iHASCOLmsRestOutbound.raiseExceptionTestClass1 = true;
            if(!ordList.isEmpty()){
                for(Order c : ordList){
                    c.status = 'Activated';
                }
                update ordList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testOrderFailure2() {
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Order> ordList = [SELECT id from Order where recordTypeId = :orderRecordType];
            MockHttpResponseGeneratorFailure mock = new MockHttpResponseGeneratorFailure();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            iHASCOLmsRestOutbound.raiseExceptionTestClass2 = true;
            if(!ordList.isEmpty()){
                for(Order c : ordList){
                    c.status = 'Activated';
                }
                update ordList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testAccountStatusFailure1(){
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Account> accList = [SELECT id from Account LIMIT 1];
            MockHttpResponseGeneratorFailure mock = new MockHttpResponseGeneratorFailure();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            iHASCOLmsRestOutbound.raiseExceptionTestClass1 = true;
            if(!accList.isEmpty()){
                for(Account c : accList){
                    c.iHASCO_Finance_Status__c = 'InActive';
                }
                update accList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testAccountStatus(){
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Account> accList = [SELECT id from Account LIMIT 1];
            MockHttpResponseGeneratorFailure mock = new MockHttpResponseGeneratorFailure();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!accList.isEmpty()){
                for(Account c : accList){
                    c.iHASCO_Finance_Status__c = 'InActive';
                }
                update accList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testAccountStatusFailure2(){
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Account> accList = [SELECT id from Account LIMIT 1];
            MockHttpResponseGeneratorFailure mock = new MockHttpResponseGeneratorFailure();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            iHASCOLmsRestOutbound.raiseExceptionTestClass2 = true;
            if(!accList.isEmpty()){
                for(Account c : accList){
                    c.iHASCO_Finance_Status__c = 'Active';
                }
                update accList;
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testCreditBasedPricing(){
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        List<Contract> conList = [SELECT id,Status from Contract where recordTypeId = :contractRecordType LIMIT 1]; 
        Map<String,product2> prodMap = new Map<String,product2>();
        for(PRODUCT2 prd :[SELECT ID,productcode from Product2]){
            prodMap.put(prd.productcode, prd);
        }
        
        System.runAs(iHASCOUser){
            SBQQ__Subscription__c sb = new SBQQ__Subscription__c();
            sb.SBQQ__Contract__c = conList[0]?.id;
            sb.SBQQ__Product__c = prodMap.get(Label.iHASCOUserBasedProduct).id;
            sb.SBQQ__Quantity__c = 1;
            sb.SBQQ__ListPrice__c = 2000; 
            insert sb; 
            
            SBQQ__Subscription__c sb2 = new SBQQ__Subscription__c();
            sb2.SBQQ__Contract__c = conList[0]?.id;
            sb2.SBQQ__Product__c = prodMap.get(Label.iHASCOCreditProductCode).id;
            sb2.SBQQ__Quantity__c = 1;
            sb2.SBQQ__ListPrice__c = 2000; 
            sb2.Ihasco_Number_of_Credits__c = 200;
            SB2.SBQQ__RequiredById__c = sb.id;
            insert sb2; 
            
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            
            Test.startTest();
            conList[0].Status = 'Active';
            update conList[0];
            Test.stopTest();
        }
        System.assertEquals('Success', [SELECT ID, LMS_payload_status__c FROM Contract where id = :conList[0].id].LMS_payload_status__c);
    }
    
    @isTest static void testCreditBasedPricingOrder(){
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        List<Account> accList = [SELECT id, (SELECT id from Orders) , (SELECT id from SBQQ__Quotes__r),(SELECT Id FROM Contacts) from Account where name = 'Test Acc']; 
        Map<String,PricebookEntry> prodMap = new Map<String,PricebookEntry>();
        for(PricebookEntry pbe :[SELECT id,Product2Id,Product2.productcode from PricebookEntry where Pricebook2.name =  'iHASCO']){
            prodMap.put(pbe.Product2.productcode, pbe);
        }
        Order ord = new Order();
        ord.AccountId = accList[0]?.Id;
        ord.SBQQ__Quote__c = accList[0]?.SBQQ__Quotes__r[0]?.id;
        ord.EffectiveDate = System.today();
        ord.CustomerAuthorizedById = accList[0]?.Contacts[0]?.id;
        ord.RecordTypeId = orderRecordType;
        ord.status = 'Draft';
        ord.Pricebook2Id = [SELECT Id FROM Pricebook2 where name = 'iHASCO']?.id;
        insert ord;
        
        OrderItem oItem = new OrderItem();
        oItem.Product2Id = prodMap.get(Label.iHASCOOpenLicensePricing).Product2Id;
        oItem.Quantity = 1;
        oItem.UnitPrice = 0;
        oItem.PricebookEntryId = prodMap.get(Label.iHASCOOpenLicensePricing).id;          
        oItem.OrderId = ord.id;
        insert oItem;
        
        OrderItem oItem2 = new OrderItem();
        oItem2.Product2Id = prodMap.get(Label.iHASCOCreditProductCode).Product2Id;
        oItem2.Quantity = 1;
        oItem2.UnitPrice = 2000;
        oItem2.iHasco_Number_of_Users__c = 250;
        oItem2.PricebookEntryId = prodMap.get(Label.iHASCOCreditProductCode).id;          
        oItem2.OrderId = ord.id;
        oItem2.SBQQ__RequiredBy__c = oItem.id;
        insert oItem2;
        System.runAs(iHASCOUser){
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            ord.status = 'Activated';
            update ord;
            Test.stopTest();
        } 
        System.assertEquals('Success', [SELECT ID, LMS_payload_status__c FROM Order where id = :Ord.id].LMS_payload_status__c);
    }
    
    @isTest static void checkDocumentStorageProducttoLMS(){
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        List<Account> accList = [SELECT id, (SELECT id from Orders) , (SELECT id from SBQQ__Quotes__r),(SELECT Id FROM Contacts) from Account where name = 'Test Acc']; 
        Map<String,PricebookEntry> prodMap = new Map<String,PricebookEntry>();
        for(PricebookEntry pbe :[SELECT id,Product2Id,Product2.productcode from PricebookEntry where Pricebook2.name =  'iHASCO']){
            prodMap.put(pbe.Product2.productcode, pbe);
        }
        Order ord = new Order();
        ord.AccountId = accList[0]?.Id;
        ord.SBQQ__Quote__c = accList[0]?.SBQQ__Quotes__r[0]?.id;
        ord.EffectiveDate = System.today();
        ord.CustomerAuthorizedById = accList[0]?.Contacts[0]?.id;
        ord.RecordTypeId = orderRecordType;
        ord.status = 'Draft';
        ord.Pricebook2Id = [SELECT Id FROM Pricebook2 where name = 'iHASCO']?.id;
        insert ord;
        
        OrderItem oItem = new OrderItem();
        oItem.Product2Id = prodMap.get(Label.iHASCOOpenLicensePricing).Product2Id;
        oItem.Quantity = 1;
        oItem.UnitPrice = 0;
        oItem.PricebookEntryId = prodMap.get('ASDS').id;          
        oItem.OrderId = ord.id;
        insert oItem;
        
        
        System.runAs(iHASCOUser){
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            ord.status = 'Activated';
            update ord;
            Test.stopTest();
        } 
        System.assertEquals('Success', [SELECT ID, LMS_payload_status__c FROM Order where id = :Ord.id].LMS_payload_status__c);
    }
    
    @isTest static void testUserBasedPricing(){
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        List<Contract> conList = [SELECT id,Status from Contract where recordTypeId = :contractRecordType LIMIT 1]; 
        Map<String,product2> prodMap = new Map<String,product2>();
        for(PRODUCT2 prd :[SELECT ID,productcode from Product2]){
            prodMap.put(prd.productcode, prd);
        }
        
        System.runAs(iHASCOUser){
            SBQQ__Subscription__c sb = new SBQQ__Subscription__c();
            sb.SBQQ__Contract__c = conList[0]?.id;
            sb.SBQQ__Product__c = prodMap.get(Label.iHASCOOpenLicensePricing).id;
            sb.SBQQ__Quantity__c = 1;
            sb.SBQQ__ListPrice__c = 2000; 
            insert sb; 
            
            SBQQ__Subscription__c sb2 = new SBQQ__Subscription__c();
            sb2.SBQQ__Contract__c = conList[0]?.id;
            sb2.SBQQ__Product__c = prodMap.get('AccessKEY5').id;
            sb2.SBQQ__Quantity__c = 1;
            sb2.SBQQ__ListPrice__c = 2000; 
            sb2.Ihasco_Number_of_Credits__c = 200;
            SB2.SBQQ__RequiredById__c = sb.id;
            insert sb2; 
            
            
            
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            
            conList[0].Status = 'Active';
            update conList[0];
            
            SBQQ__Subscription__c sb3 = new SBQQ__Subscription__c();
            sb3.SBQQ__Contract__c = conList[0]?.id;
            sb3.SBQQ__Product__c = prodMap.get('AccessKEY5').id;
            sb3.SBQQ__RevisedSubscription__c = sb2.id;
            sb3.SBQQ__Quantity__c = 1;
            sb3.SBQQ__ListPrice__c = 3000; 
            sb3.Ihasco_Number_of_Credits__c = 200;
            SB3.SBQQ__RequiredById__c = sb.id;
            insert sb3;
            
            conList[0].Status = 'In Amendment';
            update conList[0];
            
            Test.startTest();
            conList[0].Status = 'Active';
            update conList[0];
            Test.stopTest();
        }
        System.assertEquals('Success', [SELECT ID, LMS_payload_status__c FROM Contract where id = :conList[0].id].LMS_payload_status__c);
    } 
    
    @isTest static void testLMSTriggeringOnAccountOwnerChange(){
        
        User iHASCOUser2 = bg_User_TestUtils.createQMSSalesUser('123462341');
        iHASCOUser2.profileid=[select id from Profile where name='iHASCO NBM'].id;
        iHASCOUser2.Division ='iHASCO';
        insert iHASCOUser2;
        
        User iHASCOUser =[select id from USER where Division='iHASCO' AND LastName = 'iHASCOLmsRestOutboundTest' LIMIT 1];
        system.runAs(iHASCOUser){
            List<Account> accList = [SELECT id from Account LIMIT 1];
            MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            if(!accList.isEmpty()){
                for(Account c : accList){
                    c.iHASCO_Account_Manager__c = iHASCOUser2.id;
                }
                update accList;
            }
            Test.stopTest();
        }    
    }
    
    
    global class MockHttpResponseGenerator implements HttpCalloutMock {
        
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            System.debug('mock req: ' + req);
            
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"response":{"status":ok}}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
        
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            System.debug('mock req: ' + req);
            
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"response":{"status":ok}}]');
            res.setStatusCode(404);
            return res;
        }   
    }
    
    private static product2 createProduct(String pName,String pCode,Boolean isSubscriptionBased,String BillingFrequency){
        Product2 p = new Product2();
        p.Name = pName;
        p.ProductCode = pCode;
        p.IsActive = True;
        if(isSubscriptionBased){
            p.SBQQ__SubscriptionType__c = 'Renewable';
            p.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        }
        P.SBQQ__BillingFrequency__c =BillingFrequency;
        return p;
    }
    
}