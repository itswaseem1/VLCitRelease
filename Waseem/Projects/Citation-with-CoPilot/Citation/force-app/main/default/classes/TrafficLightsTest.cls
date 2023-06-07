@isTest
public class TrafficLightsTest{
	
	 @testSetup static void setup() {
		TrafficLights__c traff = new TrafficLights__c() ;
    	traff.Light1AmberThreshold__c = 15 ;
    	traff.Light1RedThreshold__c = 5 ;
    	traff.Light2AmberThreshold__c = 15 ;
    	traff.Light2RedThreshold__c = 5 ;
    	
    	traff.Light3AmberThreshold__c = 15 ;
    	traff.Light3RedThreshold__c = 5 ;
    	traff.Light4AmberThreshold__c = 15 ;
    	traff.Light4RedThreshold__c = 5 ;
    	
    	
    	traff.name = 'Standard' ;
    	traff.Light1TasksEnabled__c = true ;
    	traff.Light2TasksEnabled__c = true ;
    	traff.Light3TasksEnabled__c = true ;
    	traff.Light4TasksEnabled__c = true ;
    	
    	
    	traff.EnableForBlanks__c = true ;
    	traff.EnableForBronze__c = true ;
    	traff.HS_Advice_30_day_renewals_only__c = true ;
    	traff.HS_Advice_Non_Auto_Only__c = true ;
    	traff.EL_HR_Advice_30_day_renewals_only__c = true ;
    	traff.EL_HR_Advice_Non_Auto_Only__c = true ;
    
    	traff.HS_Advice_30_month_renewals_only__c = true ;
    	traff.EL_HR_Advice_30_month_renewals_only__c = true ;
    	
    	
    //	traff.HS_30_day_renewals_only__c = true ;
    	traff.HS_Non_Auto_Only__c = true ;
    //	traff.EL_HR_30_day_renewals_only__c = true ;
    	traff.EL_HR_Non_Auto_Only__c = true ;
    
    	traff.HS_30_month_renewals_only__c = true ;
    	traff.EL_HR_30_month_renewals_only__c = true ;
    	
    	
    	insert traff ;
    	
    	user u = [select id from user where title = 'Internal Relationship Manager' and isactive = true and usertype = 'Standard' limit 1];
    	
    	Cluster__C c1 = new cluster__c(name = 'Customer Success Manager 1',Owner__c=u.id) ;
    	insert c1 ;
    	
    	pricebook2 pb = new pricebook2(name='tst',Isactive=true,Annual_Turnover_Minimum__c = 0, Annual_Turnover_Maximum__c = 50) ;
		insert pb ;
    	
    	list<account> accountList = new list<account>() ;
    	
    	accountlist.add(new account(name='test',hs_advice_trafficlight__c='Green',EL_HR_Advice_Calls__c = 20 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 555,dealtypeid__c = 15) ) ;
    	
         
        
       accountlist.add( new account(name='test',hs_advice_renewal_days__c = 5,hs_advice_renew_months__c = 10, hs_advice_renewal_type__c='Non-auto',hs_advice_trafficlight__c='Red',hs_Advice_Calls__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 556,dealtypeid__c = 15)) ;
       
        
        accountlist.add(new account(name='test',el_hr_advice_renewal_days__c = 5,el_hr_advice_renew_months__c = 10, el_hr_advice_renewal_type__c='Non-auto',el_hr_advice_trafficlight__c='Red',EL_HR_Advice_Calls__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 557,dealtypeid__c = 15)) ;
         
        
         accountlist.add(new account(name='test',hs_advice_renewal_days__c = 35,hs_advice_renew_months__c=35, hs_advice_renewal_type__c='Non-auto',hs_advice_trafficlight__c='Red',hs_Advice_Calls__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 558,dealtypeid__c = 15)) ;
        
        
         accountlist.add( new account(name='test',el_hr_advice_renewal_days__c = 35,el_hr_advice_renew_months__c=35, el_hr_advice_renewal_type__c='Non-auto',el_hr_advice_trafficlight__c='Red',EL_HR_Advice_Calls__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 559,dealtypeid__c = 15) );
       
        accountlist.add(new account(name='test',hs_advice_renewal_days__c = 35,hs_advice_renew_months__c = 35, hs_advice_renewal_type__c='Auto',hs_advice_trafficlight__c='Red',hs_Advice_Calls__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 560,dealtypeid__c = 15)) ;
        
            accountlist.add(new account(name='test',hs_advice_renewal_days__c = 35,hs_advice_renew_months__c = 25, hs_advice_renewal_type__c='Auto',hs_advice_trafficlight__c='Red',hs_Advice_Calls__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 561,dealtypeid__c = 15)) ;
    
         accountlist.add( new account(name='test',el_hr_advice_renewal_days__c = 35,el_hr_advice_renew_months__c=35, el_hr_advice_renewal_type__c='Auto',el_hr_advice_trafficlight__c='Red',EL_HR_Advice_Calls__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 562,dealtypeid__c = 15) );
       
    	    accountlist.add( new account(name='test',el_hr_advice_renewal_days__c = 35,el_hr_advice_renew_months__c=15, el_hr_advice_renewal_type__c='Auto',el_hr_advice_trafficlight__c='Red',EL_HR_Advice_Calls__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 563,dealtypeid__c = 15) );
     
 		// hs visits red     
        accountlist.add( new account(name='test',hs_renew_months__c = 15, hs_renewal_type__c='Non-auto',hs_trafficlight__c='Red',hs_visits__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 564,dealtypeid__c = 15)) ;
    
    // el_hr visits red     
         accountlist.add( new account(name='test',el_hr_renew_months__c=15, el_hr_renewal_type__c='Non-Auto',el_hr_trafficlight__c='Red',EL_HR_Visits__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 565,dealtypeid__c = 15) );
     
     
     	// hs visits red - not non auto  
        accountlist.add( new account(name='test',hs_renew_months__c = 5, hs_renewal_type__c='Auto',hs_trafficlight__c='Red',hs_visits__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 566,dealtypeid__c = 15)) ;
    
    // el_hr visits red    - non non auto  
         accountlist.add( new account(name='test',el_hr_renew_months__c=15, el_hr_renewal_type__c='Auto',el_hr_trafficlight__c='Red',EL_HR_Visits__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 567,dealtypeid__c = 15) );
     
     
     	// hs visits red    - renew months too big 
        accountlist.add( new account(name='test',hs_renew_months__c = 50, hs_renewal_type__c='Non-auto',hs_trafficlight__c='Red',hs_visits__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 568,dealtypeid__c = 15)) ;
    
    // el_hr visits red     - renew months too big
         accountlist.add( new account(name='test',el_hr_renew_months__c=50, el_hr_renewal_type__c='Non-Auto',el_hr_trafficlight__c='Red',EL_HR_Visits__c = 0 , cluster__c = 'Customer Success Manager 1',shorthorn_id__c = 569,dealtypeid__c = 15) );
     
     
    	insert accountList ;
    	
    //	Cluster__C c2 = new cluster__c(name = 'Customer Success Manager 2') ;
    	//insert c2 ;
    	
	 } 
	 
	 static testmethod void ALU_FindHSVisitAccounts() {
	 	TrafficLights__c t1 = TrafficLights__c.getvalues('Standard') ;
	 	t1.Light2TasksEnabled__c = false ;
	 	update t1 ;
	 	
	 	test.starttest() ;
	 	
	 	 AccountVisitLightBatchableTaskGenerator sched = new AccountVisitLightBatchableTaskGenerator();
     	 Schedulablecontext Sc;
     	 sched.Execute(sc); 
	 	//AccountLightScheduledTaskGenerator.doChecks() ;
	 	test.stoptest() ;
	 	system.assertNotEquals(0,[select id from task].size()) ;
	 	
	// 	system.assertNotEquals(0,[select id from task where Healthscore_Task_Type__c = 'H&S Advice'].size()) ;
	 	
	 	
	 }
	 
	  static testmethod void ALU_FindHSVisitAccounts_light3disabled() {
	 	TrafficLights__c t1 = TrafficLights__c.getvalues('Standard') ;
	 	t1.Light3TasksEnabled__c = false ;
	 	update t1 ;
	 	
	 	test.starttest() ;
	 	
	 	 AccountVisitLightBatchableTaskGenerator sched = new AccountVisitLightBatchableTaskGenerator();
     	 Schedulablecontext Sc;
     	 sched.Execute(sc); 
	 	//AccountLightScheduledTaskGenerator.doChecks() ;
	 	test.stoptest() ;
	 	system.assertEquals(0,[select id from task where hs_task__c = true].size()) ;
	 	system.assertnotEquals(0,[select id from task].size()) ;
	 	
	// 	system.assertNotEquals(0,[select id from task where Healthscore_Task_Type__c = 'H&S Advice'].size()) ;
	 	
	 	
	 }
	 
	  static testmethod void ALU_FindELHRVisitAccounts_light4disabled() {
	 	TrafficLights__c t1 = TrafficLights__c.getvalues('Standard') ;
	 	t1.Light4TasksEnabled__c = false ;
	 	update t1 ;
	 	
	 	test.starttest() ;
	 	
	 	 AccountVisitLightBatchableTaskGenerator sched = new AccountVisitLightBatchableTaskGenerator();
     	 Schedulablecontext Sc;
     	 sched.Execute(sc); 
	 	//AccountLightScheduledTaskGenerator.doChecks() ;
	 	test.stoptest() ;
	 	system.assertEquals(0,[select id from task where el_hr_task__c = true].size()) ;
	 	system.assertnotEquals(0,[select id from task ].size()) ;
	 	
	// 	system.assertNotEquals(0,[select id from task where Healthscore_Task_Type__c = 'H&S Advice'].size()) ;
	 	
	 	
	 }
	 
	  static testmethod void ALU_FindELHRVisitAccounts() {
	 //	TrafficLights__c t1 = TrafficLights__c.getvalues('Standard') ;
	 //	t1.Light2TasksEnabled__c = false ;
	 //	update t1 ;
	 	
	 	test.starttest() ;
	 	
	 	 AccountVisitLightBatchableTaskGenerator sched = new AccountVisitLightBatchableTaskGenerator();
     	 Schedulablecontext Sc;
     	 sched.Execute(sc); 
	 	//AccountLightScheduledTaskGenerator.doChecks() ;
	 	test.stoptest() ;
	 	system.assertNotEquals(0,[select id from task].size()) ;
	 	
	// 	system.assertNotEquals(0,[select id from task where Healthscore_Task_Type__c = 'H&S Advice'].size()) ;
	 	
	 	
	 }
	 
	 static testmethod void ALU_FindHSAccounts() {
	 	TrafficLights__c t1 = TrafficLights__c.getvalues('Standard') ;
	 	t1.Light2TasksEnabled__c = false ;
	 	update t1 ;
	 	
	 	test.starttest() ;
	 	
	 	 AccountLightBatchableTaskGenerator sched = new AccountLightBatchableTaskGenerator();
     	 Schedulablecontext Sc;
     	 sched.Execute(sc); 
	 	//AccountLightScheduledTaskGenerator.doChecks() ;
	 	test.stoptest() ;
	 	system.assertNotEquals(0,[select id from task].size()) ;
	 	
	// 	system.assertNotEquals(0,[select id from task where Healthscore_Task_Type__c = 'H&S Advice'].size()) ;
	 	
	 	
	 }
	 
	  static testmethod void ALU_FindELHRAccounts() {
	 	TrafficLights__c t1 = TrafficLights__c.getvalues('Standard') ;
	 	t1.Light1TasksEnabled__c = false ;
	 	update t1 ;
	 	
	 	test.starttest() ;
	 	
	 	 AccountLightBatchableTaskGenerator sched = new AccountLightBatchableTaskGenerator();
     	 Schedulablecontext Sc;
     	 sched.Execute(sc); 
	 	//AccountLightScheduledTaskGenerator.doChecks() ;
	 	test.stoptest() ;
	 	system.assertNotEquals(0,[select id from task].size()) ;
	 	
	// 	system.assertNotEquals(0,[select id from task where Healthscore_Task_Type__c = 'EL/HR Advice'].size()) ;
	 	
	 	
	 }
	 
	 static testmethod void ALU_HS_Advice_To_Red() {
	 	Account_Light_Update__C ALU = new account_light_update__c() ;
	 	ALU.clientid__c = '555' ;
	 	ALU.HS_Contract__c = 1 ;
	 	ALU.HS_Calls__c = 0 ;
	 	test.starttest() ;
	 	insert ALU ;
	 	test.stoptest() ;
	 	
	 	Account a = [select id, hs_advice_trafficlight__c from account where shorthorn_id__c = 555 ] ;
	 	
	 	system.assertEquals('Red',a.hs_advice_trafficlight__c) ;
	 	
	 }
	 
	 static testmethod void ALU_EL_HR_Advice_To_Red() {
	 	Account_Light_Update__C ALU = new account_light_update__c() ;
	 	ALU.clientid__c = '555' ;
	 	ALU.PEL_Contract__c = 1 ;
	 	ALU.PEL_Calls__c = 0 ;
	 	test.starttest() ;
	 	insert ALU ;
	 	test.stoptest() ;
	 	
	 	Account a = [select id, el_hr_advice_trafficlight__c from account where shorthorn_id__c = 555 ] ;
	 	
	 	system.assertEquals('Red',a.el_hr_advice_trafficlight__c) ;
	 	
	 }
	 
	 
	  static testmethod void ALU_HS_Advice_To_Amber() {
	 	Account_Light_Update__C ALU = new account_light_update__c() ;
	 	ALU.clientid__c = '555' ;
	 	ALU.HS_Contract__c = 1 ;
	 	ALU.HS_Calls__c = 12 ;
	 	test.starttest() ;
	 	insert ALU ;
	 	test.stoptest() ;
	 	
	 	Account a = [select id, hs_advice_trafficlight__c from account where shorthorn_id__c = 555 ] ;
	 	
	 	system.assertEquals('Amber',a.hs_advice_trafficlight__c) ;
	 	
	 }
	 
	 static testmethod void ALU_EL_HR_Advice_To_Amber() {
	 	Account_Light_Update__C ALU = new account_light_update__c() ;
	 	ALU.clientid__c = '555' ;
	 	ALU.PEL_Contract__c = 1 ;
	 	ALU.PEL_Calls__c = 12 ;
	 	test.starttest() ;
	 	insert ALU ;
	 	test.stoptest() ;
	 	
	 	Account a = [select id, el_hr_advice_trafficlight__c from account where shorthorn_id__c = 555 ] ;
	 	
	 	system.assertEquals('Amber',a.el_hr_advice_trafficlight__c) ;
	 	
	 }
	 
	  static testmethod void ALU_HS_Advice_To_Green() {
	 	Account_Light_Update__C ALU = new account_light_update__c() ;
	 	ALU.clientid__c = '555' ;
	 	ALU.HS_Contract__c = 1 ;
	 	ALU.HS_Calls__c = 22 ;
	 	test.starttest() ;
	 	insert ALU ;
	 	test.stoptest() ;
	 	
	 	Account a = [select id, hs_advice_trafficlight__c from account where shorthorn_id__c = 555 ] ;
	 	
	 	system.assertEquals('Green',a.hs_advice_trafficlight__c) ;
	 	
	 }
	 
	 static testmethod void ALU_EL_HR_Advice_To_Green() {
	 	Account_Light_Update__C ALU = new account_light_update__c() ;
	 	ALU.clientid__c = '555' ;
	 	ALU.PEL_Contract__c = 1 ;
	 	ALU.PEL_Calls__c = 22 ;
	 	test.starttest() ;
	 	insert ALU ;
	 	test.stoptest() ;
	 	
	 	Account a = [select id, el_hr_advice_trafficlight__c from account where shorthorn_id__c = 555 ] ;
	 	
	 	system.assertEquals('Green',a.el_hr_advice_trafficlight__c) ;
	 	
	 }
	
    
     static testMethod void myUnitTest_HS_Light_R_to_G() {    	
    	
        account a = new account(name='test',HS_Advice_Renewal_type__c = 'Non-auto', HS_Advice_Renew_months__c = 20,HS_Advice_Renewal_days__c = 20,HS_Advice_Calls__c = 2,HS_Advice_Reset_Date__c = date.today().adddays(-365), cluster__c = 'Customer Success Manager 1' ,dealtypeid__c = 15,hs_advice_trafficlight__C = 'Red') ;
        insert a ;        
        contract c  = new contract(accountid = a.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0, agreement_type__c = 'Auto') ;
		insert c ;
		a.current_contract__c = c.id ;
		update a;  
       
        
         account a1 = new account(name='test',HS_Advice_Renewal_type__c = 'Non-auto', HS_Advice_Renew_months__c = 20,HS_Advice_Renewal_days__c = 20,HS_Advice_Calls__c = 2, cluster__c = 'Customer Success Manager 1',dealtypeid__c = 15,HS_Advice_Reset_Date__c = date.today().adddays(-365),hs_advice_trafficlight__C = 'Red' ) ;
        insert a1 ;        
        contract c1  = new contract(accountid = a1.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0,agreement_type__c = 'Auto') ;
		insert c1 ;
		a1.current_contract__c = c1.id ;
		update a1;  
      
        
      
        // account checkAccount1 = [select id,HS_Advice_TrafficLight__c from account where id = :a.id] ;
       
       // system.assertEquals('Red',checkAccount1.HS_Advice_TrafficLight__c) ;
    	//system.assertNotEquals(0,[select id from task].size()) ;
       list<task> tlist = new list<task>() ;
       	tlist.add( new task(whatid=a.id, subject = 'No EL/HR Advice Calls in 6 Months',hs_advice_task__c = true)) ;
       	tlist.add(new task(whatid=a1.id, subject = 'No EL/HR Advice Calls in 6 Months',hs_advice_task__c = true)) ;
       	tlist.add(new task(whatid=a1.id, subject = 'No H&S Advice Calls in 6 Months',hs_advice_task__c = true)) ;
       	
       	insert tlist ;
       	
       	
       	for(task t : tlist) {
       		t.status='Completed' ;
       		}
       		
       	  test.starttest() ;
     
       	update tlist ;
       	
       	
       
        
        test.stoptest() ;
         account checkAccount2 = [select id,HS_Advice_TrafficLight__c from account where id = :a.id] ;
        system.assertEquals('Green',checkAccount2.HS_Advice_TrafficLight__c) ;
       
        
    }
    
     static testMethod void myUnitTest_EL_HR_Light_R_to_G() {    	
    	
        account a = new account(name='test',EL_HR_Advice_Renewal_type__c = 'Non-auto', EL_HR_Advice_Renewal_days__c = 20,EL_HR_Advice_Renew_months__c = 20,EL_HR_Advice_Calls__c = 2,EL_HR_Advice_Reset_Date__c = date.today().adddays(-365), cluster__c = 'Customer Success Manager 1' ,dealtypeid__c = 15,EL_HR_advice_trafficlight__C = 'Red') ;
        insert a ;        
        contract c  = new contract(accountid = a.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0, agreement_type__c = 'Auto') ;
		insert c ;
		a.current_contract__c = c.id ;
		update a;  
       
        
         account a1 = new account(name='test',EL_HR_Advice_Renewal_type__c = 'Non-auto', EL_HR_Advice_Renewal_days__c = 20,EL_HR_Advice_Renew_months__c = 20,EL_HR_Advice_Calls__c = 2, cluster__c = 'Customer Success Manager 1',dealtypeid__c = 15,EL_HR_Advice_Reset_Date__c = date.today().adddays(-365),EL_HR_advice_trafficlight__C = 'Red' ) ;
        insert a1 ;        
        contract c1  = new contract(accountid = a1.id, FOC_Period_Mths__c = 2, FOC_Period_Mths_End__c=0, agreement_type__c = 'Auto') ;
		insert c1 ;
		a1.current_contract__c = c1.id ;
		update a1;  
      
        
      
        // account checkAccount1 = [select id,HS_Advice_TrafficLight__c from account where id = :a.id] ;
       
       // system.assertEquals('Red',checkAccount1.HS_Advice_TrafficLight__c) ;
    	//system.assertNotEquals(0,[select id from task].size()) ;
       list<task> tlist = new list<task>() ;
       	tlist.add( new task(whatid=a.id, subject = 'blah',EL_HR_advice_task__c = true)) ;
       	tlist.add(new task(whatid=a1.id, subject = 'blah',EL_HR_advice_task__c = true)) ;
       	tlist.add(new task(whatid=a1.id, subject = 'blah',EL_HR_advice_task__c = true)) ;
       	
       	insert tlist ;
       	
       	
       	for(task t : tlist) {
       		t.status='Completed' ;
       		}
       		
       	  test.starttest() ;
     
       	update tlist ;
       	
       	
       
        
        test.stoptest() ;
         account checkAccount2 = [select id,EL_HR_Advice_TrafficLight__c from account where id = :a.id] ;
        system.assertEquals('Green',checkAccount2.EL_HR_Advice_TrafficLight__c) ;
       
        
    }
    
    
    
     
	   static testmethod void LightSettingsAdjust() {
    	TrafficLightSettingsAdjust Ext = new TrafficLightSettingsAdjust() ;
		PageReference LS = Page.LightSettings ;
		test.starttest() ;
		test.SetCurrentPage(LS) ;
		Ext.Light2TasksEnabled = false ;
		Ext.SaveSetting() ;
		test.stoptest() ;
    	
    }
    
	 static testmethod void TestAccountLightsPageWithId_Red() {
	 	
    	account a = new account(name='test',EL_HR_Advice_Calls__c = 20,HS_Advice_TrafficLight__c='Red' , cluster__c = 'Customer Success Manager 1',dealtypeid__c = 15) ;
        insert a ;       
        PageReference accountLightsPage = Page.accountLights ;
    	test.starttest() ;
    	Test.setCurrentPage(accountLightsPage);
    	
    	System.currentPageReference().getParameters().put('id', a.id);
    	AccountLightsExt ale = new AccountLightsExt() ;
    	test.stoptest() ;
    	system.assertEquals('test',ale.acc.name) ;
    	system.assertequals('Customer Success Manager 1',ale.acc.cluster__c) ;
	 }
	 
	  static testmethod void TestAccountLightsPageWithId_Amber() {
	 	
    	account a = new account(name='test',EL_HR_Advice_Calls__c = 20,HS_Advice_TrafficLight__c='Amber' , cluster__c = 'Customer Success Manager 1',dealtypeid__c = 15) ;
        insert a ;       
        PageReference accountLightsPage = Page.accountLights ;
    	test.starttest() ;
    	Test.setCurrentPage(accountLightsPage);
    	
    	System.currentPageReference().getParameters().put('id', a.id);
    	AccountLightsExt ale = new AccountLightsExt() ;
    	test.stoptest() ;
    	system.assertEquals('test',ale.acc.name) ;
    	system.assertequals('Customer Success Manager 1',ale.acc.cluster__c) ;
	 }
	 
	 
	  static testmethod void TestAccountLightsPageWithCode() {
	 	
    	account a = new account(name='test',EL_HR_Advice_Calls__c = 20 , cluster__c = 'Customer Success Manager 1',account_external_id__c = '555',dealtypeid__c = 15) ;
        insert a ;       
        PageReference accountLightsPage = Page.accountLights ;
    	test.starttest() ;
    	Test.setCurrentPage(accountLightsPage);
    	
    	System.currentPageReference().getParameters().put('accountCode', a.account_external_id__c);
    	AccountLightsExt ale = new AccountLightsExt() ;
    	test.stoptest() ;
    	system.assertEquals('test',ale.acc.name) ;
    	system.assertequals('Customer Success Manager 1',ale.acc.cluster__c) ;
	 }
	 
	  static testmethod void TestAccountLightsPageWithNoCode() {
	 	
    	account a = new account(name='test',EL_HR_Advice_Calls__c = 20 , cluster__c = 'Customer Success Manager 1',account_external_id__c = '555',dealtypeid__c = 15) ;
        insert a ;       
        PageReference accountLightsPage = Page.accountLights ;
    	test.starttest() ;
    	Test.setCurrentPage(accountLightsPage);
    	
    	System.currentPageReference().getParameters().put('accountCode', 'bob');
    	AccountLightsExt ale = new AccountLightsExt() ;
    	test.stoptest() ;
    	system.assertnotequals('Customer Success Manager 1',ale.acc.cluster__c) ;
    	
	 }
	 
	 static testmethod void TestAccountLightsPageWithController_RedOverall() {
	 	
    	account a = new account(name='test',HS_Advice_TrafficLight__c='Red',EL_HR_Advice_Calls__c = 20 , cluster__c = 'Customer Success Manager 1',account_external_id__c = '555',dealtypeid__c = 15) ;
        insert a ;       
        PageReference accountLightsPage = Page.accountLights ;
    	test.starttest() ;
    	Test.setCurrentPage(accountLightsPage);
    	
    	System.currentPageReference().getParameters().put('accountCode', a.account_external_id__c);
    	
    	  ApexPages.StandardController sc = new ApexPages.StandardController(a);
    	  
    	AccountLightsExt ale = new AccountLightsExt(sc) ;
    	test.stoptest() ;
    	system.assertEquals('test',ale.acc.name) ;
    	system.assertequals('Customer Success Manager 1',ale.acc.cluster__c) ;
	 }
	 
	  static testmethod void TestAccountLightsPageWithController_AmberOverall() {
	 	
    	account a = new account(name='test',HS_Advice_TrafficLight__c='Amber',EL_HR_Advice_Calls__c = 20 , cluster__c = 'Customer Success Manager 1',account_external_id__c = '555',dealtypeid__c = 15) ;
        insert a ;       
        PageReference accountLightsPage = Page.accountLights ;
    	test.starttest() ;
    	Test.setCurrentPage(accountLightsPage);
    	
    	System.currentPageReference().getParameters().put('accountCode', a.account_external_id__c);
    	
    	  ApexPages.StandardController sc = new ApexPages.StandardController(a);
    	  
    	AccountLightsExt ale = new AccountLightsExt(sc) ;
    	test.stoptest() ;
    	system.assertEquals('test',ale.acc.name) ;
    	system.assertequals('Customer Success Manager 1',ale.acc.cluster__c) ;
	 }
    
   static testmethod void ALU_HS_Visit_To_Red() {
       TrafficLights__c tl = TrafficLights__c.getvalues('Standard') ;
       tl.Light3AmberThreshold__c = 10;
       tl.Light3RedThreshold__c = 5;
       update tl;
	 	Account_Light_Update__C ALU = new account_light_update__c() ;
	 	ALU.clientid__c = '555' ;
	 	ALU.HS_Contract__c = 1 ;
       	ALU.PEL_visits__C =1;
	 	ALU.HS_Calls__c = 12 ;
       	ALU.HS_Visits__c = 1;
	 	test.starttest() ;
	 	insert ALU ;
	 	test.stoptest() ;
	 	
	 	Account a = [select id, HS_TrafficLight__c from account where shorthorn_id__c = 555 ] ;
	 	
	 	system.assertEquals('Red',a.HS_TrafficLight__c) ;
	 	
	 }
	 
	 
    
    
    
    
   
}