@isTest 
public class LeadIndividualProcess_Test {
    public static ID recId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default Citation Record Type').getRecordTypeId();
	 static testMethod void executeTest() 
    {
        
        List<Lead> ldList = TestDataFactory.getLeads(50,'TestFN','TestCompany',false);
        integer i = 0;
        for(Lead c : ldList){
            c.RecordTypeId = recId;
            c.email = 'test' + i + '@test.com';
            c.Renewal_Date__c = SYSTEM.TODAY().ADDDAYS(2);
            i++;
        }
        insert ldList;
        for(Lead c : ldList){
            c.individualId = null;
            c.Renewal_Date__c = SYSTEM.TODAY().ADDDAYS(2);
        }
        update ldList;
     /*   i = 0;
        List<Individual> indvlList = [SELECT Id from Individual WHERE Email__c LIKE 'test%'];
        for(individual ind : indvlList){
            ind.email__c = 'chgtest' + i + '@test.com';
        }
        update indvlList; */
        
        Test.startTest();
			LeadIndividualProcess obj = new LeadIndividualProcess();
            DataBase.executeBatch(obj); 
        Test.stopTest();
        
        SYSTEM.assertEquals(50, [SELECT count() from Individual WHERE Email__c LIKE 'test%']);
        	
       
    }
}