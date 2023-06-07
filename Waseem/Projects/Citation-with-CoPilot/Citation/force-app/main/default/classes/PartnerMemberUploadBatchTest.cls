@isTest
public class PartnerMemberUploadBatchTest {
    @testSetup
    public static void makeData(){
        /* Member Account Object */
        Account accountDetails = new Account();      
        accountDetails.Name = 'Partner Upload';
        accountDetails.Phone='3333355555';
        accountDetails.Company_Registration_Number__c='6789';
        accountDetails.Street__c='KPHB';
        accountDetails.Post_Code__c='500072';  
        accountDetails.Website='https://www.google.co.in/';
        insert accountDetails;
        
        /* Account Object */
        Account partnerAcc = new Account();      
        partnerAcc.Name = 'Partner Account';
        partnerAcc.Total_HR_Member_Atlas_Access_Units__c = 10;
        partnerAcc.Total_H_S_Member_Atlas_Access_Units__c = 10;
        partnerAcc.PartnerType__c = 'Partner';
        partnerAcc.Is_Active_Partner__c = true;
        insert partnerAcc;
        
        /* Contact Object */        
        Contact contactDetails= new Contact();
        contactDetails.AccountId = accountDetails.Id;
        contactDetails.LastName = 'Upload';
        contactDetails.FirstName = 'Partner';
        contactDetails.MobilePhone = '123456789';
        contactDetails.Email = 'test@gmail.com';
        contactDetails.MailingCity='hyd';
        contactDetails.MailingStreet='KPHB';
        contactDetails.MailingPostalCode='500072';
        contactDetails.Phone='3333355555';
        insert contactDetails;
    }
    static testmethod void duplicatePm(){
        
        Lead objLead = new Lead();
        objLead.Company = 'ValueLabs ltd';
        objLead.Status = 'Open';
        objLead.Salutation='Mr.';
        objLead.FirstName ='Partner';
        objLead.LastName ='Upload';
        objLead.Email='test@gmail.com';
        objLead.LeadSource = 'Website';
        objLead.Phone='3333355555';
        insert objLead; 
        
        Partner_Member_Upload__c pmu=new Partner_Member_Upload__c();
        pmu.Partner__c = [Select Id from Account Where Name='Partner Account' LIMIT 1].Id;
        pmu.City__c='hyd';
        pmu.Company_Registration_Number__c='6789';
        pmu.Email__c='test@gmail.com';
        pmu.Salutation__c='Mr.';
        pmu.First_Name__c='Partner';
        pmu.Last_Name__c='Upload';
        pmu.Street__c='KPHB';
        pmu.Postcode__c='500072';
        pmu.Phone__c='3333355555';
        pmu.Website__c='https://www.google.co.in/';
        pmu.Assign_How_to_Access_Units__c = true;
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(pmu, insertDML);
        Database.executeBatch(new PartnerMemberUploadBatch());
    }
    
    static testmethod void duplicatePm2(){
        Account acc = [Select Id from Account where Name='Partner Upload' LIMIT 1];
        acc.CoreCitationContractMonths__c = 6;
        Database.update(acc);
        
        Partner_Member_Upload__c pmu=new Partner_Member_Upload__c();
        pmu.Partner__c = [Select Id from Account Where Name='Partner Account' LIMIT 1].Id;
        pmu.City__c='hyd';
        pmu.Company_Registration_Number__c='6789';
        pmu.Email__c='test@gmail.com';
        pmu.Salutation__c='Mr.';
        pmu.First_Name__c='Partner';
        pmu.Last_Name__c='Upload';
        pmu.Street__c='KPHB';
        pmu.Postcode__c='500072';
        pmu.Phone__c='3333355555';
        pmu.Website__c='https://www.google.co.in/';
        pmu.Assign_How_to_Access_Units__c = true;
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(pmu, insertDML);
        Database.executeBatch(new PartnerMemberUploadBatch());
    }
    static testmethod void duplicatePm3(){
        Partner_Member_Upload__c pmu=new Partner_Member_Upload__c();
        pmu.Partner__c = [Select Id from Account Where Name='Partner Account' LIMIT 1].Id;
        pmu.City__c='hyd';
        pmu.Company_Registration_Number__c='6789';
        pmu.Email__c='test@gmail.com';
        pmu.Salutation__c='Mr.';
        pmu.First_Name__c='Partner';
        pmu.Last_Name__c='Upload';
        pmu.Street__c='KPHB';
        pmu.Postcode__c='500072';
        pmu.Phone__c='3333355555';
        pmu.Website__c='https://www.google.co.in/';
        pmu.Assign_How_to_Access_Units__c = true;
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(pmu, insertDML);
        Database.executeBatch(new PartnerMemberUploadBatch());
    }
    static testmethod void duplicatePm4(){
        Account acc = [Select Id from Account where Name='Partner Upload' LIMIT 1];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Appointment';
        opp.CloseDate = system.today() + 365;
        opp.Type ='Partner';
        insert opp;
        
        Partner_Member_Upload__c pmu=new Partner_Member_Upload__c();
        pmu.Partner__c = [Select Id from Account Where Name='Partner Account' LIMIT 1].Id;
        pmu.City__c='hyd';
        pmu.Company_Registration_Number__c='6789';
        pmu.Email__c='test@gmail.com';
        pmu.Salutation__c='Mr.';
        pmu.First_Name__c='Partner';
        pmu.Last_Name__c='Upload';
        pmu.Street__c='KPHB';
        pmu.Postcode__c='500072';
        pmu.Phone__c='3333355555';
        pmu.Website__c='https://www.google.co.in/';
        pmu.Assign_How_to_Access_Units__c = true;
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(pmu, insertDML);
        Database.executeBatch(new PartnerMemberUploadBatch());
    }
    static testmethod void duplicatePm5(){
        Account acc = [Select Id from Account where Name='Partner Upload' LIMIT 1];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Closed Lost';
        opp.Originating_Closed_Lost_Opportunity_id__c ='1234';
        opp.CloseDate = system.today() + 365;
        opp.Type ='Partner';
        insert opp;
        
        Partner_Member_Upload__c pmu=new Partner_Member_Upload__c();
        pmu.Partner__c = [Select Id from Account Where Name='Partner Account' LIMIT 1].Id;
        pmu.City__c='hyd';
        pmu.Company_Registration_Number__c='6789';
        pmu.Email__c='test@gmail.com';
        pmu.Salutation__c='Mr.';
        pmu.First_Name__c='Partner';
        pmu.Last_Name__c='Upload';
        pmu.Street__c='KPHB';
        pmu.Postcode__c='500072';
        pmu.Phone__c='3333355555';
        pmu.Website__c='https://www.google.co.in/';
        pmu.Assign_How_to_Access_Units__c = true;
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(pmu, insertDML);
        Database.executeBatch(new PartnerMemberUploadBatch());
    }
    static testmethod void duplicatePm6(){
        Account acc = [Select Id from Account where Name='Partner Upload' LIMIT 1];
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'Appointment';
        opp.CloseDate = system.today() + 365;
        opp.Type ='Partner';
        opp.StageName ='Closed Lost';
        insert opp;
        
        Lead objLead = new Lead();
        objLead.Company = 'ValueLabs ltd';
        objLead.Status = 'Open';
        objLead.Salutation='Mr.';
        objLead.FirstName ='Partner';
        objLead.LastName ='Upload';
        objLead.Email='test@gmail.com';
        objLead.LeadSource = 'Website';
        objLead.Phone='3333355555';
        insert objLead; 
        
        Partner_Member_Upload__c pmu=new Partner_Member_Upload__c();
        pmu.Partner__c = [Select Id from Account Where Name='Partner Account' LIMIT 1].Id;
        pmu.City__c='hyd';
        pmu.Company_Registration_Number__c='6789';
        pmu.Email__c='test@gmail.com';
        pmu.Salutation__c='Mr.';
        pmu.First_Name__c='Partner';
        pmu.Last_Name__c='Upload';
        pmu.Street__c='KPHB';
        pmu.Postcode__c='500072';
        pmu.Phone__c='3333355555';
        pmu.Website__c='https://www.google.co.in/';
        pmu.Assign_How_to_Access_Units__c = true;
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(pmu, insertDML);
        Database.executeBatch(new PartnerMemberUploadBatch());
        system.schedule('Test status Check', '0 0 3 * * ?', new PartnerMemberUploadBatch());
    }
}