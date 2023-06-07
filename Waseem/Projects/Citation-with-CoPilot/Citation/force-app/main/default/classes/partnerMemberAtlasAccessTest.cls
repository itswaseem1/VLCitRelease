@isTest
public class partnerMemberAtlasAccessTest {
    
    static testMethod void TestSetPartner() {
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Citation Partnership').getRecordTypeId();
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Citation Partner Referral').getRecordTypeId(); 
        List<Partner_Member_Relationship__c> partnerMemberListToUpdate= new List<Partner_Member_Relationship__c>();
        List<Partner_Member_Relationship__c> partnerMemberList=new List<Partner_Member_Relationship__c>();
        
        Account parentAcc = new Account();
        parentAcc.Name = 'testName';
        parentAcc.Phone = '09876543210';
        parentAcc.AnnualRevenue = 100000;     
        parentAcc.Sites__c = 1; 
        parentAcc.Is_Active_Partner__c=true;
        parentAcc.CoreCitationContractMonths__c=1;
	parentAcc.Assigned_HR_Member_Atlas_Access_Units__c = 10;
	parentAcc.Assigned_H_S_Member_Atlas_Access_Units__c = 10; 
        insert parentAcc;
        
        Contact con=new Contact();       
        con.LastName='test';
        con.AccountId=parentAcc.id;
        insert con;
        
        Lead led=new Lead();
        led.LastName='test lead';
        led.Company='test';
        led.Email = 'test@test.com';
        led.FT_Employees__c=1;
        led.PT_Employees__c=1;
        led.Directors__c=1;
        led.Subcontractors__c=1;
        led.Status='Open';
        led.LeadSource='Advert';
        led.RecordTypeId = leadRecordTypeId;
        led.CitationSector__c = 'CARE';
        led.Sector__c ='CARE';
        led.Approved_Date__c = system.today();
        led.Approved_By__c='Test User';
        insert led;
        
        Partner_Member_Relationship__c part=new Partner_Member_Relationship__c();
        part.Partner__c=parentAcc.id;
        part.Member_Lead__c=led.id;       
        part.Name='testpartner'; 
        //part.HR_Access_Unit_Assigned__c='HR How-To Hub';
        //part.H_S_Access_Unit_Assigned__c='H&S How-To Hub';
        insert part; 
        
        Contract cont= new Contract();
        cont.Name='test contract';
        cont.AccountId=parentAcc.id;       
        cont.StartDate=System.today().addMonths(1);
        cont.ContractTerm=12;
        cont.FOC_Period_Mths__c=0;
        cont.FOC_Period_Mths_End__c =0;  
        cont.Partner_Member_Id__c=part.Id;
        cont.Status='Draft';
        cont.Renewal_Type__c='Non-Auto';
        cont.Business_Type__c='New Business';
        cont.Payment_Period__c='monthly';
        cont.Preferred_Payment_Date__c='7';
        cont.Contract_Value__c=0;   
        cont.CustomerSignedId=con.id;
        cont.RecordTypeId=contractRecordTypeId;
        cont.HR_Member_Atlas_Access_Units__c = 2;
        insert cont;
        
        String partnerAccId=parentAcc.Id;
        Test.startTest();
        cont.Status = 'Pending Start';
        update cont;
        partnerMemberAtlasAccess.fetch(part.Id);
        partnerMemberAtlasAccess.getAccount(partnerAccId);  
        partnerMemberAtlasAccess.assignUnits(new List<Partner_Member_Relationship__c>{part}, partnerAccId,1,1);
        partnerMemberAtlasAccess.fetchUnassign(part.Id);
        partnerMemberList = [Select Id,Name,Partner__c,Member_Lead__c,Member__c,HR_Access_Unit_Assigned__c, H_S_Access_Unit_Assigned__c From Partner_Member_Relationship__c];
	partnerMemberList[0].Member_left_Partner_date__c = system.today();
        partnerMemberListToUpdate.add(partnerMemberList[0]);
        partnerMemberAtlasAccess.unassignUnits(partnerMemberList, partnerMemberListToUpdate, partnerAccId);
	ByPassUtils.UndoByPass('TestTrigger');
        Test.stopTest();
    }
}