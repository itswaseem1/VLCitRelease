@isTest
private class TriggerEventHandler_Test {
	/*
	This test class is primaily for validating the event handler functionality to fix the event subject line.
	For other/previous event handler tests, check event_trigger_test.
	 
	*/
	
	 @testSetup static void setup()
	{
	  Features__c f = new features__c(name='Default') ;
	  insert f ;
	  
	  pricebook2 pb = new pricebook2(name='tst',isactive=true,Annual_Turnover_Minimum__c = 0, Annual_Turnover_Maximum__c = 50) ;
	  insert pb ;
		
	}

    static testMethod void TestSubjectLineUpdates_TakeFromEventAndLead() {
    
	    	Lead L = new lead(postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Open', bdc__c = userinfo.getuserid()) ;
	    	Insert L ;
	    	
	    	test.starttest() ;
	    	Event e = new Event(whoid = L.id,durationinminutes=10, activitydatetime = system.now().adddays(1), subject = 'Test', event_status__c  = 'Confirmed', Type='1st Visit') ;
	    	insert e ;
	    	
	    	test.stoptest() ;
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'S42 6FG' + '|' + 'Acme Ltd' + '|' + 'Confirmed' + '|' + 'Inbound - 1';
	    	
	    	system.assertEquals(ExpectedSubjectLine,eTest.subject) ;
    	}
    	
    	
	   	static testMethod void TestSubjectLineUpdates_TakeEventPostcode() {
	   		Lead L = new lead(lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Open', bdc__c = userinfo.getuserid()) ;
	    	Insert L ;
	    	
	    	
	    	
	    	test.starttest() ;
	    	Event e = new Event(whoid = L.id,durationinminutes=10, activitydatetime = system.now().adddays(1), subject = 'Test', event_status__c  = 'Confirmed',post_code__c = 'S72 7AB', Type='1st Visit') ;
	    	insert e ;
	    	
	    	test.stoptest() ;
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'S72 7AB' + '|' + 'Acme Ltd' + '|' + 'Confirmed' + '|' + 'Inbound - 1';
	    	
	    	system.assertEquals(ExpectedSubjectLine,eTest.subject) ;
	   		
	   	}
	   	
	   		static testMethod void TestSubjectLineUpdates_TakeAccountPostcodeAndOppName() {
	   		Lead L = new lead(lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Open', bdc__c = userinfo.getuserid()) ;
	    	Insert L ;
	    	
	    	Account a = new account(name='Test',billingpostalcode = 'DL7 8RW', post_code__c = 'DL7 8RW') ;
	    	insert a ;
	    	Opportunity o = new Opportunity(accountid = a.id,name='TestOpp', made_criteria__c = 'Inbound - 1', closedate = date.today().adddays(5), stagename = 'Open') ;
	    	insert o ;
	    	
	    	
	    	
	    	test.starttest() ;
	    	Event e = new Event(durationinminutes=10, activitydatetime = system.now().adddays(1), subject = 'Test', event_status__c  = 'Confirmed', whatid = o.id, Type='1st Visit') ;
	    	insert e ;
	    	
	    	test.stoptest() ;
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'DL7 8RW' + '|' + 'TestOpp' + '|' + 'Confirmed' + '|' + 'Inbound - 1';
	    	
	    	//system.assertEquals(ExpectedSubjectLine,eTest.subject) ;
	   		
	   	}
	   	
	   		static testMethod void TestSubjectLineUpdates_TakeAccountPostcodeAndOppNameAndStatus() {
	   		Lead L = new lead(lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Open', bdc__c = userinfo.getuserid()) ;
	    	Insert L ;
	    	
	    	Account a = new account(name='Test',billingpostalcode = 'DL7 8RW', post_code__c = 'DL7 8RW') ;
	    	insert a ;
	    	Opportunity o = new Opportunity(accountid = a.id,name='TestOpp', made_criteria__c = 'Inbound - 1', closedate = date.today().adddays(5), stagename = 'Open', Type='1st Visit') ;
	    	insert o ;
	    	
	    	
	    	
	    	test.starttest() ;
	    	Event e = new Event(durationinminutes=10, activitydatetime = system.now().adddays(1), subject = 'Test',  whatid = o.id, Type='1st Visit');
	    	insert e ;
	    	
	    	test.stoptest() ;
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'DL7 8RW' + '|' + 'TestOpp' + '|' + 'Approved' + '|' + 'Inbound - 1';
	    	
	    	//system.assertEquals(ExpectedSubjectLine,eTest.subject) ;
	   		
	   	}
	   	
	   	 static testMethod void TestSubjectLineUpdates_TakeEventStatus() {
    
	    	Lead L = new lead( email= 'test@citation.co.uk',salutation = 'Mr',Street='Test Street',position__c='Boss',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',appointment_type__c = 'H&S',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Data Quality', bdc__c = userinfo.getuserid(), Visit_Type__c = 'Virtual') ;
	    	Insert L ;
	    	
	    	test.starttest() ;
	    	Event e = new Event(whoid = L.id,durationinminutes=10, activitydatetime = system.now().adddays(1), subject = 'Test', Type='1st Visit') ;
	    	insert e ;
	    	
	    	test.stoptest() ;
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'S42 6FG' + '|' + 'Acme Ltd' + '|' + 'To Be Approved' + '|' + 'Inbound - 1';
	    	
	    	system.assertEquals(ExpectedSubjectLine,eTest.subject) ;
    	}
    	
    	 static testMethod void TestSubjectLineUpdates_SkipBecausofEventStatus() {
    
	    	Lead L = new lead(lastname='Smith', company = 'Acme Ltd',leadsource = 'Advert',Status='Callback Requested', bdc__C = userinfo.getuserid(),Callback_Date_Time__c = system.now().adddays(5), made_Criteria__c = 'Inbound - 1') ;
	    	Insert L ;
	    	lead l1 = [select id, status from lead where id = :l.id] ;
	    	
	    	l1.status = 'Callback Requested' ;
	    	update l1 ;
	    	
	    	test.starttest() ;
	    	Event e = new Event(whoid = L.id,durationinminutes=10,event_status__C = null, activitydatetime = system.now().adddays(1), subject = 'Test', Type='1st Visit') ;
	    	insert e ;
	    	
	    	test.stoptest() ;
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'Test';
	    	
	    	system.assertEquals(ExpectedSubjectLine,eTest.subject) ;
    	}
	   	
	   	/*
	   	 static testMethod void TestSubjectLineUpdates_overrideUserAmend() {
    
	    	Lead L = new lead(postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Open', bdc__c = userinfo.getuserid()) ;
	    	Insert L ;
	    	
	    	test.starttest() ;
	    	Event e = new Event(whoid = L.id,durationinminutes=10, activitydatetime = system.now().adddays(1), subject = 'Test') ;
	    	insert e ;
	    	
	    	
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	etest.subject = 'tester' ;
	    	
	    	update etest ;
	    	
	    	
	    	test.stoptest() ;
	    	
	    	event eTest2 = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'S42 6FG' + '|' + 'Acme Ltd' + '|' + 'To Be Approved' + '|' + 'Inbound - 1';
	    	
	    	system.assertEquals(ExpectedSubjectLine,eTest2.subject) ;
    	}
    	
    	
    	 static testMethod void TestSubjectLineUpdates_DontChangeRecordInPast() {
    
	    	Lead L = new lead(postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Open', bdc__c = userinfo.getuserid()) ;
	    	Insert L ;
	    	
	    	test.starttest() ;
	    	Event e = new Event(whoid = L.id,durationinminutes=10,startdatetime = system.now().adddays(-11),  activitydatetime = system.now().adddays(-11), subject = 'Test', event_status__c  = 'Confirmed') ;
	    	insert e ;
	    	
	    	test.stoptest() ;
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'Test';
	    	
	    	system.assertEquals(ExpectedSubjectLine,eTest.subject) ;
    	}
    	*/
	   	/*
	   	  static testMethod void TestSubjectLineUpdates_TakeFromEvent_AndOpportunityName() {
    
	    	Lead L = new lead(postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Open', bdc__c = userinfo.getuserid()) ;
	    	Insert L ;
	    	
	    	Account a = new account(name='Test',billingpostalcode = 'DL7 8RW', post_code__c = 'DL7 8RW') ;
	    	insert a ;
	    	
	    	Opportunity o = new Opportunity(accountid = a.id,name='TestOpp') ;
	    	
	    	
	    	test.starttest() ;
	    	Event e = new Event(whoid = L.id,durationinminutes=10, activitydatetime = system.now(), subject = 'Test', event_status__c  = 'Confirmed') ;
	    	insert e ;
	    	
	    	test.stoptest() ;
	    	
	    	event eTest = [select id,subject from event where id = :e.id] ;
	    	
	    	string ExpectedSubjectLine = 'S42 6FG' + '|' + 'TestOpp' + '|' + 'Confirmed' + '|' + 'Inbound - 1';
	    	
	    	system.assertEquals(ExpectedSubjectLine,eTest.subject) ;
    	}
    	*/
        
    }