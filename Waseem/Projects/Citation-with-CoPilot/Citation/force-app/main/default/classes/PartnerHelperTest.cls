@isTest
public class PartnerHelperTest {
    
    static testMethod void TestsetAccount() {
        List<Partner_Member_Relationship__c> partlist=new List<Partner_Member_Relationship__c>();
        Account acc = new Account();
        acc.Name = 'testName';
        acc.Phone = '09876543210';
        acc.AnnualRevenue = 100000;     
        acc.Sites__c = 1;        
        insert acc;
        
        Partner_Member_Relationship__c part=new Partner_Member_Relationship__c();
        part.Partner__c=acc.id;
        part.Name='testpartner';
        insert part;
        
        for(Partner_Member_Relationship__c part1 :[Select id from Partner_Member_Relationship__c where id=:part.id]){
            part1.H_S_Access_Unit_Assigned__c='H&S How-To Hub';
            part1.HR_Access_Unit_Assigned__c= 'HR How-To Hub';
            partlist.add(part1);
        }
        test.startTest();
        update partlist;
        test.stopTest();
        
    }
}