@isTest
public class FetchReportResultsTest {

    @isTest(SeeAllData=true)
    public static void TestgetRecordIdList(){
        
                // Get the report ID
                
                List <Report> reportList = [SELECT Id,name FROM Report where Name = 'Check for missing renewal opps' ];
                Id reportId = ((String)reportList.get(0).get('Id')).left(15);
        		FetchReportResults FRR = new FetchReportResults();
        		Test.startTest();
                lIST<ID> tlid = FRR.getRecordIdList(reportId,'Opportunity');  
        		test.stopTest();
    }
}