@isTest
public class ContactServiceTest
{
    @isTest
    private static void whenInsertOptoutEmailTrue_DoesNotUpdateIndividualSoftOptIn()
    { 
        Individual individual = new Individual(lastName = 'smith');
        TestUtility.setId(individual);

        Contact ct = new Contact(HasOptedOutOfEmail = true, lastName = 'smith', IndividualId = individual.Id);

        MockSelector selector = new MockSelector();
        selector.individualsForContacts = new List<Individual>{individual};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new ContactService(selector).processRelatedRecordsOnNew(new List<Contact>{ct});
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(individual.getSObjectType()).size());
    }

    @isTest
    private static void whenInsertOptoutEmailFalse_UpdateIndividualSoftOptIn()
    { 
        Individual individual = new Individual(lastName = 'smith');
        TestUtility.setId(individual);

        Contact ct = new Contact(HasOptedOutOfEmail = false, lastName = 'smith', IndividualId = individual.Id);

        MockSelector selector = new MockSelector();
        selector.individualsForContacts = new List<Individual>{individual};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new ContactService(selector).processRelatedRecordsOnNew(new List<Contact>{ct});
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(individual.getSObjectType()).size());
        individual = (Individual)uow.getRecords(individual.getSObjectType())[0];

        System.assertEquals(true, individual.Atlas_platform_updates_legit_soft__c);
        System.assertEquals(true, individual.Citation_Partner_Offers_Soft_Opt_in__c);
        System.assertEquals(true, individual.Events_webinars_legit_soft__c);
        System.assertEquals(true, individual.New_product_offer_legit_soft__c);
        System.assertEquals(true, individual.News_service_updates_legit_soft__c);
        System.assertEquals(true, individual.PR_Surveys_legit_soft__c);
        System.assertEquals(true, individual.Referral_scheme_updates_legit_soft__c);   
    }

    @isTest
    private static void whenUpdateOptoutEmailChangesFalse_UpdateIndividualSoftOptIn()
    { 
        Individual individual = new Individual(lastName = 'smith');
        TestUtility.setId(individual);

        Contact oldCt = new Contact(HasOptedOutOfEmail = true,lastName = 'smith', IndividualId = individual.Id);
        TestUtility.setId(oldCt);
        Contact ct = new Contact(Id = oldCt.Id, HasOptedOutOfEmail = false, lastName = 'smith', IndividualId = individual.Id);

        MockSelector selector = new MockSelector();
        selector.individualsForContacts = new List<Individual>{individual};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new ContactService(selector).processRelatedRecordsOnChange(new List<Contact>{ct}, new Map<Id, Contact>{oldCt.Id=>oldCt});
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(individual.getSObjectType()).size());
        individual = (Individual)uow.getRecords(individual.getSObjectType())[0];

        System.assertEquals(true, individual.Atlas_platform_updates_legit_soft__c);
        System.assertEquals(true, individual.Citation_Partner_Offers_Soft_Opt_in__c);
        System.assertEquals(true, individual.Events_webinars_legit_soft__c);
        System.assertEquals(true, individual.New_product_offer_legit_soft__c);
        System.assertEquals(true, individual.News_service_updates_legit_soft__c);
        System.assertEquals(true, individual.PR_Surveys_legit_soft__c);
        System.assertEquals(true, individual.Referral_scheme_updates_legit_soft__c);
    }

    @isTest
    private static void whenUpdateOptoutEmailDoesNotChange_DoesNotUpdateIndividualSoftOptIn()
    { 
        Individual individual = new Individual(lastName = 'smith');
        TestUtility.setId(individual);

        Contact oldCt = new Contact(HasOptedOutOfEmail = false,lastName = 'smith', IndividualId = individual.Id);
        TestUtility.setId(oldCt);
        Contact ct = new Contact(Id = oldCt.Id, HasOptedOutOfEmail = false, lastName = 'smith', IndividualId = individual.Id);

        MockSelector selector = new MockSelector();
        selector.individualsForContacts = new List<Individual>{individual};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        new ContactService(selector).processRelatedRecordsOnChange(new List<Contact>{ct}, new Map<Id, Contact>{oldCt.Id=>oldCt});
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(individual.getSObjectType()).size());
    }

    @isTest
    private static void whenInserted_SetsContactActive()
    {
        List<Contact> contacts = new List<Contact>{
            new Contact(lastName = 'Smith'),
            new Contact(lastName = 'Jones')
        };

        Test.startTest();
        new ContactService(new MockSelector()).setDefaults(contacts);
        Test.stopTest();

        System.assertEquals(true, contacts[0].Active__c);
        System.assertEquals(true, contacts[1].Active__c);
    }
	
    @isTest
    private static void whenInserted_SetContactOpenCore()
    {
        List<Account> actsList = new List<Account>{
            new Account(Name = 'Fred', Open_Core_Opportunities__c=true),
            new Account(Name = 'Mary', Open_Core_Opportunities__c=false)
        };
        TestUtility.setIDs(actsList);
        
        List<Contact> contacts = new List<Contact>{
            new Contact(lastName = 'Smith', AccountId=actsList[0].Id),
            new Contact(lastName = 'Jones', AccountId=actsList[1].Id)
        };
		
        MockSelector selector = new MockSelector();
        selector.accountInfoForContacts = new Map<Id,Account>(actsList);
            
        Test.startTest();
        new ContactService(selector).setDefaults(contacts);
        Test.stopTest();

        System.assertEquals('True', contacts[0].Open_Core_Opportunities__c);
        System.assertEquals('False', contacts[1].Open_Core_Opportunities__c);
    }
    
    @isTest
    private static void whenContactInsertWithIncorrectAccountId_VerifyContactOpenCoreValueNull()
    {
        List<Account> actsList = new List<Account>{
            new Account(Name = 'Fred', Open_Core_Opportunities__c=true)
        };
        TestUtility.setIDs(actsList);
        
        List<Contact> contacts = new List<Contact>{
            new Contact(lastName = 'Smith', AccountId = '001D000001rqh70IAA')
        };
		
        MockSelector selector = new MockSelector();
        selector.accountInfoForContacts = new Map<Id,Account>(actsList);
            
        Test.startTest();
        new ContactService(selector).setDefaults(contacts);
        Test.stopTest();

        System.assertEquals(Null, contacts[0].Open_Core_Opportunities__c);
    }
    
    @isTest
    private static void whenRelatedContact_DifferentOptOut_relatedContactUpdated()
    {
        Contact oldContact = new Contact(IndividualId = TestUtility.getFakeId(Individual.SObjectType), 
                                        HasOptedOutOfEmail = true);
        TestUtility.setID(oldContact);

        Contact newContact = new Contact(Id = oldContact.Id, 
                                            IndividualId = oldContact.IndividualId, 
                                            HasOptedOutOfEmail = true);

        Contact relatedContact = new Contact(Id = oldContact.Id, 
                                            IndividualId =oldContact.IndividualId, 
                                            HasOptedOutOfEmail = false);
        TestUtility.setID(relatedContact);

        MockSelector selector = new MockSelector();
        selector.relatedIndividualContacts = new List<Contact>{relatedContact};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        List<Contact> newList = new List<Contact>{newContact};
        Map<Id, Contact> oldMap = new Map<Id, Contact>{oldContact.Id => oldContact};

        new ContactService(selector).processRelatedRecordsOnChange(newList, oldMap);
        Test.stopTest();

        System.assertEquals(1, uow.getRecords(Contact.SObjectType).size());
        System.assertEquals(relatedContact.Id, uow.getRecords(Contact.SObjectType).get(0).Id);
    }

    @isTest
    private static void whenRelatedContact_SameOptOut_relatedContactNotUpdated()
    {
        Contact oldContact = new Contact(IndividualId = TestUtility.getFakeId(Individual.SObjectType), 
                                        HasOptedOutOfEmail = true);
        TestUtility.setID(oldContact);

        Contact newContact = new Contact(Id = oldContact.Id, 
                                            IndividualId = oldContact.IndividualId, 
                                            HasOptedOutOfEmail = true);

        Contact relatedContact = new Contact(Id = oldContact.Id, 
                                            IndividualId =oldContact.IndividualId, 
                                            HasOptedOutOfEmail = true);
        TestUtility.setID(relatedContact);

        MockSelector selector = new MockSelector();
        selector.relatedIndividualContacts = new List<Contact>{relatedContact};

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        List<Contact> newList = new List<Contact>{newContact};
        Map<Id, Contact> oldMap = new Map<Id, Contact>{oldContact.Id => oldContact};

        new ContactService(selector).processRelatedRecordsOnChange(newList, oldMap);
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Contact.SObjectType).size());
    }

    @isTest
    private static void sourceContactNotUpdated()
    {
        Contact oldContact = new Contact(IndividualId = TestUtility.getFakeId(Individual.SObjectType), 
                                        HasOptedOutOfEmail = true);
        TestUtility.setID(oldContact);

        Contact newContact = new Contact(Id = oldContact.Id, 
                                            IndividualId = oldContact.IndividualId, 
                                            HasOptedOutOfEmail = true);

        MockUOW uow = new MockUOW();
        UnitOfWork.setInstance(uow);

        Test.startTest();
        List<Contact> newList = new List<Contact>{newContact};
        Map<Id, Contact> oldMap = new Map<Id, Contact>{oldContact.Id => oldContact};

        new ContactService(new MockSelector()).processRelatedRecordsOnChange(newList, oldMap);
        Test.stopTest();

        System.assertEquals(0, uow.getRecords(Contact.SObjectType).size());
    }

    @isTest
    private static void selector_returnsRelatedContacts()
    {        
        List<Individual> individuals = new List<Individual>{
            new Individual(LastName='smith'),
            new Individual(LastName='jones'),
            new Individual(LastName='macdonald')
        };
        insert individuals;

        List<Contact> contacts = new List<Contact>{
            new Contact(firstName = 'bob', lastName = 'smith', IndividualId = individuals[0].Id),
            new Contact(firstName = 'robert', lastName = 'smith', IndividualId = individuals[0].Id),
            new Contact(firstName = 'bobby', lastName = 'smith', IndividualId = individuals[0].Id),
            new Contact(firstName = 'sam', lastName = 'jones', IndividualId = individuals[1].Id),
            new Contact(firstName = 'sammy', lastName = 'jones', IndividualId = individuals[1].Id),
            new Contact(firstName = 'Mary', lastName = 'macdonald', IndividualId = individuals[2].Id)
        };
        insert contacts;

        List<Contact> querySource = new List<Contact>{
            contacts[0],
            contacts[3],
            contacts[5]
        };

        List<Contact> response = new ContactService.DefaultSelector().getRelatedContactsByIndividual(querySource);

        System.assertEquals(3, response.size());  // 2 related to smith, and 1 related to jones

        Map<Id, Contact> contactMap = new Map<Id, Contact>(response);
        System.assert(contactMap.containsKey(contacts[1].ID));
        System.assert(contactMap.containsKey(contacts[2].ID));
        System.assert(contactMap.containsKey(contacts[4].ID));
    }
	@isTest
    private static void selector_returnsAccountInfo()
    {        
        Account act  = new Account(name='test',Open_Core_Opportunities__c = true) ;
        insert act;
        
        List<Contact> contacts = new List<Contact>{
            new Contact(firstName = 'bob', lastName = 'smith', AccountId = act.Id),
            new Contact(firstName = 'robert', lastName = 'smith', AccountId = act.Id)
        };
        insert contacts;
        
        Map<Id,Account> response = new ContactService.DefaultSelector().getAccountInfo(contacts);

        System.assertEquals(1, response.size());
    }
    class MockSelector implements ContactService.ISelector
    {
        List<Contact> relatedIndividualContacts = new List<Contact>();
        List<Individual> individualsForContacts = new List<Individual>();
        Map<Id,Account> accountInfoForContacts = new Map<Id,Account>();
            
        public List<Contact> getRelatedContactsByIndividual(List<Contact> sourceContacts)
        {
            return relatedIndividualContacts;
        }

        public List<Individual> getIndividualsForContacts(List<Contact> contacts)
        {
            return individualsForContacts;
        }
        
        public Map<Id,Account> getAccountInfo(List<Contact> contactList){
            return accountInfoForContacts;
        }
    }
}