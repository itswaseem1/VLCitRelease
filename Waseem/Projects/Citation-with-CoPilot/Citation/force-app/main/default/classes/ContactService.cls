public inherited sharing class ContactService extends DefaultService
{
    /*
    *   This implementation of the service will require a selector to handle loading
    *   records that it will need to perform its job.
    */
    public interface ISelector
    {
        /*
        *   Load optout status of contacts related to the provided ones, where they
        *   are related by a common individual ID.
        *   Does not return the sourceContacts
        */
        List<Contact> getRelatedContactsByIndividual(List<Contact> sourceContacts);

        /*
        *   Get the individuals for the given contacts.
        */
        List<Individual> getIndividualsForContacts(List<Contact> contacts);
        /*
        *   Get the associated Account Data for Contacts 
        */
        Map<Id,Account> getAccountInfo(List<Contact> contactList);
    }

    /*
    *   Our selector that we were provided by what ever created us.
    */
    private ISelector selector;

    public ContactService(ISelector selector) 
    {
        this.selector = selector;
    }

    /*
    *   see IDomainService
    */
    public override void setDefaults(List<SObject> newRecords)
    {
        List<Contact> newContacts = (List<Contact>)newRecords;
        setActive(newContacts);
        setOpenCoreOpp(newContacts);
    }

    /*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnNew(List<SObject> newRecords)
    {
        super.processRelatedRecordsOnNew(newRecords);

        List<Contact> newContacts = (List<Contact>)newRecords;

        optInToMarketing(newContacts, null);
    }

    /*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        super.processRelatedRecordsOnChange(newRecords, oldRecords);

        List<Contact> newContacts = (List<Contact>)newRecords;
        Map<Id, Contact> oldContacts = (Map<Id, Contact>)oldRecords;
        updateGDPRValuesOnIndividuals(newContacts);
        optInToMarketing(newContacts, oldContacts);
    }
	
    private void setActive(List<Contact> newContacts)
    {
        new ActivateContacts(newContacts).process();
    }
    
    private void updateGDPRValuesOnIndividuals(List<Contact> newContacts)
    {
        new GDPRHandler(newContacts, selector).process();
    }

    private void optInToMarketing(List<Contact> newContacts, Map<Id, Contact> oldContacts)
    {
        new OptInToMarketing(newContacts, oldContacts, selector).process();
    }
	
    private void setOpenCoreOpp(List<Contact> newContacts)
    {
        new OpenCoreOppFromAccount(newContacts, selector).process();
    }
    /*
    *   Our default selector.
    */
    public class DefaultSelector implements ISelector
    {
        public List<Contact> getRelatedContactsByIndividual(List<Contact> sourceContacts)
        {
            // can't use an inner select as both against same field!
            Set<Id> individualIDs = new Set<Id>();
            for(Contact ct: sourceContacts)
            {
                individualIDs.add(ct.IndividualId);
            }
            individualIDs.remove(null);

            if(individualIDs.isEmpty())
                return new List<Contact>();

            return [SELECT IndividualId, HasOptedOutOfEmail 
                        FROM Contact 
                        WHERE IndividualId IN :individualIDs
                            AND Id NOT IN :sourceContacts];
        }

        public List<Individual> getIndividualsForContacts(List<Contact> contacts)
        {
            Set<ID> ids = new Set<ID>();
            for(Contact ct:  contacts)
            {
                ids.add(ct.IndividualId);
            }
            ids.remove(null);

            if(ids.isEmpty())
                return new List<Individual>();

            return [SELECT News_service_updates__c, 
                            Eventswebinars__c, 
                            Special_Offers__c, 
                            Atlas_platform_updates__c, 
                            Referral_scheme_updates__c, 
                            PR_Surveys__c,
                            Atlas_platform_updates_legit_soft__c,
                            Citation_Partner_Offers_Soft_Opt_in__c,
                            Events_webinars_legit_soft__c,
                            New_product_offer_legit_soft__c,
                            News_service_updates_legit_soft__c,
                            PR_Surveys_legit_soft__c,
                            Referral_scheme_updates_legit_soft__c
                    FROM Individual 
                    WHERE ID IN :Ids];
        }
        
        public Map<Id,Account> getAccountInfo(List<Contact> contactList){
            Set<Id> accIdSet = new Set<Id>();
            for(Contact objCon:  contactList)
            {
                if(objCon.AccountId!=null){
                    accIdSet.add(objCon.AccountId);
                }
            }
            if(!accIdSet.isEmpty()){
                return new Map<Id,Account>([Select Id,Open_Core_Opportunities__c FROM Account Where Id=:accIdSet]);
            }
            return new Map<Id,Account>();
        }
    }

    /*
    *   This updates contacts that are related to the same individual as the ones
    *   handed to this instance.
    */
    class GDPRHandler
    {
        private List<Contact> updatedRecords;
        private ISelector selector;

        GDPRHandler(List<Contact> updatedRecords, ISelector selector)
        {
            this.updatedRecords = updatedRecords;
            this.selector = selector;
        }

        void process()
        {
            Map<Id, Boolean> optOutByIndividual = new Map<Id,Boolean>();

            for(Contact ct: updatedRecords)
            {
                optOutByIndividual.put(ct.IndividualId, ct.HasOptedOutOfEmail);
            }

            List<Contact> relatedContacts = selector.getRelatedContactsByIndividual(updatedRecords);

            List<Contact> updatedContacts = new List<Contact>();
            for(Contact ct: relatedContacts)
            {
                Boolean value = optOutByIndividual.get(ct.IndividualId);
                if(ct.HasOptedOutOfEmail != value)
                {
                    ct.HasOptedOutOfEmail = value;
                    updatedContacts.add(ct);
                }
            }

            if(!updatedContacts.isEmpty()){
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.updateRecords(updatedContacts);
            }
        }
    }
	
    class ActivateContacts
    {
        private List<Contact> newContacts;

        ActivateContacts(List<Contact> newContacts)
        {
            this.newContacts = newContacts;
        }

        void process()
        {
            for(Contact ct: newContacts)
            {
                ct.Active__c = true;
            }
        }
    }
    
    class OptInToMarketing
    {
        private List<Contact> newContactsToAction;
        private ISelector selector;

        OptInToMarketing(List<Contact> newContacts, Map<Id, Contact> oldContacts, ISelector selector)
        {
            this.selector = selector;
            this.newContactsToAction = getChangedContacts(newContacts, oldContacts);
        }

        private List<Contact> getChangedContacts(List<Contact> newContacts, Map<Id, Contact> oldContacts)
        {
            List<Contact> contactsToAction = new List<Contact>();

            for(Contact newContact: newContacts)
            {
                if(newContact.HasOptedOutOfEmail == true || newContact.IndividualId == null)
                {
                    continue;
                }
                
                if(oldContacts == null)
                {
                    contactsToAction.add(newContact);
                    continue;
                }

                Contact oldContact = oldContacts.get(newContact.ID);
                if(oldContact == null)
                {
                    contactsToAction.add(newContact);
                }
                else if(newContact.HasOptedOutOfEmail != oldContact.HasOptedOutOfEmail)
                {
                    contactsToAction.add(newContact);
                }
            }

            return contactsToAction;
        }

        void process()
        {
            List<Individual> individuals = selector.getIndividualsForContacts(newContactsToAction);
            Map<Id, Individual> individualMap = new Map<Id, Individual>(individuals);

            List<Individual> individualsToUpdate = new List<Individual>();
            for(Contact ct: newContactsToAction)
            {
                Individual individual = individualMap.get(ct.IndividualId);
                if(individual == null)
                    continue;

                if(subscribed(individual)  || isAlreadyFullySoftOpted(individual))
                {
                    // we don't update soft opt in if they are hard opt in.
                    // we don't bother updating if nothing to change.
                    continue; 
                }   

                individual.Atlas_platform_updates_legit_soft__c = true;
                individual.Citation_Partner_Offers_Soft_Opt_in__c = true;
                individual.Events_webinars_legit_soft__c = true;
                individual.New_product_offer_legit_soft__c = true;
                individual.News_service_updates_legit_soft__c = true;
                individual.PR_Surveys_legit_soft__c = true;
                individual.Referral_scheme_updates_legit_soft__c = true;

                individualsToUpdate.add(individual);
            }

            if(individualsToUpdate.size() > 0)
            {
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.updateRecords(individualsToUpdate);
            }
        }

        private Boolean subscribed(Individual individual)
        {
            return individual.Atlas_platform_updates__c &&
                    individual.Eventswebinars__c &&
                    individual.Special_Offers__c &&
                    individual.News_service_updates__c &&
                    individual.PR_Surveys__c &&
                    individual.Referral_scheme_updates__c;
        }

        private Boolean isAlreadyFullySoftOpted(Individual individual)
        {
            return individual.Atlas_platform_updates_legit_soft__c &&
                    individual.Citation_Partner_Offers_Soft_Opt_in__c &&
                    individual.Events_webinars_legit_soft__c &&
                    individual.New_product_offer_legit_soft__c &&
                    individual.News_service_updates_legit_soft__c &&
                    individual.PR_Surveys_legit_soft__c &&
                    individual.Referral_scheme_updates_legit_soft__c;
        }
    }
    
    class OpenCoreOppFromAccount
    {
        private List<Contact> newContacts;
        private ISelector selector;
        
        OpenCoreOppFromAccount(List<Contact> newContacts, ISelector selector)
        {
            this.newContacts = newContacts;
            this.selector = selector;
        }
        
        void process()
        {
            Map<Id, Account> accountMap = selector.getAccountInfo(newContacts);
            
            if(accountMap.isEmpty()){
                return;
            }
            
            for(Contact objCon: newContacts)
            {
                Account objAcc = accountMap.get(objCon.AccountId);
                if(objCon.AccountId != null && objAcc != null){
                    objCon.Open_Core_Opportunities__c = String.valueOf(objAcc.Open_Core_Opportunities__c).capitalize(); //To follow the existing pattern, used Capitalize
                }
            }            
        }
    }
}