@isTest
public class PartnerRenewalOpportunityBatchTest {
    
    public static testMethod void executeData(){
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();
        Account partnerAcc = new Account();
        partnerAcc.Name = 'Citation Account';
        partnerAcc.PT_Employees__c=20;
        partnerAcc.FT_Employees__c=20;
        partnerAcc.Sites__c=5;
        partnerAcc.AccountSource='Partnership';
        insert partnerAcc;
        Contact contactRec = new Contact(LastName='Rama',Email='ramadevithota@citation.co.uk',AccountId=partnerAcc.Id);
        insert contactRec;
        
        Id pricebookId = Test.getStandardPricebookId();
        opportunity opp=new opportunity();
        opp.name='test opp';
        opp.StageName='Renewal Contact Due';
        opp.CloseDate=System.today().addMonths(1);
        opp.accountid=partnerAcc.id;
        opp.DateMade__c=System.today().addMonths(2);
        opp.LeadSource='Partnership';
        opp.Amount=100;
        opp.Type='Partner';
        insert opp;
        
        OpportunityContactRole oppcon=new OpportunityContactRole();
        oppcon.OpportunityId=opp.id;
        oppcon.ContactId=contactRec.id;
        oppcon.IsPrimary=true;
        insert oppcon;
        
        Sbqq__Quote__c partnerQuote = new Sbqq__Quote__c();
        partnerQuote.SBQQ__PrimaryContact__c = contactRec.Id;
        partnerQuote.SBQQ__StartDate__c = System.today();
        partnerQuote.SBQQ__Opportunity2__c=opp.id;
        partnerQuote.Initial_Payment__c=1000;
        insert partnerQuote;        
        
        Contract conRec = new Contract();
        conRec.Name = 'New Citation Contract';
        conRec.AccountId = partnerAcc.Id;
        conRec.SBQQ__Quote__c=partnerQuote.Id;
        conRec.Source_Opportunity__c=opp.Id;
        conRec.Status = 'Draft';
        conRec.Renewal_Type__c = 'Auto';
        conRec.Business_Type__c = 'New Business';
        conRec.StartDate = System.today();
        conRec.ContractTerm = 1;
        conRec.FOC_Period_Mths__c = 20;
        conRec.FOC_Period_Mths_End__c = 10;
        conRec.Service_Type__c = 'Citation';
        conRec.Agreement_Type__c = 'Paper';
        conRec.CustomerSignedId = contactRec.Id;
        conRec.RecordTypeId=contractRecordTypeId;
        conRec.Ts_Cs_Version__c = null;
        conRec.Total_Contract_Value__c=1000;
        conRec.Core_Compliance_TCV__c=100;
        conRec.Initial_Payment2__c=1000;
        
        Test.startTest();
        insert conRec;
        
        conRec.ContractTerm=3;
        update conRec;
        Database.executeBatch(new PartnerRenewalOpportunityBatch());
        Test.stopTest();        
    }    
}