@isTest
public class uploadFileControllerTest {
    
    static testmethod void duplicatePm(){
        String str='(Test01,Pragati nagar,Hyderabad,500090,Mr,John,Kennedy,43216,987654321,test@test.com,www.kennedy.com,12,12345,23/06/2021,1,TRUE,TRUE'+'\n'
            +')';
        Test.startTest();  
        /* Account Object */
        Account accountDetails = new Account();      
        accountDetails.Name = 'test accont';    
        insert accountDetails;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Test',
            PathOnClient   = 'Test.csv',
            VersionData    = Blob.valueOf(str),
            IsMajorVersion = true);
        insert contentVersion; 
        Id getId = [Select ContentDocumentId From ContentVersion Where Id =:contentVersion.id and isLatest=true].ContentDocumentId;        
        uploadFileController.readCSVFile(getId, accountDetails.Id);        
        Test.stopTest();
    }
    static testmethod void amendPartnersTest(){
        
        Test.startTest();  
        /* Account Object */
        Account accountDetails = new Account();      
        accountDetails.Name = 'test accont';
        accountDetails.Is_Active_Partner__c = true;
        accountDetails.Total_H_S_Member_Atlas_Access_Units__c = 5;
        insert accountDetails;
        
        Partner_Member_Relationship__c objpmr = new Partner_Member_Relationship__c();
        objpmr.H_S_Access_Unit_Assigned__c = 'H&S How-To Hub';
        objpmr.HR_Access_Unit_Assigned__c = 'HR How-To Hub';
        objpmr.Partner__c = accountDetails.Id;
        insert objpmr;
        
        String str= objpmr.Id+',Pragati nagar,Hyderabad,500090,Mr,John,9/9/2021,43216,987654321,test@test.com,www.kennedy.com,12,12345,23/06/2021,1,TRUE,TRUE'+'\n'
            +')';
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'assign Partners',
            PathOnClient   = 'Test.csv',
            VersionData    = Blob.valueOf(str),
            IsMajorVersion = true);
        insert contentVersion; 
        Id getId = [Select ContentDocumentId From ContentVersion Where Id =:contentVersion.id and isLatest=true].ContentDocumentId;        
        uploadFileController.readCSVFile(getId, accountDetails.Id);        
        Test.stopTest();
    }
}