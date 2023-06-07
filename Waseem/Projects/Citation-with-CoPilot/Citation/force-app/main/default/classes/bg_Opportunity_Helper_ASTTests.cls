@isTest
private class bg_Opportunity_Helper_ASTTests {
	

	@testSetup static void setup() {
		account acc = new account(name = 'test account',AnnualRevenue=10 ) ;
		insert acc ;		
		//UserRole r = [select id,name from userrole where name = 'Add-On Sales'] ;
		//User u = [select id from user where id = :string.valueOf(System.label.AST_Consultant) ];	
		//List<User>ActiveAddOnUsers = [select id from User where IsActive = true and UserRoleId = :r.id] ;
		//ActiveAddOnUsers.add(u) ;
		
	}
    
    /*
    static testMethod void TestAddsAllASTPeople() {
    	account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(pricebook2id=Test.getStandardPricebookId(),amount=9000,accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(), leadSource = 'Ref_Employee',deal_type__c = 'Add-On' );
		
		test.starttest() ;
		insert Opp ;
		
		test.stoptest() ;
		
		Opportunity CheckOpp = [select id, (select id,userid, teammemberRole from OpportunityTeamMembers) from opportunity where id = :Opp.id] ;
		UserRole r = [select id,name from userrole where name = 'Add-On Sales'] ;
		User u = [select id from user where id = :string.valueOf(System.label.AST_Consultant) ];	
		List<User>ActiveAddOnUsers = [select id,firstname,lastname from User where IsActive = true and UserRoleId = :r.id] ;
		ActiveAddOnUsers.add(u) ;
        
		system.assertEquals(ActiveAddOnUsers.size() +1,CheckOpp.OpportunityTeamMembers.size()) ;
        // TO DO: implement unit test
        
    }
    
  
    
    static testMethod void TestAddsAllASTPeople_RunAsASTUser() {
    	account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(pricebook2id=Test.getStandardPricebookId(),amount=9000,accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(), leadSource = 'Ref_Employee',deal_type__c = 'Add-On' );
		User u = [select id from user where id = :string.valueOf(System.label.AST_Consultant) ];	
		
		test.starttest() ;
        system.runas(u) {
			insert Opp ;
		}
		test.stoptest() ;
		
		Opportunity CheckOpp = [select id,ownerid, (select id,userid, teammemberRole from OpportunityTeamMembers) from opportunity where id = :Opp.id] ;
		UserRole r = [select id,name from userrole where name = 'Add-On Sales'] ;
				List<User>ActiveAddOnUsers = [select id,firstname,lastname from User where IsActive = true and UserRoleId = :r.id] ;
		ActiveAddOnUsers.add(u) ;
        for(user au : ActiveAddOnUsers) {
            system.debug(au) ;
        }
        
        for(OpportunityTeamMember otm :CheckOpp.OpportunityTeamMembers)  {
            system.debug(otm) ;
            
        }
		system.assertEquals(ActiveAddOnUsers.size()+1,CheckOpp.OpportunityTeamMembers.size()) ;
        system.assertEquals(string.valueOf(System.label.AST_Opportunity_Holding_User), checkopp.ownerid) ;
        
        
    }
    */

}