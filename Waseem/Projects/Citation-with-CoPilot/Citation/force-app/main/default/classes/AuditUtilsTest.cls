@isTest
private class AuditUtilsTest {
	
	 @testSetup static void setup() {
         
         Audit_Trace__c tr = new Audit_Trace__c() ;
         tr.name = userinfo.getuserid() ;
         insert tr;
	 	
	 	pricebook2 pb = new pricebook2(name='tst',isactive=true,Annual_Turnover_Minimum__c = 0, Annual_Turnover_Maximum__c = 50) ;
	  	insert pb ;	  	
	  
	 	account acc = new account(name = 'test account' ) ;
		insert acc ;		
	 
	 }
	 

    static testMethod void Test_Insert_Opp() {
        // TO DO: implement unit test
        account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(Description = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890',pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today() );
		test.starttest() ;
		insert Opp ;
		test.stoptest() ;
		list<Audit_Log__c> logs = [select id from audit_log__c] ;
		
		system.assertNotEquals(0,logs.size()) ;
		
        
    }
    
     static testMethod void Test_Update_Opp() {
        // TO DO: implement unit test
        account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(Description = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890',pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today() );
		
		insert Opp ;
		test.starttest() ;
		opp.amount = 8000 ;
		update opp ;
		test.stoptest() ;
			list<Audit_Log__c> logs = [select id from audit_log__c] ;
		
		system.assertNotEquals(0,logs.size()) ;
        
    }
    
    static testMethod void Test_Insert_Lead() {
    	Lead l = new lead(lastname = 'Test', company = 'Bob',Description = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890') ;
    	
    	test.starttest() ;
    	insert l ;
    	test.stoptest() ;
    		list<Audit_Log__c> logs= [select id from audit_log__c] ;
		
		system.assertNotEquals(0,logs.size()) ;
    }
    
    
    
    static testMethod void Test_Update_Lead() {
    	Lead l = new lead(lastname = 'Test', company = 'Bob',description = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890') ;
    	insert l ;
    	
    	test.starttest() ;
    	l.lastname = 'test2' ;
    	update l ;
    	test.stoptest() ;
    		list<Audit_Log__c> logs = [select id from audit_log__c] ;
		
		system.assertNotEquals(0,logs.size()) ;
    	
    }
    
}