@isTest
private class bg_Active_Campaign_Checker_HelperTest {
	@isTest
    static void test_getInRangeActiveSeminarNamesDescriptionByLeadId() {
        
         Map<String, String> campaignNameDescriptionMap = new Map<String, String>();
		List<Campaign> campList1 = TestDataFactory.getCampaigns(100 , 'testCamp1' ,null,true);
        List<Campaign> campList2 = TestDataFactory.getCampaigns(100 , 'testCamp2' ,'testDescp',true);
        campList2.addAll(campList1);
		
		Test.StartTest();
			campaignNameDescriptionMap	= bg_Active_Campaign_Checker_Helper.getInRangeActiveSeminarNamesDescriptionByLeadId(campList2);
		Test.stopTest();
			System.AssertEquals('No Description',campaignNameDescriptionMap.get('testCamp1 1'));
        	System.AssertEquals('testDescp',campaignNameDescriptionMap.get('testCamp2 1'));
		
    }
    
    @isTest
    static void test_getActiveCampaigns() {
        List<Campaign> nCamp = new List<Campaign>();
        Test.StartTest();
			nCamp	= bg_Active_Campaign_Checker_Helper.getActiveCampaigns('Test',new Lead(),0.01 );
		Test.stopTest();
        System.assertEquals(NULL, nCamp);
    }
    
    @isTest
    static void test_getActiveCampaignRelatedtoGeoCode() {
	List<Campaign> nCamp = new List<Campaign>();
	Test.StartTest();
			nCamp	= bg_Active_Campaign_Checker_Helper.getActiveCampaignRelatedtoGeoCode(new Set<Id>() );
	Test.stopTest();
        System.assertEquals(NULL, nCamp);   
    }
}