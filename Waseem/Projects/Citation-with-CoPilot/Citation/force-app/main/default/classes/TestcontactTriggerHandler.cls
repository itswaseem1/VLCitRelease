@isTest
public class TestcontactTriggerHandler{

 public static testmethod void testdata(){
    List<Account> accounts = new List<Account>();
        List<Individual> idlList = new List<Individual>();
       List<Contact> contactsList = new List<Contact>();
      
        Account acc = new Account();
        acc.Name='Test';
        acc.Shorthorn_Id__c =12345;
        acc.FM_Contact_External_Id__c='33232';
        insert acc;
        
        contact con = new contact();
        con.LastName='test11';
        con.FirstName='dd';
        con.email='test222@gmail.com';
        con.AccountId= acc.Id;
        insert con;
        Map<Id,contact> contMap = new Map<Id,contact>();
        con.Email='Test16ghouse@gmail.com';
        
        contMap.put(con.Id,con);
        update contMap.values();
       for (Integer i=0;i<=200;i++) {
            idlList.add(new Individual(LastName='last',FirstName='first',Email__c ='Test16ghouse@gmail.com',Group_Company_Name__c ='Citation'));
        }
        insert idlList;
      system.assert(idlList != null ,'Indiviudal record inserted successfully');       
      con.individualId= idlList[0].Id;
      update con;
      idlList[0].Email__c =con.Email;
      update idlList[0];
      con=[SELECT HasOptedOutOfEmail,Id from Contact WHERE Id=:con.Id];
      con.HasOptedOutOfEmail=true;
      update con;
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
                                    FROM Individual WHERE Id IN :idlList];
      for(Individual ind:lstIndividual){
         System.assertEquals(ind.News_service_updates_legit_soft__c,false,'New service updates Not Updated');
         System.assertEquals(ind.Events_webinars_legit_soft__c,false,'Events And Webinars Not Updated');
         System.assertEquals(ind.Atlas_platform_updates_legit_soft__c, false, 'Atlas Platform Updates Not Updated');
         System.assertEquals(ind.New_product_offer_legit_soft__c,false,'New products and offers Not Updated');
         System.assertEquals(ind.Referral_scheme_updates_legit_soft__c,false,'Referral scheme updates Not Updated');
         System.assertEquals(ind.Citation_Partner_Offers_Soft_Opt_in__c, false, 'Citation Partner offers Not Updated');
         System.assertEquals(ind.PR_Surveys_legit_soft__c,false,'PR Survey Not Updated');
      }
   }
}