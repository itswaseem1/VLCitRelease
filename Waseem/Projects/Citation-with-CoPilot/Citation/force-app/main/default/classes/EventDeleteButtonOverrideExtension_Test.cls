@isTest
public class EventDeleteButtonOverrideExtension_Test {
	@testSetup static void setup()
	{		
        List<Account> accList = TestDataFactory.getAccounts(1,'TestAccount',true);
        
        Event e = new Event();
        e.WhatId=accList[0].id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.Type = '1st Visit';
        insert e;
        
       List<Profile> lstP = [select id, name from Profile];
        Map<String, Profile> profileMAP = new Map<String, Profile>();
        for(profile p : lstP){
            profileMAP.put(p.name, p);
        }
        List<Event_Deletion_Configuration__c> lstEDC = new List<Event_Deletion_Configuration__c>();
        lstEDC.add(new Event_Deletion_Configuration__c(
            SetupOwnerId = profileMAP.get('Citation Data Admin').Id,
            Can_delete_events__c = true)
                  );
        lstEDC.add(new Event_Deletion_Configuration__c(
            SetupOwnerId = profileMAP.get('Citation BDM').Id,
            Can_delete_events__c = false)
                  );
            insert lstEDC;
	}
    
	@isTest static void authorisedUser()
    {	
        List<Event_Deletion_Configuration__c>  EDC = [SELECT Id, SetupOwner.name, Can_delete_events__c FROM Event_Deletion_Configuration__c where Can_delete_events__c = TRUE LIMIT 1];
        if(EDC.size() != 0){
            User usr = TestDataFactory.createUser_Generic('Citation Data Admin', '',true);
            system.runAs(usr){
                Event evnt = [SELECT whatId FROM EVENT where what.type = 'Account'];
                Test.startTest();
                EventDeleteButtonOverrideExtension qbe = new EventDeleteButtonOverrideExtension(new ApexPages.StandardController(evnt));
                qbe.handleDeletionRequest();
                Test.stopTest();
                System.assertEquals(0, [SELECT count() from Event WHERE Id = :evnt.Id ]);
            }
        }
        	
    }
    
    @isTest static void unAuthorisedUser()
    {
        List<Event_Deletion_Configuration__c> EDC = [SELECT Id, SetupOwner.name, Can_delete_events__c FROM Event_Deletion_Configuration__c where Can_delete_events__c = false LIMIT 1];
        if(EDC.size() != 0){
            User usr = TestDataFactory.createUser_Generic('Citation BDM', '',true);
            system.runAs(usr){
                Event evnt = [SELECT whatId FROM EVENT where what.type = 'Account'];
                Test.startTest();
                EventDeleteButtonOverrideExtension qbe = new EventDeleteButtonOverrideExtension(new ApexPages.StandardController(evnt));
                qbe.handleDeletionRequest();
                Test.stopTest();
                System.assertEquals(1, [SELECT count() from Failed_Event_Deletion__c WHERE Event_Id__c = :evnt.Id ]);
            }
        }
    }
    
    
    
}