@isTest
public class ContractLineItemHandlerTest {

    @TestSetup
    static void setup(){
        ffrr__Settings__c settings = new ffrr__Settings__c() ;
        settings.ffrr__activeField__c = 'ffbc__ContractStatus__c' ;
        settings.ffrr__ActiveValue__c = 'Active' ;
        settings.ffrr__Description__c = 'Name' ;
        settings.ffrr__Object__c = 'ffbc__ContractLineItem__c' ;
        settings.ffrr__SettingsType__c = 'Actual' ;
        settings.ffrr__TransactionLineRelationship__c = 'ffps_cita__ContractLineItem__c' ;
        settings.CurrencyIsoCode = 'GBP' ;
        settings.ffrr__BalanceSheetAccount__c = 'SalesRevenueAccount__c' ;
        settings.ffrr__IncomeStatementAccount__c = 'Revenue_Recognition_GLA__c' ;
        settings.ffrr__PercentageComplete__c = 'Percent__c' ;

        settings.ffrr__FixedBalanceSheetAccountCode__c = true ;
        settings.ffrr__FixedIncomeStatementAccountCode__c = true ;
        settings.ffrr__TotalRevenue__c = 'Total_Revenue__c' ;
       
        settings.ffrr__Currency__c = 'CurrencyIsoCode' ;
        settings.ffrr__IncludeActiveValue__c = 'Include' ;
        settings.ffrr__StartDate__c = 'Service_Start_Date__c' ;
        settings.ffrr__EndDate__c = 'Service_End_Date__c' ;
        insert settings ;

        ffrr__Template__c ffrrtemplate = new ffrr__Template__c() ;
        ffrrtemplate.ffrr__RevRecType__c = '% Complete'  ;
        ffrrtemplate.name = System.label.ContractLineItem_RevRecTemplateName ;
        ffrrtemplate.ffrr__CalculationType__c = 'Not Applicable' ;
        ffrrtemplate.ffrr__Settings__c = settings.id ;
        
        ffrrtemplate.ffrr__RevenueSource__c = 'ffbc__ContractLineItem__c' ;
        ffrrtemplate.ffrr__RevenueBasis__c = 'Total revenue' ;
        ffrrtemplate.name = 'Billing Contract Lines - % Complete' ;
        insert ffrrtemplate ;
        
        List<ffbc__ContractLineItem__c> contractList = new  List<ffbc__ContractLineItem__c>();
        Map<Id,ffbc__ContractLineItem__c> contractNewMap = new  Map<Id,ffbc__ContractLineItem__c>();
        Map<Id,ffbc__ContractLineItem__c> contractOldMap = new  Map<Id,ffbc__ContractLineItem__c>();
        ContractLineItemHandler clih = new ContractLineItemHandler();
        
        Account acc = new Account();
            acc.Name = 'ValueLabs LLP';
            insert acc;
        
        Contact contac = new Contact();
            contac.FirstName = 'Sai';
            contac.LastName = 'Karthik';
            contac.AccountId = acc.Id;
            insert contac;
        
        fferpcore__Company__c comp = new fferpcore__Company__c();
            comp.Name = 'Citation Limited';
            insert comp;

        ffbc__Contract__c contract = new ffbc__Contract__c();
            contract.ffbc__ContractName__c = 'ValueLabs Billing Contract';
            contract.ffbc__Account__c = acc.Id;
            contract.Contract_Type__c = 'New';
            contract.ffbc__Company__c = comp.Id;
            contract.ffbc__StartDate__c = Date.newInstance(2018, 11, 11);
            contract.ffbc__EndDate__c = Date.newInstance(2019, 11, 11);
            insert contract;

        SBQQ__Quote__c quoteCpq = new SBQQ__Quote__c();
            quoteCpq.SBQQ__StartDate__c = Date.newInstance(2020, 11, 11);
            quoteCpq.SBQQ__Status__c = 'Approved';
            quoteCpq.SBQQ__PrimaryContact__c = contac.Id;
            quoteCpq.Customer_Signatory__c = contac.Id;
            insert quoteCpq;
        
        Contract cont = new Contract();
            cont.Billing_Contract__c = contract.Id;
            cont.Name = 'ValueLabs Contract';
            cont.StartDate = Date.newInstance(2018, 11, 11);
            cont.ContractTerm = 12;
            cont.FOC_Period_Mths__c = 3;
            cont.FOC_Period_Mths_End__c = 12;
            cont.Service_Type__c = 'Citation';
            cont.Status = 'Draft';
            cont.Renewal_Type__c = 'Auto';
            cont.Business_Type__c = 'New Business';
            cont.AccountId = acc.Id;
            cont.Total_Contract_Value__c = 1000;
            cont.Payment_Period__c = 'Monthly';
            cont.Preferred_Payment_Date__c = '7';
            cont.Agreement_Type__c  = 'Auto';
            insert cont;
        
        Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'ValueLabs Opportunity';
            opp.ContractId = cont.Id;
            opp.StageName = 'Appointment';
            opp.CloseDate = Date.newInstance(2020, 11, 11);
            insert opp;

        Product2 p2 = new Product2();
            p2.Product_Grouping__c = 'Audit - Contract';
            p2.Name = 'Additional Tribunal Day';
            insert p2;

        Revenue_Recognition_Logic__c rrl = new Revenue_Recognition_Logic__c();
            rrl.Product_Grouping__c = 'Audit - Contract';
            rrl.Selling_Company__c = 'Citation Limited';
            rrl.Term_months__c = 13;
            rrl.New_or_Renewal__c = 'New';
            insert rrl;
        
        ffbc__ContractLineItem__c ffb = new  ffbc__ContractLineItem__c();
            ffb.ffbc__ProductService__c = p2.Id;
            ffb.ffbc__Contract__c = contract.Id;
            ffb.Service_Start_Date__c = Date.newInstance(2017, 10, 11);
            ffb.Service_End_Date__c = Date.newInstance(2018, 11, 11);
            ffb.Revenue_Recognition_Logic__c = rrl.Id;
            ffb.Migrated_from_Sage__c = false;
            insert ffb;
      
    }

    public static testMethod void testMigratedFromStage(){
        
        ffbc__ContractLineItem__c ffbc_CLI = [SELECT id,ffbc__ProductService__c,Migrated_from_Sage__c from ffbc__ContractLineItem__c
                                             WHERE Migrated_from_Sage__c = false LIMIT 1];
        	
		Test.startTest();
        ffbc_CLI.Migrated_from_Sage__c = true;
        update ffbc_CLI;
        Test.stopTest();
        
        
        ffbc__ContractLineItem__c cliCheck = [select id,ffrrtemplate__c from ffbc__ContractLineItem__c where id = :ffbc_CLI.id] ;

        ffrr__Template__c ffrrtemplate =  [select id from ffrr__Template__c];

        system.assertEquals(ffrrtemplate.id, cliCheck.ffrrtemplate__c) ;

    }
    
    public static testMethod void testNoCompanyUpdate(){
        
        ffbc__ContractLineItem__c ffbc_CLI = [SELECT id,ffbc__ProductService__c,Migrated_from_Sage__c from ffbc__ContractLineItem__c
                                             WHERE Migrated_from_Sage__c = false LIMIT 1];
       System.debug('Star' + ffbc_CLI); 
		Test.startTest();
        	ffbc_CLI.Migrated_from_Sage__c = true;
        	ffbc_CLI.Revenue_Recognition_Logic__c = NULL;
            DELETE [SELECT ID, Selling_Company__c FROM Revenue_Recognition_Logic__c];
        	Update ffbc_CLI;
        Test.stopTest();
          
        ffbc__ContractLineItem__c cliCheck = [select id,ffrrtemplate__c from ffbc__ContractLineItem__c where id = :ffbc_CLI.id] ;

        ffrr__Template__c ffrrtemplate =  [select id from ffrr__Template__c];

        system.assertEquals(ffrrtemplate.id, cliCheck.ffrrtemplate__c) ;
    } 
    public static testMethod void testCombinedPackage(){
        
        list<ffbc__ContractLineItem__c> clis = new list<ffbc__ContractLineItem__c>();  
        ffbc__Contract__c contract = [Select Id, ffbc__Account__c from ffbc__Contract__c where ffbc__ContractName__c = 'ValueLabs Billing Contract'];
      /*  Account acct = new Account();
            acct.Name = 'Test Account';
            insert acct;  */
        
      /*  ffbc__Contract__c contract1 = new ffbc__Contract__c();
            contract1.ffbc__ContractName__c = 'Citation Contract';
            contract1.ffbc__Account__c = acct.Id;
            contract1.Contract_Type__c = 'New';
            //contract.ffbc__Company__c = comp.Id;
            contract1.ffbc__StartDate__c = Date.newInstance(2021, 04, 1);
            contract1.ffbc__EndDate__c = Date.newInstance(2021, 05, 30);
            insert contract1; */
         
       Product2 coreProd1 = new Product2();
        	coreProd1.Name = 'Core Product One';
        	coreProd1.Core_Product__c = True;
        	insert coreProd1;
        
       Product2 coreProd2 = new Product2();
        coreProd2.Name = 'Core Product 2';
        coreProd2.Core_Product__c = True;
        insert coreProd2;
        
        ffbc__ContractLineItem__c ffb1 = new  ffbc__ContractLineItem__c();
        ffb1.ffbc__ProductService__c = coreProd1.Id;
        ffb1.ffbc__Contract__c = contract.Id;
        ffb1.Service_Start_Date__c = Date.newInstance(2018, 11, 12);
        ffb1.Service_End_Date__c = Date.newInstance(2019, 11, 10);
        ffb1.ffbc__StartDate__c = Date.newInstance(2018, 11, 20);
        ffb1.ffbc__EndDate__c = Date.newInstance(2019, 11, 1);
        clis.add(ffb1);
        
        ffbc__ContractLineItem__c ffb2 = new  ffbc__ContractLineItem__c();
        ffb2.ffbc__ProductService__c = coreProd2.Id;
        ffb2.ffbc__Contract__c = contract.Id;
        ffb2.Service_Start_Date__c = Date.newInstance(2018, 11, 12);
        ffb2.Service_End_Date__c = Date.newInstance(2019, 11, 10);
        ffb2.ffbc__StartDate__c = Date.newInstance(2018, 11, 20);
        ffb2.ffbc__EndDate__c = Date.newInstance(2019, 11, 1);
        clis.add(ffb2);
        Test.startTest();
        insert clis;
        //Test.stopTest();
        
        clis[0].ffbc__EndDate__c = Date.newInstance(2019, 11, 09);
        clis[1].ffbc__EndDate__c = Date.newInstance(2019, 11, 07);
        //Test.startTest();
        update clis;
        Test.stopTest();
        
    }
        
  
}