@isTest
Public class ContractRenewalOppBatchHandlerTest {

     @testSetup static void setup(){
        
        Id contRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Standard Contract').getRecordTypeId();
        
        Account parentAcc = TestFactory.createAccount('PROFESSIONAL ACTIVITIES','B12 3TU',6,1);
        Insert parentAcc;

        Account acc = TestFactory.createAccount('PROFESSIONAL ACTIVITIES','WA5 3TU',6,1);
        acc.ParentId =parentAcc.Id;
        Insert acc;
        
        Contact con = TestFactory.createContact(acc.Id);
        insert con;

        Pricebook2 pricebook = TestFactory.createPricebook('1', 100000.0, 0.0);
        pricebook.Term__c = '3';
        insert pricebook;

        Contract cont = TestFactory.createContract(acc.Id, contRecTypeId, 'Auto', 15, con.Id);
		cont.FOC_Period_Mths__c = 2;
		cont.FOC_Period_Mths_End__c=0;
        insert cont;

        cluster__c cls  = TestFactory.createCluster('Cluster 5',  'CA, LA, FY, PR, BB,OL, BL, WN, L, WA, M, SK', 'Somu' );
        insert cls;
        
        
    }
        
    @isTest static void myUnitTest(){

        Id testRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('NBS Contract').getRecordTypeId();
        Id contRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Standard Contract').getRecordTypeId();
   
        Account testAcc = [Select Id, Name, Postcode_District__c, Cluster__c From Account Where Postcode_District__c = 'WA' Limit 1];
        
        Test.startTest();
        Contact con = TestFactory.createContact(testAcc.Id);
        insert con;

        Contract cont = TestFactory.createContract(testAcc.Id, testRecTypeId,'Non-Auto', 15, con.Id);
        cont.Services_Taken_EL__c = True;
        cont.StartDate = Date.Today().addDays(1);
        cont.ContractTerm = 9;
        cont.Status= 'Draft';
        cont.Agreement_Type__c = 'Paper';
        cont.Initial_Payment2__c = 170.00;
		cont.FOC_Period_Mths__c = 2;
		cont.FOC_Period_Mths_End__c=0;
        insert cont;
        
        cont.Status = 'Active';
        update cont;
        

        Contract cont1 = TestFactory.createContract(testAcc.Id, testRecTypeId , 'Auto', 15, con.Id);
        cont1.Services_Taken_HS__c = True;
        cont1.StartDate = Date.Today().addDays(1);
        cont1.ContractTerm = 9;
        cont1.Status= 'Draft';
        cont.Agreement_Type__c = 'Paper';
        cont1.Initial_Payment2__c = 70.00;
		cont1.FOC_Period_Mths__c = 2;
		cont1.FOC_Period_Mths_End__c=0;
        insert cont1;
 
        cont1.Status = 'Active';
        update cont1;

        Contract cont2 = TestFactory.createContract(testAcc.Id, contRecTypeId,'Auto', 15, con.Id);
        cont2.Services_Taken_AI_Only_HS__c = True;
        cont2.Services_Taken_HS__c = True;
        cont2.StartDate = Date.Today().addDays(1);
        cont2.ContractTerm = 9;
        cont2.Status= 'Draft';
        cont.Agreement_Type__c = 'Paper';
        cont2.Initial_Payment2__c = 90.00;
		cont2.FOC_Period_Mths__c = 2;
		cont2.FOC_Period_Mths_End__c=0;
        insert cont2;
        
        cont2.Status = 'Active';
        update cont2;
        
        
        
        
        ContractRenewalOppBatchHandler batch = new ContractRenewalOppBatchHandler();
            
        database.executeBatch(batch);
        
        Test.stopTest();
        
        list<Opportunity> oppList = [select Id, Name,AccountId, Original_Contract__c from Opportunity Where AccountId =:testAcc.ID ];
        system.debug('oppList::=='+oppList.Size());
        System.assertEquals(3, oppList.Size());
    
    }
    
    
}