public without sharing class LegacyContactTriggerHandler implements ITriggerHandler
{
    private boolean isIHasco()
    {
        return iHASCOUtility.userDivison == 'iHASCO';
    }

    public virtual void beforeInsert(List<SObject> newRecords)
    {
        if(isIHasco())
            return;

        List<Contact> newList = (List<Contact>)newRecords;
        new UpdateIndividuals().checktoCallUpdateIndividual(newList, null);

    }

    public virtual void afterInsert(List<SObject> newRecords)
    {
        if(isIHasco())
            return;

        List<Contact> newList = (List<Contact>)newRecords;
        TriggerContactHandler.getInstance().onAfterInsert(newList);
    }

    public virtual void beforeUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {       
        Map<Id, Contact> newMap = (Map<Id, Contact>)newRecords;
        Map<Id, Contact> oldMap = (Map<Id, Contact>)oldRecords;

        ContactAdviceDetailsHandler.updatePinSetDate(oldMap, newMap);

        if(isIHasco())
            return;

        new UpdateIndividuals().checktoCallUpdateIndividual(newMap.values(), oldMap);
        
    }

    public virtual void afterUpdate(Map<Id, SObject> newRecords, Map<ID, SObject> oldRecords)
    {
        List<Contact> newList = (List<Contact>)newRecords.values();
        Map<Id, Contact> oldMap = (Map<Id, Contact>)oldRecords;

        bg_FmInt_Contact_Helper.synchronise(newList, oldMap);

        if(isIHasco())
            return;

        TriggerContactHandler.getInstance().onAfterUpdate(newList, oldMap);
    }

    public virtual void beforeDelete(List<SObject> oldRecords)
    {
    }
    public virtual void afterDelete(List<SObject> oldRecords)
    {
    }

    public virtual void afterUnDelete(List<SObject> newRecords)
    {
    }

    public class UpdateIndividuals
    {
        public void checktoCallUpdateIndividual(List<Contact> conList, Map<Id,Contact> oldContactMap)
        {
            List<Contact> finContact = new List<Contact>();

            if(oldContactMap == null)   //insert
            {
                for(Contact ct:conList)
                {
                    if(ct.email != null && ct.accountid != null)
                    {
                        finContact.add(ct);     
                    }
                }
            }
            else    //update
            {
                for(Contact con: conList)
                {
                    Contact oldContact = oldContactMap.get(con.Id);
                    if(oldContact == null)
                        continue;
                    
                    if( (con.email!= null) && 
                        (con.FirstName != oldContact.FirstName 
                            || con.LastName != oldContact.LastName 
                            || con.email != oldContact.email))
                    {   
                        con.Individualid = null;
                        con.Copy_of_Individual__c ='';

                        finContact.add(con);
                    }
                }
            }

            if(finContact.size() > 0)
            {
                IndividualPopulation(finContact);    
            } 
        }
        
        // NB this code looks bugged as hell, but needs looking at along with a whole lot of
        // other GDPR code/flows before working out what is going on.  
        // for now just altered to remove unreachable (untestable) code and be a bit more efficient in places.
        public List<Contact> IndividualPopulation(List<Contact> conList)
        {
            List<String> lsemail = new List<String>();
            for(Contact con : conList)
            {
                if(con.Email != null && con.email != '')
                {
                    lsemail.add(con.email);
                }
            }

            List<Individual> individualsForEmails = [SELECT Id, Group_Company_Name__c, LastName, FirstName, Email__c, Name 
                                                        FROM Individual 
                                                        WHERE Email__c In: lsemail];

            Map<String, Map<String, List<individual>>> individualsByEmailAndCompany = mapIndividualsByEmailAndCompany(individualsForEmails);

            Id RecordTypeIdContact = Schema.SObjectType.Individual.getRecordTypeInfosByName().get('Default Citation Record Type').getRecordTypeId();
            Set<Individual> shorhonIndividualList = new Set<Individual>();
            Set<Contact> conListFin = new Set<Contact>();
            List<Contact> noindividual = new List<Contact>();
            
            for(Contact contact: conList)
            {
                Map<String, List<Individual>> individualsForEmail = individualsByEmailAndCompany.get(contact.email);

                if(individualsForEmail != null && individualsForEmail.containsKey('Citation'))
                {
                    List<individual> individuals = individualsForEmail.get('Citation');

                    for(Individual ind: individuals)  //makes no sense, can only be 1 individual per contact?
                    {
                        contact.individualid = ind.id;
                        contact.Copy_of_Individual__c = ind.id;

                        Individual indnew11 = ind;
                        if(contact.HasOptedOutOfEmail == true)
                        {
                            indnew11.Atlas_platform_updates_legit_soft__c = false;
                            indnew11.Citation_Partner_Offers_Soft_Opt_in__c = false;
                            indnew11.Events_webinars_legit_soft__c = false;
                            indnew11.New_product_offer_legit_soft__c = false;
                            indnew11.News_service_updates_legit_soft__c = false;
                            indnew11.PR_Surveys_legit_soft__c = false;
                            indnew11.Referral_scheme_updates_legit_soft__c = false;
                        } 
                        shorhonIndividualList.add(indnew11);
                    }
                }
                else if(contact.individualid == null)
                {
                    noindividual.add(contact);
                    String companyName = 'Citation';

                    Individual indnew1 = new Individual();
                    indnew1.LastName = contact.LastName;
                    indnew1.FirstName = contact.FirstName;
                    indnew1.Email__c = contact.Email;

                    if(contact.HasOptedOutOfEmail == false)
                    {
                        indnew1.Atlas_platform_updates_legit_soft__c = true;
                        indnew1.Citation_Partner_Offers_Soft_Opt_in__c = true;
                        indnew1.Events_webinars_legit_soft__c = true;
                        indnew1.New_product_offer_legit_soft__c = true;
                        indnew1.News_service_updates_legit_soft__c = true;
                        indnew1.PR_Surveys_legit_soft__c = true;
                        indnew1.Referral_scheme_updates_legit_soft__c = true;
                    }
                    
                    indnew1.recordtypeid = RecordTypeIdContact;
                    indnew1.Group_Company_Name__c = companyName;

                    shorhonIndividualList.add(indnew1 );
                }
                
                if(contact.individualid != null || contact.QMS_Individual__c != null)
                {
                    Individual indnew = new Individual();

                    if(contact.individualid != null)
                    {
                        indnew.id = contact.individualid;
                        indnew.email__c = contact.email;
                        shorhonIndividualList.add(indnew);
                    }
                    
                    if(contact.QMS_Individual__c != null)
                    {
                        indnew.id = contact.QMS_Individual__c;
                        indnew.email__c = contact.email;
                        shorhonIndividualList.add(indnew);
                    }
                }    
                conListFin.add(contact);
            }
            
            if(!shorhonIndividualList.isEmpty())
            {
                map<String,individual> updateInd = new map<String,individual>();
                for(individual idv:shorhonIndividualList)
                {
                    updateInd.put(idv.Email__c,idv);
                }
            
                upsert updateInd.values();
            }
        
            Map<id,map<String,Individual>> shorhonIndividualMap = new Map<id,map<String,Individual>>();
        
            for(Individual indd: shorhonIndividualList)
            {
                map<String,individual> mp = new map<String,individual>();
                mp.put(indd.email__c,indd);
                shorhonIndividualMap.put(indd.id,mp);
            }
        
            for(Contact cont: noindividual)
            {
                List<map<String,individual>> tempInd = shorhonIndividualMap.values();
                for(map<String,individual> idd: tempInd)
                {
                    if((idd.containsKey(cont.email)))
                    {
                        if(idd.get(cont.email).group_company_name__c == 'Citation')
                        {
                            cont.individualid = idd.get(cont.email).id;
                            cont.copy_of_individual__c = idd.get(cont.email).id;
                        }
                    }
                }
            }
        
            if(conListFin.size()>0)
            {
                List<Contact> lc = new List<Contact>();
                lc.addall(conListFin);
                return lc;
                
            }
            else
            {
                return null;
            }
        }

        private Map<String, Map<String, List<individual>>> mapIndividualsByEmailAndCompany(List<Individual> individuals)
        {
            Map<String, Map<String, List<individual>>> individualsByEmailAndCompany = new Map<String, Map<String, List<individual>>>();

            if(!individuals.isEmpty())
            {
                for(Individual individual: individuals)
                {
                    Map<String, List<Individual>> individualsForEmail = individualsByEmailAndCompany.get(individual.email__c);
                    if(individualsForEmail == null)
                    {
                        individualsForEmail = new Map<String, List<Individual>>();
                        individualsByEmailAndCompany.put(individual.email__c, individualsForEmail);
                    }

                    List<Individual> individualsForCompany = individualsForEmail.get(individual.group_company_name__c);
                    if(individualsForCompany == null)
                    {
                        individualsForCompany = new List<Individual>();
                        individualsForEmail.put(individual.group_company_name__c, individualsForCompany);
                    }

                    individualsForCompany.add(individual);
                }
            }

            return individualsByEmailAndCompany;
        }
    }

}