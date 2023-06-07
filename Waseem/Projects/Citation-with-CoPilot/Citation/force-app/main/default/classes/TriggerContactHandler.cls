public without sharing class TriggerContactHandler
{
    private static TriggerContactHandler instance;
    public static TriggerContactHandler getInstance() {
        if (instance == null) {
            instance = new TriggerContactHandler();
        }
        return instance;
    }

    public void onAfterInsert(final List<Contact> newObjects)
    {
        List<Contact> contactsWOLeadConvert=new List<Contact>();
        for(Contact c: newObjects)
        {
            if(c.IndividualId != null)
            {
                if(!c.isConverted__c)
                {
                    contactsWOLeadConvert.add(c);
                }
            }
        }
        if(!contactsWOLeadConvert.isEmpty())
        {
            setDefaultClientPreferences(contactsWOLeadConvert);
        }
    }

    public void onAfterUpdate(final List<Contact> newObjects, final Map<Id, Contact> oldObjectsMap)
    {
        List<Contact> contactsToProcess=new List<Contact>();

        for(Contact c: newObjects)
        {
            if(c.HasOptedOutOfEmail && c.HasOptedOutOfEmail != oldObjectsMap.get(c.Id).HasOptedOutOfEmail)
            {
                contactsToProcess.add(c);
            }
        }
        if(!contactsToProcess.isEmpty()){
            setClientPreferencesOnEmailOptOut(contactsToProcess);
        }
    }

    /**
    * @description this method unchecks the client specific consent and soft-optins preferences 
    * on individual record , when email opt out is checked on contact .
    */
    private void setClientPreferencesOnEmailOptOut(List<Contact> clientsToProcess) {
        Set<Id> individualIds=new Set<Id>();
        for(Contact c:clientsToProcess){
            if(c.IndividualId!=null){
                individualIds.add(c.IndividualId);
            }
        }
        List<Individual> lstIndividual=new List<Individual>();
        lstIndividual=[Select News_service_updates_legit_soft__c
                            , Events_webinars_legit_soft__c
                            , New_product_offer_legit_soft__c
                            , Atlas_platform_updates_legit_soft__c
                            , Referral_scheme_updates_legit_soft__c
                            , Citation_Partner_Offers_Soft_Opt_in__c
                            , PR_Surveys_legit_soft__c
                            , News_service_updates__c
                            , Eventswebinars__c
                            , Special_Offers__c
                            , Atlas_platform_updates__c
                            , Referral_scheme_updates__c
                            , Citation_Partner_Offers__c
                            , PR_Surveys__c
                            From Individual WHERE Id IN :individualIds];
        for(Individual ind1:lstIndividual){
          ind1.News_service_updates__c=false;
          ind1.News_service_updates_legit_soft__c=false;
          ind1.Eventswebinars__c=false;
          ind1.Events_webinars_legit_soft__c=false;
          ind1.Special_Offers__c=false;
          ind1.New_product_offer_legit_soft__c=false;
          ind1.Atlas_platform_updates__c=false;
          ind1.Atlas_platform_updates_legit_soft__c=false;
          ind1.Referral_scheme_updates__c=false;
          ind1.Referral_scheme_updates_legit_soft__c=false;
          ind1.PR_Surveys__c=false;
          ind1.PR_Surveys_legit_soft__c=false;
          ind1.Citation_Partner_Offers__c=false;
          ind1.Citation_Partner_Offers_Soft_Opt_in__c=false;
          
       }
        if(!lstIndividual.isEmpty()){
            update lstIndividual;
        }
    }

    /**
    * @description this method sets the default soft-opt ins on Individual record. 
    */
    private void setDefaultClientPreferences(List<Contact> contactsWOLeadConvert)
    {
        Set<Id> individualIds=new Set<Id>();
        for(Contact c:contactsWOLeadConvert)
        {
            if(c.IndividualId != null && !c.HasOptedOutOfEmail)
            {
                individualIds.add(c.IndividualId);
            }
        }

        List<Individual> lstIndividual=new List<Individual>();
        lstIndividual=[SELECT   Id,News_service_updates_legit_soft__c,
                                Events_webinars_legit_soft__c,
                                New_product_offer_legit_soft__c,
                                Atlas_platform_updates_legit_soft__c,
                                Referral_scheme_updates_legit_soft__c,
                                Citation_Partner_Offers_Soft_Opt_in__c,
                                PR_Surveys_legit_soft__c
                             FROM Individual WHERE Id IN :individualIds];
                             
        for(Individual ind:lstIndividual){
            ind.News_service_updates_legit_soft__c=true;
            ind.Events_webinars_legit_soft__c=true;
            ind.New_product_offer_legit_soft__c=true;
            ind.Atlas_platform_updates_legit_soft__c=true;
            ind.Referral_scheme_updates_legit_soft__c=true;
            ind.Citation_Partner_Offers_Soft_Opt_in__c=true;
            ind.PR_Surveys_legit_soft__c=true;

        }
        if(!lstIndividual.isEmpty()){
            update lstIndividual;
        }
    }
}