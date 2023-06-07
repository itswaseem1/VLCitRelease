@isTest
private class QuoteBannerExtensionTest{
    
    @testSetup static void setup()
    {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;

        Product2 product = new Product2(Name='Fire Risk Assessment', ProductCode='FRAREF', Invalid_CPQ_Product__c = true); 
        insert product;     
      
        recordtype rt = [select id from recordtype where name = 'Quote Locked' and sobjecttype = 'SBQQ__Quote__c' ] ;
      
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = 'PROFESSIONAL ACTIVITIES';
        acc.FT_Employees__c = 6;
        acc.PT_Employees__c = 1;
        
        insert acc;
         
        contract c = new contract(accountid=acc.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0, startdate = date.today() , Agreement_Type__c = 'Auto') ;
        insert c ;
        
        opportunity opp = new opportunity(name = 'test',stagename = 'Appointment',closedate = date.today(), accountid = acc.id) ;
        insert opp ;
        
        sbqq__quote__c q = new sbqq__quote__c(sbqq__account__c = acc.id,SBQQ__Opportunity2__c = opp.id, contract__c = c.id, recordtypeid = rt.id ) ;
        insert q ;
        
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c( SBQQ__Quote__c = q.Id, SBQQ__Product__c = product.Id );
        Test.startTest();
        insert ql;
        Test.stopTest();
        
    }
    
    
    static testMethod void testGetHasInvalidProduct(){
        System.assertEquals([select count() from sbqq__quote__c], 1);
        System.assertEquals([select count() from SBQQ__QuoteLine__c], 1);
        sbqq__quote__c quote = [select Id from sbqq__quote__c limit 1];

        Test.startTest();
        QuoteBannerExtension qbe = new QuoteBannerExtension(new ApexPages.StandardController(quote));
        System.assertEquals(qbe.getHasInvalidProduct(), true);
        Test.stopTest();
    }
    
}