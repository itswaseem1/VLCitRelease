@isTest
private class TriggerOpportunityHandler_ReferralsTests {

	 @testSetup static void setup() {
	 	
	 	pricebook2 pb = new pricebook2(name='Term Referrals Pricebook',isactive=true,Annual_Turnover_Minimum__c = 0, Annual_Turnover_Maximum__c = 50) ;
	  	insert pb ;
	  	product2 p1 = new product2(name = 'TESTER1', productcode = 'PELX') ;
	  	insert p1 ;
         
        Pricebook2 qmsNewPB = new PriceBook2(Name = 'QMS CPQ');
        insert qmsNewPB;
	  	
	  	pricebookentry pbestd1 = new pricebookentry(pricebook2id =Test.getStandardPricebookId(), unitprice = 100, product2id = p1.id, isactive = true) ;
	  	insert pbestd1 ;
	  	
	  	pricebookentry pbe1 = new pricebookentry(pricebook2id = pb.id, unitprice = 100, product2id=p1.id, isactive = true ) ;
	  	insert pbe1 ;
	  	
	  	
	  	
	  	product2 p2 = new product2(name = 'TESTER2', productcode = 'PEL') ;
	  	insert p2 ;
	  	
	  	pricebookentry pbestd2 = new pricebookentry(pricebook2id =Test.getStandardPricebookId(), unitprice = 100, product2id = p2.id, isactive = true) ;
	  	insert pbestd2 ;
	  	
	  	pricebookentry pbe2 = new pricebookentry(pricebook2id = pb.id, unitprice = 100, product2id=p2.id, isactive = true ) ;
	  	insert pbe2 ;
         
         product2 p3 = new product2(name = 'TESTER zero', productcode = 'TSTZ') ;
	  	insert p3 ;
	  	
	  	pricebookentry pbestd3 = new pricebookentry(pricebook2id =Test.getStandardPricebookId(), unitprice = 100, product2id = p3.id, isactive = true) ;
	  	insert pbestd3 ;
	  	
	  	pricebookentry pbe3 = new pricebookentry(pricebook2id = pb.id, unitprice = 100, product2id=p3.id, isactive = true ) ;
	  	insert pbe3 ;
	  
	 	account acc = new account(name = 'test account',AnnualRevenue=10 ) ;
		insert acc ;

		list<product2> pList = new list<product2>() ;
		//plist.add( new product2(name='test', productcode = 'HS-Compliance', referral_product__C = true , lead_payment__c = 10, deal_payment__c = 300) ) ;
		//plist.add( new product2(name='test', productcode = 'PEL', referral_product__C = true , lead_payment__c = 15, deal_payment__c = 200) ) ;
		
		//insert plist ;
		//

  		Referral_Payment__c refX = new Referral_Payment__c() ;
		refX.name = 'PELX' ;
		refX.lead_payment__C = 5 ;
		refX.deal_payment__c = 10 ;
		insert refX ;
		
		Referral_Payment__c refX2 = new Referral_Payment__c() ;
		refX2.name = 'PEL2X' ;
		refX2.lead_payment__C = 5 ;
		refX2.deal_payment__c = 20 ;
		insert refX2 ;
		
		Referral_Payment__c refX3 = new Referral_Payment__c() ;
		refX3.name = 'PEL3X' ;
		refX3.lead_payment__C = 5 ;
		refX3.deal_payment__c = 30 ;
		insert refX3 ;
		
		Referral_Payment__c refX4 = new Referral_Payment__c() ;
		refX4.name = 'PEL4X' ;
		refX4.lead_payment__C = 6 ;
		refX4.deal_payment__c = 40 ;
		insert refX4 ;
		
		
		Referral_Payment__c ref = new Referral_Payment__c() ;
		ref.name = 'PEL' ;
		ref.lead_payment__C = 15 ;
		ref.deal_payment__c = 100 ;
		insert ref ;
		
		Referral_Payment__c ref2 = new Referral_Payment__c() ;
		ref2.name = 'PEL2' ;
		ref2.lead_payment__C = 15 ;
		ref2.deal_payment__c = 200 ;
		insert ref2 ;
		
		Referral_Payment__c ref3 = new Referral_Payment__c() ;
		ref3.name = 'PEL3' ;
		ref3.lead_payment__C = 15 ;
		ref3.deal_payment__c = 300 ;
		insert ref3 ;
		
		Referral_Payment__c ref4 = new Referral_Payment__c() ;
		ref4.name = 'PEL4' ;
		ref4.lead_payment__C = 16 ;
		ref4.deal_payment__c = 400 ;
		insert ref4 ;
		
	 Referral_Payment__c refzero = new Referral_Payment__c() ;
		refzero.name = 'TSTZ' ;
		refzero.lead_payment__C = 0 ;
		refzero.deal_payment__c = 0 ;
		insert refzero ;
	 }


	static testmethod void Test_Opportunity_Update() {
		system.debug('Begin TEST') ;
		account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(ReferringEmployeelookup__c = userinfo.getuserid(),Referral_Deal_Paid__c = 'No',Referral_Lead_Paid__c = 'No',pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(), Interested_Products__c = 'PEL,HS-Compliance', leadSource = 'Ref_Employee' );
		
		insert Opp ;
		
		
		product2 p = [select id from product2 WHERE name = 'TESTER2'] ;
		
		pricebookentry pbe = [select id from pricebookentry where product2id = :p.id and pricebook2id <> :Test.getStandardPricebookId() limit 1] ;
		OpportunityLineItem op = new OpportunityLineItem(pricebookentryid=pbe.id,opportunityid = opp.id, product2id=p.id, quantity=50,unitprice=200) ;
		insert op ;
		
		
		
		test.starttest() ;
		
		test.stoptest() ;
		
		opportunity CheckOpp = [select id,name, referral_lead_payment__c, referral_deal_payment__c, amount from opportunity where id = :opp.id] ;
		system.assertEquals(16,CheckOpp.referral_lead_payment__C) ;
		system.assertEquals(400,CheckOpp.referral_deal_payment__c) ;
		system.debug(CheckOpp.amount) ;
		
		
		
	}
	
	
	static testmethod void Test_Opportunity_DoesNotUpdate_DealNotRequired() {
		system.debug('Begin TEST') ;
		account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(ReferringEmployeelookup__c = userinfo.getuserid(),Referral_Deal_Paid__c='Not Required',Referral_Lead_Paid__c='No',referral_deal_payment__C=1,pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(), Interested_Products__c = 'PEL,HS-Compliance', leadSource = 'Ref_Employee' );
		
		insert Opp ;
		
	
		product2 p = [select id from product2 WHERE name = 'TESTER2'] ;
		pricebookentry pbe = [select id from pricebookentry  where product2id = :p.id and pricebook2id <> :Test.getStandardPricebookId() limit 1] ;
		OpportunityLineItem op = new OpportunityLineItem(pricebookentryid=pbe.id,opportunityid = opp.id, product2id=p.id, quantity=50,unitprice=200) ;
		insert op ;
		
		
		
		test.starttest() ;
		
		test.stoptest() ;
		
		opportunity CheckOpp = [select id,name, referral_lead_payment__c, referral_deal_payment__c,Referral_Deal_Paid__c, amount from opportunity where id = :opp.id] ;
		system.assertEquals(16,CheckOpp.referral_lead_payment__C) ;
		system.assertEquals(1,CheckOpp.referral_deal_payment__c) ;
       // system.assertEquals('Not Required',CheckOpp.Referral_Deal_Paid__c) ;
		system.debug(CheckOpp.amount) ;
		
		
		
	}
	
	static testmethod void Test_Opportunity_DoesNotUpdate_LeadNotRequired() {
		system.debug('Begin TEST') ;
		account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(ReferringEmployeelookup__c = userinfo.getuserid(),Referral_Deal_Paid__c='No',Referral_Lead_Paid__c='Not Required',referral_lead_payment__C=1,pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(),  leadSource = 'Ref_Employee' );
		
		insert Opp ;
		
		
		product2 p = [select id from product2 WHERE name = 'TESTER2'] ;
		pricebookentry pbe = [select id from pricebookentry  where product2id = :p.id and pricebook2id <> :Test.getStandardPricebookId()  limit 1] ;
		OpportunityLineItem op = new OpportunityLineItem(pricebookentryid=pbe.id,opportunityid = opp.id, product2id=p.id, quantity=50,unitprice=200) ;
		insert op ;
		
		
		
		test.starttest() ;
		
		test.stoptest() ;
		
		opportunity CheckOpp = [select id,name, referral_lead_payment__c, referral_deal_payment__c, amount,Referral_Deal_Paid__c,Referral_Lead_Paid__c from opportunity where id = :opp.id] ;
		system.assertEquals(1,CheckOpp.referral_lead_payment__C) ;
        system.assertEquals('Not Required',CheckOpp.Referral_LEad_Paid__c) ;
		system.assertEquals(400,CheckOpp.referral_deal_payment__c) ;
		system.debug(CheckOpp.amount) ;
		
		
		
	}
    
    
    static testmethod void Test_Opportunity_QualifyingWithZeroPayments() {
		system.debug('Begin TEST') ;
		account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(ReferringEmployeelookup__c = userinfo.getuserid(),Referral_Deal_Paid__c='No',Referral_Lead_Paid__c='No',pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(),  leadSource = 'Ref_Employee' );
		
		insert Opp ;
		
		
		product2 p = [select id from product2 WHERE name = 'TESTER zero'] ;
		pricebookentry pbe = [select id from pricebookentry  where product2id = :p.id and pricebook2id <> :Test.getStandardPricebookId()  limit 1] ;
		OpportunityLineItem op = new OpportunityLineItem(pricebookentryid=pbe.id,opportunityid = opp.id, product2id=p.id, quantity=50,unitprice=200) ;
		insert op ;
		
		
		
		test.starttest() ;
		
		test.stoptest() ;
		
		opportunity CheckOpp = [select id,name, referral_lead_payment__c, referral_deal_payment__c, amount,Referral_LEad_Paid__c,Referral_Deal_Paid__c from opportunity where id = :opp.id] ;
		system.assertEquals(0,CheckOpp.referral_lead_payment__C) ;
		system.assertEquals(0,CheckOpp.referral_deal_payment__c) ;
        
        //system.assertEquals('Not Required',CheckOpp.Referral_LEad_Paid__c) ;
		//system.assertEquals('Not Required',CheckOpp.Referral_Deal_Paid__c) ;
		system.debug(CheckOpp.amount) ;
		
		
		
	}
	
	
	static testmethod void Test_Opportunity_Update_Skips_QMSRecordType() {
		system.debug('Begin TEST') ;
		account acc = [select id from account limit 1] ;
		RecordType rt = [Select id from recordtype where name = 'QMS' and SobjectType = 'Opportunity'] ;
		Pricebook2 pb=[Select Id From Pricebook2 where Name='QMS CPQ'];
        Opportunity Opp = new Opportunity(Contract_Length_Years__c=3,Contract_Length_Months__c = 36,Sites__c=1,term__c = '3',recordtypeid=rt.id,ReferringEmployeelookup__c = userinfo.getuserid(),Referral_Deal_Paid__c = 'No',Referral_Deal_Payment__C=50,Referral_Lead_Paid__c = 'No',pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(), Interested_Products__c = 'PEL,HS-Compliance', leadSource = 'Ref_Employee' );
		opp.Pricebook2Id =pb.id;
		insert Opp ;
		
		
		product2 p = [select id from product2 WHERE name = 'TESTER2'] ;
		
		pricebookentry pbe2 = new pricebookentry(pricebook2id = pb.id, unitprice = 100, product2id=p.id, isactive = true ) ;
	  	insert pbe2 ;
        OpportunityLineItem op = new OpportunityLineItem(pricebookentryid=pbe2.id,opportunityid = opp.id, product2id=p.id, quantity=50,unitprice=200) ;
		insert op ;
		
		
		
		test.starttest() ;
		
		test.stoptest() ;
		
		opportunity CheckOpp = [select id,name, referral_lead_payment__c, referral_deal_payment__c, amount from opportunity where id = :opp.id] ;
		system.assertEquals(null,CheckOpp.referral_lead_payment__C) ;
		system.assertEquals(50,CheckOpp.referral_deal_payment__c) ;
		system.debug(CheckOpp.amount) ;
		
		
		
	}
	
	static testmethod void Test_Opportunity_Update_EmployeeAndClient() {
		system.debug('Begin TEST') ;
		account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(ReferringEmployeelookup__c = userinfo.getuserid(),Referral_Deal_Paid__c = 'No',Referral_Lead_Paid__c = 'No',pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(), Interested_Products__c = 'PEL,HS-Compliance', leadSource = 'Ref_Employee_&_Client' );
		
		insert Opp ;
		
		
		product2 p = [select id from product2 WHERE name = 'TESTER2'] ;
		
		pricebookentry pbe = [select id from pricebookentry where product2id = :p.id and pricebook2id <> :Test.getStandardPricebookId() limit 1] ;
		OpportunityLineItem op = new OpportunityLineItem(pricebookentryid=pbe.id,opportunityid = opp.id, product2id=p.id, quantity=50,unitprice=200) ;
		
		
		
		
		test.starttest() ;
		insert op ;
		
		test.stoptest() ;
		
		opportunity CheckOpp = [select id,name, referral_lead_payment__c, referral_deal_payment__c, amount from opportunity where id = :opp.id] ;
		system.assertEquals(16,CheckOpp.referral_lead_payment__C) ;
		system.assertEquals(400,CheckOpp.referral_deal_payment__c) ;
		system.debug(CheckOpp.amount) ;	
		
		
	}
	
	static testmethod void Test_Opportunity_Update_Recalculate_ToBlank() {
		system.debug('Begin TEST') ;
		account acc = [select id from account limit 1] ;
		Opportunity Opp = new Opportunity(ReferringEmployeelookup__c = userinfo.getuserid(),Referral_Deal_Paid__c = 'No',Referral_Lead_Paid__c = 'No',pricebook2id=Test.getStandardPricebookId(),amount=9000,Contract_Length_Mths__c='24',accountid = acc.id,Name = 'Test Account Update' , isConverted__c = false,StageName = 'Qualified', CloseDate = System.Today(), Interested_Products__c = 'PEL,HS-Compliance', leadSource = 'Ref_Employee_&_Client' );
		
		insert Opp ;
		
		
		product2 p = [select id from product2 WHERE name = 'TESTER2'] ;
		
		pricebookentry pbe = [select id from pricebookentry where product2id = :p.id and pricebook2id <> :Test.getStandardPricebookId() limit 1] ;
		OpportunityLineItem op = new OpportunityLineItem(pricebookentryid=pbe.id,opportunityid = opp.id, product2id=p.id, quantity=50,unitprice=200) ;
		insert op ;
		
		
		
		test.starttest() ;
		delete op ;
		
		test.stoptest() ;
		
		opportunity CheckOpp = [select id,name, referral_lead_payment__c, referral_deal_payment__c, amount from opportunity where id = :opp.id] ;
		//system.assertEquals(null,CheckOpp.referral_lead_payment__C) ;
		//system.assertEquals(null,CheckOpp.referral_deal_payment__c) ;
		system.debug(CheckOpp.amount) ;	
		
		
	}
	
	/*  need to test not updating a record which has been paid - for referral lead paid*/
	
	/*  need to test not updating a record which has been paid - for referral deal paid */
	
		/*  need to test updating a record which has been paid for one but not the other */   
}