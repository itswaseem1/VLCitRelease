@isTest
private class BillingScheduleController_Test {
	
	@testsetup
	static void setup(){
		c2g__codaGeneralLedgerAccount__c gl = new c2g__codaGeneralLedgerAccount__c();
		gl.Name = '45100 - Trade Debtors Control';
		gl.Account_Description__c = 'Trade Debtors Control';
		gl.c2g__ReportingCode__c = '45100';
		gl.c2g__ExternalId__c = '45100 - Trade Debtors Control';
		gl.Sub_Ledger_Required__c = 'Tax';
		gl.c2g__TrialBalance1__c = 'Balance Sheet';
		gl.c2g__Type__c = 'Balance Sheet';
		gl.c2g__TrialBalance2__c = 'Current Assets';
		gl.c2g__TrialBalance3__c = 'Trade debtors';
		insert gl;

		c2g__codaTaxCode__c tc = new c2g__codaTaxCode__c();
		tc.c2g__ExternalId__c = 'GB-O-STD';
		tc.CurrencyIsoCode = 'GBP';
		tc.ffvat__NetBox__c = 'Box 6';
		tc.ffvat__TaxBox__c = 'Box 1';
		tc.c2g__Description__c = 'UK Output Standard Rated';
		tc.c2g__GeneralLedgerAccount__c = gl.Id;
		insert tc;

		c2g__codaTaxCode__c tc1 = new c2g__codaTaxCode__c();
		tc1.c2g__ExternalId__c = 'GB-I-STD';
		tc1.CurrencyIsoCode = 'GBP';
		tc1.ffvat__NetBox__c = 'Box 7';
		tc1.ffvat__TaxBox__c = 'Box 4';
		tc1.c2g__Description__c = 'UK Input Standard Rated';
		tc1.c2g__GeneralLedgerAccount__c = gl.Id;
		insert tc1;
	}
	
	static testmethod void testcontract() {
		pricebook2 pb = new pricebook2(name='tst',isactive=true,Annual_Turnover_Minimum__c = 0, Annual_Turnover_Maximum__c = 50) ;
		insert pb ;
		account a = new account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
		insert a;
		fferpcore__Company__c c = new fferpcore__Company__c(name='test') ;
		insert c ;
		ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id) ;
		insert cont ;
		
		product2  p1 = new product2(name = 'a',isactive = true) ;
		insert p1 ;
		
			
		ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c='MB') ;
		insert sd ;
		
		date d = date.today().adddays(7) ;
		ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(service_start_date__c = date.today(), service_end_date__c = date.today(),ffbc__Quantity__c	=3,ffbc__SalesPriceOverride__c=199.99,ffbc__Contract__c = cont.id, ffbc__ProductService__c = p1.id,ffbc__BillingTerm__c=sd.id,ffbc__FirstBillDate__c=d , ffbc__BillingType__c= 'Recurring Fixed')  ;
		insert l ;
		
		ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
		request.ContractIds = new Set<Id>{cont.id};
		request.MonthsToGenerate = 0;
		
		ffbc.ContractsService.activation(request);
		
		
		
		ffbc__billingSchedule__c bs1 = new ffbc__billingSchedule__c(ffbc__ContractLineItem__c = l.id,ffbc__BillingDate__c=date.today().adddays(5),ffbc__BillingPeriodEndDate__c=date.today().adddays(365),ffbc__BillingPeriodStartDate__c=date.today()) ;
		insert bs1 ;
			ffbc__billingSchedule__c bs2 = new ffbc__billingSchedule__c(ffbc__ContractLineItem__c = l.id,ffbc__BillingDate__c=date.today().adddays(35),ffbc__BillingPeriodEndDate__c=date.today().adddays(365),ffbc__BillingPeriodStartDate__c=date.today()) ;
		insert bs2 ;
		
		
		
				
		  test.starttest() ;
        
        	 cont.VAT_schedule_filetrigger__c = true ;
        
        update cont ;
        test.stoptest() ;
        
     
		
	}
	
		static testmethod void testcontract2() {
		account a = new account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
		insert a;
		fferpcore__Company__c c = new fferpcore__Company__c(name='test') ;
		insert c ;
		ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id) ;
		insert cont ;
		
		product2  p1 = new product2(name = 'a',isactive = true) ;
		insert p1 ;
		
	
		
		ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c='MB') ;
		insert sd ;
		
		date d = date.today().adddays(7) ;
		ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(service_start_date__c = date.today(), service_end_date__c = date.today(),ffbc__Quantity__c	=3,ffbc__SalesPriceOverride__c=199.99,ffbc__Contract__c = cont.id, ffbc__ProductService__c = p1.id,ffbc__BillingTerm__c=sd.id,ffbc__FirstBillDate__c=d , ffbc__BillingType__c= 'Recurring Fixed')  ;
		insert l ;
		
		ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
		request.ContractIds = new Set<Id>{cont.id};
		request.MonthsToGenerate = 0;
		
		ffbc.ContractsService.activation(request);
		
		
		ffbc__billingSchedule__c bs1 = new ffbc__billingSchedule__c(ffbc__ContractLineItem__c = l.id,ffbc__BillingDate__c=date.today(),ffbc__BillingPeriodEndDate__c=date.today().adddays(365),ffbc__BillingPeriodStartDate__c=date.today()) ;
		insert bs1 ;
		
		
		
		PageReference pdf = Page.BillingSchedule ;
    	test.starttest() ;
    	Test.setCurrentPage(pdf);
    	System.currentPageReference().getParameters().put('id', cont.id);
    	/* HOW TO UNIT TEST THIS - a new constructor?  a separate method?  */
    	billingScheduleController b = new billingScheduleController(new ApexPages.StandardController(cont)) ;
    	 
    	test.stoptest() ;
		
	
		
	}
	
	
	static testmethod void testcontract3() {
		account a = new account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
		insert a;
		fferpcore__Company__c c = new fferpcore__Company__c(name='test') ;
		insert c ;
		
		list<ffbc__contract__c> contlist = new list<ffbc__contract__c>() ;
	
		ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id) ;
		contlist.add(  new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add(new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id) );
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		contlist.add( new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id)) ;
		
		insert cont ;
		insert contlist ;
		
		
		product2  p1 = new product2(name = 'a',isactive = true) ;
		insert p1 ;
		
	
		
		ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c='MB') ;
		insert sd ;
		
		date d = date.today().adddays(7) ;
		ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(service_start_date__c = date.today(), service_end_date__c = date.today(),ffbc__Quantity__c	=3,ffbc__SalesPriceOverride__c=199.99,ffbc__Contract__c = cont.id, ffbc__ProductService__c = p1.id,ffbc__BillingTerm__c=sd.id,ffbc__FirstBillDate__c=d , ffbc__BillingType__c= 'Recurring Fixed')  ;
		insert l ;
		
		set<id> idSet = new set<id>() ;
		for(ffbc__contract__c ffbccont : contlist) {
			idSet.add(ffbccont.id) ;
			
		}
		idset.add(cont.id) ;
		
		
		ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
		request.ContractIds = idSet;
		request.MonthsToGenerate = 0;
		
		ffbc.ContractsService.activation(request);
		
		
		
		ffbc__billingSchedule__c bs1 = new ffbc__billingSchedule__c(ffbc__ContractLineItem__c = l.id,ffbc__BillingDate__c=date.today().adddays(5),ffbc__BillingPeriodEndDate__c=date.today().adddays(365),ffbc__BillingPeriodStartDate__c=date.today()) ;
		insert bs1 ;
			ffbc__billingSchedule__c bs2 = new ffbc__billingSchedule__c(ffbc__ContractLineItem__c = l.id,ffbc__BillingDate__c=date.today().adddays(35),ffbc__BillingPeriodEndDate__c=date.today().adddays(365),ffbc__BillingPeriodStartDate__c=date.today()) ;
		insert bs2 ;
		
		
	
		
		  test.starttest() ;
		  
		  for(ffbc__contract__c ffbccont : contlist) {
			 ffbccont.VAT_schedule_filetrigger__c = true ;
			
		}
        
        
        
        update contlist ;
        test.stoptest() ;
        
    
		
	}

    	static testmethod void testcontract4() {
		pricebook2 pb = new pricebook2(name='tst',isactive=true,Annual_Turnover_Minimum__c = 0, Annual_Turnover_Maximum__c = 50) ;
		insert pb ;
		account a = new account(name='test',c2g__CODAInvoiceEmail__c = 'test@test.com') ;
		insert a;
		fferpcore__Company__c c = new fferpcore__Company__c(name='test') ;
		insert c ;
		ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = a.id) ;
		insert cont ;
		
		product2  p1 = new product2(name = 'a',isactive = true) ;
		insert p1 ;
		
			
		ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c='MB') ;
		insert sd ;
		
		date d = date.today().adddays(7) ;
		ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(service_start_date__c = date.today(), service_end_date__c = date.today(),ffbc__Quantity__c=3,ffbc__SalesPriceOverride__c=199.99,ffbc__Contract__c = cont.id, ffbc__ProductService__c = p1.id,ffbc__BillingTerm__c=sd.id,ffbc__FirstBillDate__c=d , ffbc__BillingType__c= 'Recurring Fixed')  ;
		insert l ;
		
		ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
		request.ContractIds = new Set<Id>{cont.id};
		request.MonthsToGenerate = 0;
		
		ffbc.ContractsService.activation(request);
		
		cont.VAT_schedule_filetrigger__c = true ;
        update cont ;	
        List<id> ids = new List<id>();
        ids.add(cont.id);
		test.starttest() ;     
        	 BillingScheduleController.GenerateScheduleFilesSynchronous(ids);
        test.stoptest() ;
	
	}

/*
    static testMethod void TestMethod1() {
    	
    	
    	ffbc__billingSchedule__c bsc = [select id,ffbc__ContractLineItem__r.ffbc__Contract__c from ffbc__billingSchedule__c where ffbc__BillingDate__c > today and ffbc__ContractLineItem__c <> null order by id desc limit 1] ;
    	 
    	ffbc__contract__C ffbccontract = new ffbc__contract__c(id=bsc.ffbc__ContractLineItem__r.ffbc__Contract__c) ; 
    	
        test.starttest() ;
        
        ffbccontract.VAT_schedule_filetrigger__c = true ;
        
        update ffbccontract ;
        test.stoptest() ;
        
        
        
        
    }
    
    
    static testmethod void testmethod2() {
    	ffbc__billingSchedule__c bsc = [select id,ffbc__ContractLineItem__r.ffbc__Contract__c from ffbc__billingSchedule__c where ffbc__BillingDate__c > today and ffbc__ContractLineItem__c <> null order by id desc limit 1] ;
    	 
    	ffbc__contract__C ffbccontract = new ffbc__contract__c(id=bsc.ffbc__ContractLineItem__r.ffbc__Contract__c) ; 
    	
    	PageReference pdf = Page.BillingSchedule ;
    	test.starttest() ;
    	Test.setCurrentPage(pdf);
    	System.currentPageReference().getParameters().put('id', ffbcContract.id);
    	// HOW TO UNIT TEST THIS - a new constructor?  a separate method?  
    	billingScheduleController b = new billingScheduleController(new ApexPages.StandardController(ffbccontract)) ;
    	 
    	test.stoptest() ;
    	
    	
    }*/
}