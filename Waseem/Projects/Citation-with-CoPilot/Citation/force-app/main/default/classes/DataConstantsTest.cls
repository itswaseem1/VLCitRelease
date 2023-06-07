@istest
public class DataConstantsTest {
    
        static TestMethod void DataContTest(){
            
            Test.startTest();
            
            DataConstants  dataCont = New DataConstants ();
            
            System.assertEquals('Renewal / Retention Opportunity - Auto', DataConstants.RENEWAL_AUTO_OPPORTUNITY_RECORDTYPE_NAME);
            System.assertEquals('Renewal / Retention Opportunity - Non-Auto', DataConstants.RENEWAL_NON_AUTO_OPPORTUNITY_RECORDTYPE_NAME);
            System.assertEquals('Renewal', DataConstants.RENEWAL_OPPORTUNITY_TYPE);
            System.assertEquals('Edit', DataConstants.OPPORTUNITY_ACCESS_LEVEL_READ_WRITE);
            
            test.stopTest();
        }
    }