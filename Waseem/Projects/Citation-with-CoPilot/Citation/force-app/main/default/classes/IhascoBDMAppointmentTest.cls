@isTest
Private class IhascoBDMAppointmentTest {
   @isTest
    static void IhascoBDMAppoitnment(){
        
      User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'iHasco NBM'].Id,
     LastName = 'Prospect',
     Email = 'Prospectuser@citation.co.uk',
     Username = 'Prospectuser@citation.co.uk' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
   );
        insert u;
        
        lead Ld = new lead();
        Ld.LastName = 'Userprospect';
        Ld.Company='DDFG';
        Ld.Status='open';
        Ld.OwnerId=u.id;
        Ld.Current_training_method__c='Online';
        Ld.Current_training_delivered__c='tsgd';
        Ld.Number_Of_Sites__c=3;
        Ld.NumberOfEmployees=2;
        Ld.RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default IHASCO').getRecordTypeId();
        insert Ld;
        
        IhascoBDMAppointment.ihascoBDM(Ld.Id);
               
    }

}