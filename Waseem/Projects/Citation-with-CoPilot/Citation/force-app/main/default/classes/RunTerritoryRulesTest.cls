@isTest
public class RunTerritoryRulesTest {
	
    static testmethod void TestTerritory(){
 /*       Account acc = new Account();
        acc.Name = 'accName';
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.BillingPostalCode = 'AZ1 ABC';
        acc.ShippingPostalCode = 'AZ1 ABC';
        ACC.MACV__c = 180;
      //acc.Number_of_Active_Sites__c = 1;
        acc.Sites__c = 1;
        
        insert acc; */
        
        Set<String> IdSet = new Set<String>();
     //   IdSet.add(acc.id);
   //  	test.setMock(HttpCalloutMock.class, new RunTerritoryMock());
        RunTerritoryRules  job = new RunTerritoryRules() ;
     //   job.isTest = true;
        job.accntIds = IdSet; 
        Test.startTest();
        
        RunTerritoryRules.TestCoverage();
        Test.stoptest();
    }
}