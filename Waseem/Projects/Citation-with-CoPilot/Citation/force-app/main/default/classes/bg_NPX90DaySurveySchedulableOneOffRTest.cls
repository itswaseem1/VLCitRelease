@isTest
private class bg_NPX90DaySurveySchedulableOneOffRTest {

    @testSetup static void setup()
  {
    List<Account> accList = TestDataFactory.getAccounts(10,'TestAcc',false);
        for(Account ac : accList){
            ac.CALC_Citation_Contract__c = 1;
              
        }
        insert accList;
        List<Contact> conList = new List<Contact>(); 
        integer i = 0;
        for(Account acc: accList){
          List<Contact> c = TestDataFactory.getContacts(1,'TestFN','TestLN',acc.id,false);
          c[0].Email = 'Test5432' + i +  '@test.com';
          c[0].HasOptedOutOfEmail = false;
          c[0].Main_User__c = 'Yes';
          c[0].Online_Super_User__c  = 'Yes';
          c[0].Service_Owner__c = true; 
          conList.add(c[0]);
          i++;
      }
        insert conList;
        
        List<opportunity> oppList = new List<opportunity>();
        for(Account acc: accList){
            oppList.addall(TestDataFactory.generateOppsForAccount(acc.Id,1000,1,false));
        }
        
        Map<id,contact> conMap = new Map<id, Contact>();
        for(Contact c: [select id , accountid from contact]){
            conMap.put(c.AccountId,c);
        }
         List<Contract> contrList = new List<Contract>();
        for(Account acc: accList){
            Contract c = new Contract();
            c.name = 'Test';
            c.ContractTerm = 24;
            c.AccountId = acc.Id;
            c.Status = 'Draft';
            c.Renewal_Type__c = 'Auto';
            c.FOC_Period_Mths__c = 1;
            c.FOC_Period_Mths_End__c = 12;
            c.Service_Type__c = 'Citation';
            c.Business_Type__c = 'New Business';
            c.Contract_Value__c = 1000;
            c.Payment_Period__c = 'monthly';
            c.Preferred_Payment_Date__c = '7';
            c.CustomerSignedId = conMap.get(acc.id).Id;
            contrList.add(c);
        }
      test.startTest();
        insert contrList;
      test.stopTest();
    
  }
    
    static testMethod void testGetAnniversaries(){
        
        test.startTest();
            List<Date> anniversaries = bg_NPX90DaySurvey_Schedulable_OneOffRuns.getAnniversaries();
        test.stopTest();

        //system.assertEquals(4, anniversaries.size());
    }

    static testMethod void testExecute(){
                
    NPX_90_Day_Survey_Account_Mapping__c accountMapping = new NPX_90_Day_Survey_Account_Mapping__c();
    accountMapping.Name = 'Account__c';
    accountMapping.SF_Field_Name__c = 'Id';
    insert accountMapping;

    NPX_90_Day_Survey_Contact_Mapping__c contactMapping = new NPX_90_Day_Survey_Contact_Mapping__c();
    contactMapping.Name = 'Contact__c';
    contactMapping.SF_Field_Name__c = 'Id';
    insert contactMapping;
        
        List<Account> accList = new List<Account>();
        For(Account ac: [SELECT Id,Cluster_Start_Date__c from Account]){
            ac.Cluster_Start_Date__c = Date.today().addDays(-94);  
            accList.add(ac);
        }
        update accList;
        
        List<Contract> contrList = new List<Contract>();
        For(Contract c: [SELECT Id, CustomerSignedDate  from Contract]){
            c.CustomerSignedDate = Date.today().addDays(-94);  
            contrList.add(c);
        }
        update contrList;
        
        test.startTest();
            bg_NPX90DaySurvey_Schedulable_OneOffRuns ssoor = new bg_NPX90DaySurvey_Schedulable_OneOffRuns();
            string schedule = '0 0 23 * * ?';
            system.schedule('Test Update', schedule, ssoor);
        test.stopTest();
        //System.assertEquals(10,[SELECT count() from NPX_Survey_Record__c]);
    }
    
    static testMethod void testException(){
        
        List<Account> accList = new List<Account>();
        For(Account ac: [SELECT Id,Cluster_Start_Date__c from Account]){
            ac.Cluster_Start_Date__c = Date.today().addDays(-94);  
            accList.add(ac);
        }
        update accList;
        
        List<Contract> contrList = new List<Contract>();
        For(Contract c: [SELECT Id, CustomerSignedDate  from Contract]){
            c.CustomerSignedDate = Date.today().addDays(-94);  
            contrList.add(c);
        }
        update contrList;
        
    NPX_90_Day_Survey_Contact_Mapping__c contactMapping = new NPX_90_Day_Survey_Contact_Mapping__c();
    contactMapping.Name = 'Contact__c';
    contactMapping.SF_Field_Name__c = 'lastname';
     test.startTest();
    insert contactMapping;
        
        
        
            bg_NPX90DaySurvey_Schedulable_OneOffRuns ssoor = new bg_NPX90DaySurvey_Schedulable_OneOffRuns();
            string schedule = '0 0 23 * * ?';
            system.schedule('Test Update', schedule, ssoor);
          Integer I = Limits.getEmailInvocations();
        test.stopTest();
        //System.assertEquals(0,[SELECT count() from NPX_Survey_Record__c]);
    }

}