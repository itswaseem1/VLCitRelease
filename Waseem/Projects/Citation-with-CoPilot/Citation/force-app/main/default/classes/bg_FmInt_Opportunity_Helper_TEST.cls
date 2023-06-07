@isTest
public class bg_FmInt_Opportunity_Helper_TEST {
    
    static private Id ext_id;
    
    private static void setupCustomSettings() {
            FM_Integration__c integrationSetting = FM_Integration__c.getValues('Host');
            if(integrationSetting == null) {
                integrationSetting = new FM_Integration__c(Name= 'Host');
                integrationSetting.Http_Callout_Endpoint__c = 'test';
                integrationSetting.Http_Callout_Query__c = '?action=POST';
                integrationSetting.Http_Callout_Username__c = 'test';
                integrationSetting.Http_Callout_Password__c = 'test';
                integrationSetting.SF_API_Username__c = 'batman';
                insert integrationSetting;
            }

	}
    
    private static void initialSetup() {
    	setupCustomSettings();
        Id elasRenewalOppRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ELAS Renewal / Retention Opportunity - Non-Auto').getRecordTypeId();             
		Pricebook2 pricebook = bg_Pricebook_TestUtils.createPricebook('1', 10000.0, 0.0);
		insert pricebook;
		User QMSUser = bg_User_TestUtils.createQMSSalesUser('1');
		insert QMSUser;

		Account acc = bg_Account_TestUtils.createQMSAccount('1', 5000.0);
		insert acc;

		Contact cnt = New Contact(FirstName = 'Bruce', LastName = 'Wayne', Account = acc);
		insert cnt;
        
        List<Opportunity> oppList = TestDataFactory.generateOppsForAccount(acc.id,1000,2,false);
        oppList[0].certification__c = 'ISO 9001:2015';
        oppList[0].Sale_Approved__c = false;
        oppList[1].certification__c = 'ISO 9001:2015';
        opplist[1].Sale_Approved__c = true;
        oppList[1].FM_Opportunity_External_Id__c = 'xyz';
	oppList[1].RecordTypeId=elasRenewalOppRecordTypeId;
        oppList[1].StageName='Closed Won';
        insert opplist;
        
	Id pricebookId = Test.getStandardPricebookId();
        
        Product2 productDetails = new Product2();
        productDetails.Name = 'On-Site H&S Site Inspections - Bi-Annually';
        productDetails.ProductCode = 'HS-INSP-Bi-annual';
        productDetails.Online_System_Feature_Enabling__c=true;
        productDetails.Online_System__c='Atlas';
        insert productDetails;
        
        PricebookEntry priceBookEntryDetails = new PricebookEntry();
        priceBookEntryDetails.Pricebook2Id = pricebookId;
        priceBookEntryDetails.Product2Id = productDetails.Id;
        priceBookEntryDetails.UnitPrice = 15;
        priceBookEntryDetails.IsActive = true;
        insert priceBookEntryDetails;        
        
        OpportunityLineItem optline=new OpportunityLineItem();
        optline.OpportunityId=oppList[0].id;
        optline.PricebookEntryId=priceBookEntryDetails.Id;
        optline.Quantity=1;
        optline.TotalPrice=100;
        insert optline;


	}

    @isTest static void testsynchronise(){
        initialSetup() ;
        List<Opportunity> oppList = NEW List<Opportunity>();
        opportunity oppList1 = [SELECT ID,Sale_Approved__c FROM OPPORTUNITY WHERE Sale_Approved__c = FALSE LIMIT 1];
        opportunity oppList2 = [SELECT ID, Sale_Approved__c FROM OPPORTUNITY WHERE Sale_Approved__c = TRUE LIMIT 1];
        
        oppList1.Sale_Approved__c = true;
        oppList2.Sale_Approved__c = false;
        opplist.add(oppList1);
        opplist.add(oppList2);
        update oppList;
        
    }

    @isTest static void elasEmailTest(){        
        initialSetup() ;
        Id elasRenewalOppRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ELAS Renewal / Retention Opportunity - Non-Auto').getRecordTypeId();             
        List<Opportunity> oppList = NEW List<Opportunity>();
        opportunity oppList1 = [SELECT ID,Sale_Approved__c FROM OPPORTUNITY WHERE Sale_Approved__c = FALSE LIMIT 1]; 
        opportunity oppList2 = [SELECT ID, Sale_Approved__c FROM OPPORTUNITY WHERE Sale_Approved__c = TRUE LIMIT 1];
        
        oppList1.RecordTypeId=elasRenewalOppRecordTypeId;
        oppList1.StageName='Closed Won';
        opplist.add(oppList1);
        update oppList;        
        bg_FmInt_Opportunity_Helper.opportunityELASEmail(oppList);
        
    }

}