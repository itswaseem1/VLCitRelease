@isTest 
public class QMS_Opportunity_ContractCreationTest {

    @testSetup static void methodName() 
    {User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
        insert QMSUser;
        Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
        insert pricebook;

		campaign camp = new campaign(name='test') ;
		insert camp ;

		Pricebook2 qmsNewPB = new PriceBook2(Name = 'QMS CPQ');
        insert qmsNewPB;        

        system.runAs(QMSUser)
        {
            Account testAccount = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
            insert testAccount;
            List<Opportunity> oppList = new List<Opportunity>();
            for(Integer i=0;i<10;i++){
               // String num = (string)i;
            Opportunity opp = bg_Opportunity_TestUtils.createQMSOpportunity('1', testAccount.Id, true, 1);
            opp.Ready_For_Renewal__c = True;
            opp.StageName = bg_Constants.OPPORUNITY_STAGE_CLOSED_WON;
            opp.Accepted_Quote__c = True;
            opp.New_Service_Form_Returned__c = True;
            opp.Probability = 100;
            opp.Contract_Signed__c = True;
            opp.Contract_Length_Years__c = 3;
            opp.Contract_End_Date__c = Date.today()-45;
            opp.campaignid = camp.id ;
             oppList.add(opp);   
            }
			test.startTest() ;           
            insert oppList;
            for(opportunity opp:oppList){
               opp.StageName = bg_Constants.OPPORUNITY_STAGE_CLOSED_WON;
            }
            update oppList;
            Test.stopTest();
        }
                                         
                                         
    }
    @isTest static void testBatch() {
        Test.startTest();
        Id batchId = Database.executeBatch(new QMS_Opportunity_ContractCreationBatch());
        Test.stopTest();
        Map<id,opportunity> oppMap= new Map<id,opportunity>([Select id from Opportunity]);
        System.debug([Select id,Recordtype.name from Contract Where SBQQ__Opportunity__c in(Select id from Opportunity)]);
        List<Contract> contracsCreated=[Select id,Recordtype.name from Contract Where SBQQ__Opportunity__c in(Select id from Opportunity)];
        System.assertEquals(10, contracsCreated.size());
    }
}