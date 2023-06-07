@IsTest
public class DataJobForExpContractTest {

    @testSetup
  		static void setup() {
        	Account acc = new Account();
    		acc.put('Name', 'Test Account 1');
            acc.c2g__CODAInvoiceEmail__c = 'test@test.com';
        	insert acc;
        	
            List<WorkType> workTypes = new List<WorkType>();
            WorkType workTypeObj2 = new WorkType(
      		Name = 'Non Documentation',
      		EstimatedDuration = 2.00,
      		DurationType = 'Hours',
        	ShouldAutoCreateSvcAppt = false
    		);
    		workTypes.add(workTypeObj2);
        	WorkType workTypeObj1 = new WorkType(
      		Name = 'Documentation',
      		EstimatedDuration = 2.00,
      		DurationType = 'Hours',
      		ShouldAutoCreateSvcAppt = true
    		);
            workTypes.add(workTypeObj1);
    		insert workTypes;
            
            Product2 prod2 = new Product2();
    		prod2.put('Name', 'H&S Compliance Service');
    		prod2.put('ProductCode', 'HS-Compliance');
    		prod2.put('IsActive', true);
    		insert prod2;

            customSettings();
            
            fferpcore__Company__c c = new fferpcore__Company__c(name = 'test');
      		insert c;
            
            ffbc__SoftDate__c sd = new ffbc__SoftDate__c(ffbc__Definition__c = 'MB');
      		insert sd;
            
      		ffbc__contract__c cont = new ffbc__contract__c(ffbc__company__c = c.id, ffbc__account__c = acc.id,Contract_Type__c='New',ffbc__StartDate__c=Date.newInstance(2021, 01, 01),ffbc__EndDate__c=Date.newInstance(2022, 04, 01));
      		insert cont;
            
            ffbc__ContractLineItem__c l = new ffbc__ContractLineItem__c(
        	service_start_date__c = Date.newInstance(2021, 02, 01),
        	service_end_date__c = Date.newInstance(2022, 02, 01),
        	ffbc__Quantity__c = 3,
        	ffbc__UnitPrice__c = 199.99,
            ffbc__FirstBillDate__c = Date.newInstance(2021, 03, 01),
        	ffbc__Contract__c = cont.id,
        	ffbc__ProductService__c = prod2.id,
        	ffbc__BillingTerm__c = sd.id,
        	ffbc__BillingType__c = 'Recurring Fixed'
      		);
      		insert l;
            
            List<Case> cases = new List<Case>();
            Case c1 = new Case(Subject = 'Test Case 1', Description = 'Test Des', Billing_Contract__c = cont.id, AccountId = acc.id, Status = 'Pending Start');
            Case c2 = new Case(Subject = 'Test Case 2', Description = 'Test Des', Billing_Contract__c = cont.id, AccountId = acc.id, Status = 'Active');
            Case c3 = new Case(Subject = 'Test Case 3', Description = 'Test Des', Billing_Contract__c = cont.id, AccountId = acc.id, Status = 'Pending Start', expBillingContProcessed__c = True);
			cases.add(c1);
            cases.add(c2);
            cases.add(c3);
            insert cases;
            
            List<WorkOrder> wOrders = new List<WorkOrder>();
            WorkOrder w1 = new WorkOrder(CaseId = c2.Id, AccountId = acc.Id, Subject = 'Test subject 1', Description = 'Test des', Status = 'New', WorkTypeId = workTypeObj1.Id);
            WorkOrder w3 = new WorkOrder(CaseId = c2.Id, AccountId = acc.Id, Subject = 'Test subject 3', Description = 'Test des', Status = 'New', WorkTypeId = workTypeObj1.Id);
            WorkOrder w2 = new WorkOrder(CaseId = c2.Id, AccountId = acc.Id, Subject = 'Test subject 2', Description = 'Test des', Status = 'New', WorkTypeId = workTypeObj2.Id);
            wOrders.add(w1);
            wOrders.add(w2);
            wOrders.add(w3);
            Test.startTest();
            insert wOrders;
            
        	ffbc.ContractsService.ActivationRequest request = new ffbc.ContractsService.ActivationRequest();
      		request.ContractIds = new Set<Id>{ cont.id };
      		request.MonthsToGenerate = 0;
            ffbc.ContractsService.activation(request);
            
            Test.stopTest();
            
    }
    
    static testMethod void expBillingContract(){
        ffbc__Contract__c cont = [Select Id, ffbc__Status__c from ffbc__Contract__c limit 1];     
        //System.assertEquals('Active', cont2.ffbc__Status__c);
        
        ffbc.ContractsService.ExpireRequest expReq = new ffbc.ContractsService.ExpireRequest();
        expReq.ContractIds = new Set<Id>{ cont.id };        
        ffbc.ContractsService.expire(expReq);
        FSL.GlobalAPIS.addStatusTransition('None', 'Cannot Complete');
        
        //WorkOrder wo = [Select Id, Status from workOrder where subject = 'Test subject 1'];
        //ServiceAppointment sa = new serviceAppointment(ParentRecordId = wo.Id, Status = 'In Progress', EarliestStartTime = DateTime.newInstance(2022, 08, 01, 05, 00, 00), DueDate = DateTime.newInstance(2022, 10, 30, 05, 00, 00));
        
        
        Test.startTest();
        WorkOrder wo = [Select Id, Status from workOrder where subject = 'Test subject 1'];
        ServiceAppointment sa = new serviceAppointment(ParentRecordId = wo.Id, Status = 'In Progress', EarliestStartTime = DateTime.newInstance(2022, 08, 01, 05, 00, 00), DueDate = DateTime.newInstance(2022, 10, 30, 05, 00, 00));
        
        insert sa;
        DataJobForExpBillingContracts datajob = new DataJobForExpBillingContracts();
        Database.executeBatch(datajob);
                
        Test.stopTest();     
             
       	List<Case> caseList = [Select Id, Status, subject, expBillingContProcessed__c from case where subject = 'Test Case 1' OR subject = 'Test Case 3'];        
        for(Case c : caseList){
            if(c.subject == 'Test case 1'){
                System.assertEquals('Contract Amendment', c.Status);
            	System.assertEquals(True,c.expBillingContProcessed__c);
            }            	
            else if(c.subject == 'Test Case 3')
                System.assertEquals('Pending Start', c.Status);
        }
        System.assertEquals('New', wo.Status);
       
    }
    private static void customSettings() {
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

    ffbc__BackgroundProcessSettings__c settings = new ffbc__BackgroundProcessSettings__c();
    settings.ffbc__GenerateSchedulesQueueSize__c = 5;
    settings.ffbc__GenerateSchedulesSchedulesPerLine__c = 100;
    settings.ffbc__GenerateSchedulesScopeSize__c = 5;

    insert settings;
  }
}