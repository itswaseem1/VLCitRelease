@isTest
private class bg_NonRenewalSurvey_Tests {

    public static final String OPPORTUNITY_RT_DEFAULT_CITATION_OPPORTUNITY = 'Default Citation Opportunity';


    @testSetup static void setupData() {
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000000.0, 0.0);
        insert pricebook;
    }


    @isTest static void Create_Closed_Lost_Non_Renewal_testOpportunity_Survey() {

        Test.startTest();

        Account testAccount;
        Contact testContact;
        Contract testContract;
        
        testAccount = bg_Account_TestUtils.createCitationAccount('test 1', 1000.00);
        testAccount.CALC_Citation_Contract__c = 1;
        testAccount.Cluster_Start_Date__c = Date.today().addDays(-90);
        insert testAccount;

        testContact = bg_Contact_TestUtils.createContact('test 1', testAccount.Id);
        testContact.FirstName = 'test';
        testContact.LastName = 'test';
        testContact.Main_User__c = 'Yes';
        testContact.HasOptedOutOfEmail = False;
        testContact.Email = 'test@test.test';
        insert testContact;

        testContract = bg_Contract_TestUtils.createContract('1', testAccount.Id);
        testContract.CustomerSignedId = testContact.Id;
        testContract.CustomerSignedDate = Date.today().addDays(-90);
        insert testContract;

        Opportunity testOpp = bg_Unit_Test_Helper.createOpportunity('test 1', OPPORTUNITY_RT_DEFAULT_CITATION_OPPORTUNITY, testAccount, testContact);
        upsert testOpp;

        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = testContact.Id;
        ocr1.OpportunityId = testOpp.Id;
        ocr1.IsPrimary = TRUE;
        ocr1.Role = 'Decision Maker';
        insert ocr1;

        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId = testContact.Id;
        ocr2.OpportunityId = testOpp.Id;
        ocr2.IsPrimary = TRUE;
        ocr2.Role = 'Economic Buyer';
        insert ocr2;

        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.ContactId = testContact.Id;
        ocr3.OpportunityId = testOpp.Id;
        ocr3.IsPrimary = TRUE;
        ocr3.Role = 'Test, don\'t expect a survey record for this role!';
        insert ocr3;

        // update the opp
        testOpp.SendSatmetrixClosedLostSurvey__c = True;

        testOpp.Ready_For_Renewal__c = True;
        testOpp.StageName = bg_Constants.OPPORUNITY_STAGE_CLOSED_LOST;
        testOpp.Brightgen_Multi_select__c = 'Cost';
        testOpp.Lost_Reason_Notes__c = 'Test Lost Opp';
        testOpp.Brightgen_Multi_select__c = 'Bringing in house';
        testOpp.Accepted_Quote__c = True;
        testOpp.New_Service_Form_Returned__c = True;
        testOpp.Probability = 100;
        testOpp.Contract_Signed__c = True;
        testOpp.Contract_Length_Years__c = 3;
        testOpp.Contract_End_Date__c = Date.today()-45;
        update testOpp;

        Test.stopTest();

        // Assertions
        List<NPX_Survey_Record__c> surveyRecords = [select Account__c, Contact__c from NPX_Survey_Record__c];
        //system.assertEquals(2, surveyRecords.size());
        //system.assertEquals(testAccount.Id, surveyRecords.get(0).Account__c);
        //system.assertEquals(testContact.Id, surveyRecords.get(0).Contact__c);
   }

}