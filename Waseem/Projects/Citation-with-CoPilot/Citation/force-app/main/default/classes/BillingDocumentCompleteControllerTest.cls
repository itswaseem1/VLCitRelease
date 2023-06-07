@isTest
public class BillingDocumentCompleteControllerTest {
    
    @testSetup 
    static void setup()
    {
        Account acc = new Account(Name='test', c2g__CODAInvoiceEmail__c = 'test@test.com') ;
        insert acc;
        
        fferpcore__Company__c comp = new fferpcore__Company__c(Name='QMS International Limited');
        insert comp;
        
        ffbc__contract__c cont = new ffbc__contract__c(CustomerReference__c = 'TestRef', ffbc__account__c = acc.Id, ffbc__company__c = comp.Id) ;
        insert cont;
        
        fferpcore__BillingDocument__c billDoc = new fferpcore__BillingDocument__c(ffbc__Contract__c = cont.Id, fferpcore__Account__c=acc.Id,
                                                                                  fferpcore__DocumentType__c='Invoice',
                                                                                  fferpcore__DocumentStatus__c='Draft', fferpcore__Company__c =comp.Id);
        insert billDoc;
        
        Product2 product = new Product2(Name = 'tst');
        insert product;

        fferpcore__BillingDocumentLineItem__c billingDocumentLineItem = new fferpcore__BillingDocumentLineItem__c();
        billingDocumentLineItem.fferpcore__ProductService__c = product.Id;
        billingDocumentLineItem.fferpcore__UnitPrice__c = 32;
        billingDocumentLineItem.fferpcore__Quantity__c = 1;
        billingDocumentLineItem.fferpcore__BillingDocument__c = billDoc.Id;
        insert billingDocumentLineItem;
        
        BatchApexController__c setting = new BatchApexController__c(Name = 'BulkBillingDocumentCompleteBatch', Batch_size__c = 10);
        insert setting;
        
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId())) {
            queuesobject companyQueueSobject = new queuesobject (queueid=testGroup.Id, sobjecttype='c2g__codaCompany__c'); 
            insert  companyQueueSobject;
            
            GroupMember GroupMemberObj = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = UserInfo.getUserId());
            insert GroupMemberObj;
        } 
        
        c2g__codaCompany__c company = new c2g__codaCompany__c(Name = 'QMS International Limited', c2g__CashMatchingCurrencyMode__c = 'Test Account',
                                                              c2g__YearEndMode__c = 'Test Code', c2g__ExternalId__c = 'ABCDE1234567876',
                                                              c2g__LogoURL__c ='www.XYZ.com', c2g__ECCountryCode__c = 'GBP', 
                                                              c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA', c2g__Website__c = 'www.xyz.com',
                                                              c2g__Country__c ='UK', ownerid = testGroup.Id);
        
        insert company;
        
        c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c(c2g__Company__c =company.Id, c2g__User__c = userInfo.getUserId(),
                                                                          c2g__ExternalId__c = 'ABCDE1234567876', c2g__UnitOfWork__c = 111);
        insert  userCompany;
    }
    
    @isTest
    static void whenBillingDocsSelected_ProcessRecordsSyncronously() 
    {
        List<fferpcore__BillingDocument__c> billDocList = [SELECT Id,fferpcore__DocumentStatus__c FROM fferpcore__BillingDocument__c];
        
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(billDocList);
        stdSetController.setSelected(billDocList);
        BillingDocumentCompleteController ext = new BillingDocumentCompleteController(stdSetController);
        ext.onSave();
        Test.stopTest();
        
        List<fferpcore__BillingDocument__c> billDocList1 = [SELECT Id,fferpcore__DocumentStatus__c FROM fferpcore__BillingDocument__c];
    }
    
    @isTest
    static void whenNoBillingDocsSelected_ProcessRecordsAsyncronously() 
    {
        List<fferpcore__BillingDocument__c> billDocList = new List<fferpcore__BillingDocument__c>();
        
		Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(billDocList);
        stdSetController.setSelected(billDocList);
        BillingDocumentCompleteController ext = new BillingDocumentCompleteController(stdSetController);
        ext.onSave();
        Test.stopTest();
        
        List<fferpcore__BillingDocument__c> billDocList1 = [SELECT Id,fferpcore__DocumentStatus__c FROM fferpcore__BillingDocument__c];
    }
}