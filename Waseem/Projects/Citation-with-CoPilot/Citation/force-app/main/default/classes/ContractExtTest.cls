/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ContractExtTest{

     @testSetup static void setup()
    {
         Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;
      
      
        recordtype rt = [select id from recordtype where name = 'Quote Locked' and sobjecttype = 'SBQQ__Quote__c' ] ;
      
        
         Account testAccount = createAccount('TestAccount','PROFESSIONAL ACTIVITIES',6,1);
         
         
        contract c = new contract(accountid=testaccount.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0, startdate = date.today() , Agreement_Type__c = 'Auto') ;
        insert c ;
        
            opportunity opp = new opportunity(name = 'test',stagename = 'Appointment',closedate = date.today(), accountid = testaccount.id) ;
        insert opp ;
        
            sbqq__quote__c q = new sbqq__quote__c(sbqq__account__c = testaccount.id,SBQQ__Opportunity2__c = opp.id, contract__c = c.id, recordtypeid = rt.id ) ;
            insert q ;
            
            
            
        
    }
    
    
    
    
    private static Account createAccount(String accName, String sector, Decimal fullTimeEmployees, Decimal partTimeEmployees)
    {
        Account acc = new Account();
        acc.Name = accName;
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;
        acc.CitationSector__c = sector;
        acc.FT_Employees__c = fullTimeEmployees;
        acc.PT_Employees__c = partTimeEmployees;
        
        insert acc;
        return acc;     
    }
    
    static testMethod void Test1() {
        contract c = [select id, accountid,startdate, enddate from contract limit 1] ;
        ContractExt ext1 = new ContractExt(new ApexPages.StandardController(c)) ;
        ext1.cancelcontract() ;
        
    }
    
     
        
        
}