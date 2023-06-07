@isTest
public class TestIndividualTriggerHandler {
   
   @isTest
   static void testUpdatePreferencesFromPreferenceCenter(){
      List<lead> prospectList = new List<lead>();
      ID recId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default Citation Record Type').getRecordTypeId();
      for(integer i=0;i<2;i++){
         lead led = new lead();
         led.RecordTypeId =recId;
         led.CurrencyIsoCode='EUR';
         led.FT_Employees__c=2;
         led.PT_Employees__c=3;
         led.Directors__c=4;
         led.Subcontractors__c=7;
         led.LeadSource='3rd_party';
         led.Email='test016' + i + '@test.com';
         led.Lastname = 'Test lead'+i;
         led.company = 'Test company'+i;
         led.Sector__c='CARE';
         led.CitationSector__c='CARE';
         led.State='CA';
         led.Country='United States';
         led.Street='1 way citation';
         led.City='Santa Clara';
         led.PostalCode='780987';
         led.Salutation='Mr';
         led.Position__c='CEO';
         led.Appointment_Type__c='Combined';
         led.BDC__c=UserInfo.getUserId();
         led.MADE_Criteria__c ='TBNT cold';
         led.Date_Made__c=System.today();
         led.Status='Data Quality';
         led.Visit_Type__c = 'Virtual';
         prospectList.add(led);
      }
      
      insert prospectList;
      Set<Id> individualIds=new Set<Id>();
      List<Individual> lstIndividual=[SELECT News_service_updates__c
                                             ,News_service_updates_legit_soft__c
                                             ,Eventswebinars__c
                                             ,Events_webinars_legit_soft__c
                                             ,Special_Offers__c
                                             ,New_product_offer_legit_soft__c
                                             ,Atlas_platform_updates__c
                                             ,Atlas_platform_updates_legit_soft__c
                                             ,Referral_scheme_updates__c
                                             ,Referral_scheme_updates_legit_soft__c
                                             ,Citation_Partner_Offers__c
                                             ,Citation_Partner_Offers_Soft_Opt_in__c
                                             ,PR_Surveys__c
                                             ,PR_Surveys_legit_soft__c
                                    FROM Individual ];
     
      Profile p=[SELECT Id from Profile WHERE Name='Citation Data Admin' limit 1];
        User u = new User(Alias = 'jitbit1', Email='jitterbit@citation.co.uk', 
        EmailEncodingKey='UTF-8', LastName=System.Label.API_User_Name, LanguageLocaleKey='en_US', 
        LocaleSidKey='en_GB', ProfileId = p.Id,
        TimeZoneSidKey='Europe/London', UserName='JBUser@testorg.com');
       // System.assertEquals('A','B','User Info is'+u);
        insert u;
        List<Individual> lstIndividualLst=new List<Individual>();
      System.runAs(u){                                                                                                                                   
          for(Individual ind:lstIndividual){
              ind.News_service_updates__c=true;
              ind.Eventswebinars__c=true; 
              ind.Special_Offers__c=true;
              ind.Atlas_platform_updates__c=true; 
              ind.Referral_scheme_updates__c=true; 
              ind.Citation_Partner_Offers__c=true; 
              ind.PR_Surveys__c=true; 
              lstIndividualLst.add(ind);
          }
          Test.startTest();
          if(!lstIndividualLst.isEmpty()){
              update lstIndividualLst;
          }
           Test.stopTest();
      }
      lstIndividual=[SELECT News_service_updates__c
                           ,News_service_updates_legit_soft__c
                           ,Eventswebinars__c
                           ,Events_webinars_legit_soft__c
                           ,Special_Offers__c
                           ,New_product_offer_legit_soft__c
                           ,Atlas_platform_updates__c
                           ,Atlas_platform_updates_legit_soft__c
                           ,Referral_scheme_updates__c
                           ,Referral_scheme_updates_legit_soft__c
                           ,Citation_Partner_Offers__c
                           ,Citation_Partner_Offers_Soft_Opt_in__c
                           ,PR_Surveys__c
                           ,PR_Surveys_legit_soft__c
                     FROM Individual WHERE Id IN :lstIndividualLst];
        for(Individual ind:lstIndividual){
            System.assertEquals(ind.News_service_updates_legit_soft__c,false,'Atlas Features Soft Opt In');
            System.assertEquals(ind.Events_webinars_legit_soft__c,false,'Citatin Partner Soft opt In Not Updated');
            System.assertEquals(ind.New_product_offer_legit_soft__c, false, 'Products and Special Offers Not Updated');
            System.assertEquals(ind.Atlas_platform_updates_legit_soft__c,false,'Atlas platform Soft Opt In');
            System.assertEquals(ind.Referral_scheme_updates_legit_soft__c,false,'Referal Scheme Soft opt In Not Updated');
            System.assertEquals(ind.Citation_Partner_Offers_Soft_Opt_in__c, false, 'Citation partner Soft opt In  Not Updated');
            System.assertEquals(ind.PR_Surveys_legit_soft__c, false, 'PR Surveys Soft opt In  Not Updated');
        }
        List<Individual_History__c> indHistory=new List<Individual_History__c>();
         indHistory=[SELECT Individual__c,Createdby.Name,Field_Name__c,New_Value__c,Old_Value__c FROM Individual_History__c where Individual__c IN :lstIndividual and createdById=:u.Id];
         system.assertNotEquals(0,indHistory.size());
    }
}