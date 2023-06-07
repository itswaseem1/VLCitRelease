@isTest
private class PB_NVM_Dialler_Outcomes_Test{

    @TestSetUp
    static void setData(){
       List<Task> taskLead = TestDataFactory.generateTask_Lead('Kumar','Citation',3,true);
       User u = newUser();
       insert u;
       User curUser = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
       System.runAs(u){
            PermissionSet perset = [SELECT Id FROM PermissionSet WHERE Name='Lead_Object_Executive_Access'];
       	    insert new PermissionSetAssignment(AssigneeId=u.Id,PermissionSetId=perset.Id);
       }
    }
    
    static testMethod User newUser(){
        Profile pro = [SELECT Id FROM Profile WHERE Name='Citation Data Quality & Diary Mgmt (inc MI)' LIMIT 1];
        User u = new User(
            ProfileId       = pro.Id,
            FirstName       = 'andrew',
            LastName        = 'russell',
            Email           = 'andrewrussell@citation.co.uk',
            Username        = 'andrewrussell250319ar@citation.co.uk',
            CompanyName     = 'Citation Limited',
            Title           = 'President',
            Alias           = 'arus',
            TimeZoneSidKey  = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey    = 'en_US'
        );
        return u;
    }
    
    static testMethod void node1_AssignedBDCPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,Renewal_Date__c,OwnerId,CallbackDateTime__c FROM Task];
 		User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'Future Third Party';
                t.Renewal_Date__c = Date.today().addDays(10);
                t.OwnerId = u.Id;
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        for(Task t : taskRecs){
            System.assertEquals([SELECT Assigned_BDC__c FROM Lead LIMIT 1].Assigned_BDC__c,t.OwnerId);
            System.assertEquals([SELECT Renewal_Date__c FROM Lead LIMIT 1].Renewal_Date__c,t.Renewal_Date__c);
        }
    }

    static testMethod void node1_AssignedBDCNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,OwnerId,Renewal_Date__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'DMU';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        for(Task t : taskRecs){
            System.assertNotEquals([SELECT Assigned_BDC__c FROM Lead LIMIT 1].Assigned_BDC__c,t.OwnerId);
            System.assertNotEquals([SELECT Renewal_Date__c FROM Lead LIMIT 1].Renewal_Date__c,t.Renewal_Date__c);
        }
    }
    
    static testMethod void node2_DMUPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c          = 'Open';
                t.Suspended_Close__c = 'DMU';
                t.CallObject         = 'Example Task';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertEquals('Decision Maker Unavailable',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node2_DMUNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();   
        System.runAs(u){    
            for(Task t : taskRecs){
                t.Status__c = 'Internal Call';
                t.Suspended_Close__c = 'BDM Call';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }    
        }
        Test.stopTest();
        System.assertNotEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Decision Maker Unavailable',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
        System.assertNotEquals(true,[SELECT OutboundDMUnavailableCheck__c FROM Lead LIMIT 1].OutboundDMUnavailableCheck__c);
    }

    static testMethod void node3_GKRefusalPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status = 'Open';
                t.Suspended_Close__c = 'Gatekeeper Refusal';
                t.CallObject         = 'Example Task';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }    
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead LIMIT 1].Status);
        System.assertEquals('Gatekeeper Refusal',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node3_GKRefusalNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'DMU';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Gatekeeper Refusal',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
        System.assertNotEquals(true,[SELECT OutboundGKCheck__c FROM Lead LIMIT 1].OutboundGKCheck__c);
    }

    static testMethod void node4_NoAnswerPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'No Answer';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertEquals('No Answer',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node4_NoAnswerNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'Answer Machine';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('No Answer',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
        System.assertNotEquals(true,[SELECT OutboundNoAnswerCheck__c FROM Lead LIMIT 1].OutboundNoAnswerCheck__c);
    }

    static testMethod void node5_AnswerMachinePositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'Answer Machine';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertEquals('Answer Machine',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node5_AnswerMachineNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'No Answer';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Answer Machine',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
        System.assertNotEquals(true,[SELECT OutboundAnswerMachineCallCheck__c FROM Lead LIMIT 1].OutboundAnswerMachineCallCheck__c);
    }

    static testMethod void node6_BusyPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        Lead leadRec        = [SELECT Id,Status,Suspended_Closed_Reason__c FROM Lead];
        User u = [SELECT Id FROM User LIMIT 1];
        List<Task> taskList = new List<Task>();
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'Busy';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertEquals('Busy',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node6_BusyNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'Answer Machine';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Busy',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
        System.assertNotEquals(true,[SELECT OutboundBusyCheck__c FROM Lead LIMIT 1].OutboundBusyCheck__c);
    }

    static testMethod void node7_DisconnectPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'Disconnect';
                t.CallObject = 'Example Task';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertEquals('Disconnect',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node7_DisconnectNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Open';
                t.Suspended_Close__c = 'DMU';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Open',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Disconnect',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
        System.assertNotEquals(true,[SELECT OutboundDisconnectCallCheck__c FROM Lead LIMIT 1].OutboundDisconnectCallCheck__c);
    }

    static testMethod void node8_CallbackPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Callback Requested';
                t.Suspended_Close__c = 'DM Callback';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Callback Requested',[SELECT Status FROM Lead].Status);
        System.assertEquals('DM Callback',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node8_CallbackNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Callback Requested';
                t.Suspended_Close__c = 'Returned Callback';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Callback Requested',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('DM Callback',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node9_AppointmentPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        System.debug('taskRecs:::'+taskRecs);
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Appointment';
                t.Suspended_Close__c = 'Inbound';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        System.debug('Update taskRecs:::'+taskRecs);
        Test.stopTest();
        Lead l = [SELECT Status,Suspended_Closed_Reason__c FROM Lead];
        System.debug('Lead Record:::'+l);
        System.assertEquals('Appointment',[SELECT Status FROM Lead LIMIT 1].Status);
        System.assertEquals('Inbound',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node9_AppointmentNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Callback Requested';
                t.Suspended_Close__c = 'None DM Callback';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertNotEquals('Appointment',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Inbound',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node10_UnderCriteriaPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,FullTimeEmployees__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Under Criteria';
                t.FullTimeEmployees__c = 5;
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertEquals('Under Criteria',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
        System.assertEquals(5,[SELECT FT_Employees__c FROM Lead].FT_Employees__c);
    }

    static testMethod void node10_UnderCriteriaNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'DM Refusal';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Under Criteria',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node11_OverCriteriaPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,FullTimeEmployees__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Over Criteria';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertEquals('Over Criteria',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
        System.assertEquals(299,[SELECT FT_Employees__c FROM Lead LIMIT 1].FT_Employees__c);
    }

    static testMethod void node11_OverCriteriaNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'DM Refusal';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Over Criteria',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node12_NotInterestedPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Not Interested';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertEquals('Not Interested',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node12_NotInterestedNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Bad Sector';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Not Interested',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node13_BadSectorPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Bad Sector';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertEquals('Bad Sector',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node13_BadSectorNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Bad Company';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Bad Sector',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node14_BadCompanyPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Bad Company';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertEquals('Bad Company',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);    
    }

    static testMethod void node14_BadCompanyNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Sole Trading';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Bad Company',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node15_DMRefusalPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'DM Refusal';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertEquals('DM Refusal',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node15_DMRefusalNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Sole Trading';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('DM Refusal',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node16_ThirdPartyPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Third Party Renewal';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertEquals('Third Party Renewal',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node16_ThirdPartyNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Sole Trading';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Third Party Renewal',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node17_SoleTraderPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Sole Trading';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertEquals('Sole Trader',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node17_SoleTraderNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Suspended';
                t.Suspended_Close__c = 'Third Party Renewal';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Suspended',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Sole Trader',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node18_AreaNotCoveredPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Area Not Covered';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Area Not Covered',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node18_AreaNotCoveredNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Ceased Trading';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Area Not Covered',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node19_CeasedTradingPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Ceased Trading';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Ceased Trading',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node19_CeasedTradingNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Area Not Covered';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Ceased Trading',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node20_BranchPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Branch';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Branch',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node20_BranchNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task ];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Area Not Covered';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Branch',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node21_DoNotCallPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Do Not Call';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Do Not Call',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node21_DoNotCallNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Area Not Covered';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Do Not Call',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node22_DuplicatePositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Duplicate';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Duplicate',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node22_DuplicateNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Do Not Call';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Duplicate',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node23_ClientPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Client';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Client',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node23_ClientNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Do Not Call';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Client',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node24_LocalAuthorityPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Local Authority';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Local Authority',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node24_LocalAuthorityNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Client';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Local Authority',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node25_EmployeePositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Employee';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Employee',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node25_EmployeeNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Client';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Employee',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c); 
    }

    static testMethod void node26_MemberOfPublicPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Member Of public';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertEquals('Member of the public',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node26_MemberOfPublicNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Client';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Closed',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Member Of public',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node27_InternalCallPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Internal Call';
                t.Suspended_Close__c = 'Manager Call';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Internal Call',[SELECT Status FROM Lead].Status);
        System.assertEquals('Manager Call',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node27_InternalCallNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Client';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertNotEquals('Internal Call',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Manager Call',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node28_CallBackPassedBackPositive(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Callback Requested';
                t.Suspended_Close__c = 'Returned Callback';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertEquals('Callback Requested',[SELECT Status FROM Lead].Status);
        System.assertEquals('Returned Callback',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

    static testMethod void node28_CallBackPassedBackNegative(){
        List<Task> taskRecs = [SELECT Id,Status__c,Suspended_Close__c,CallbackDateTime__c FROM Task];
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u){
            for(Task t : taskRecs){
                t.Status__c = 'Closed';
                t.Suspended_Close__c = 'Client';
                t.CallbackDateTime__c = SYSTEM.NOW().addDays(1);
            }
            if(!taskRecs.isEmpty()){
                update taskRecs;
            }
        }
        Test.stopTest();
        System.assertNotEquals('Callback Requested',[SELECT Status FROM Lead].Status);
        System.assertNotEquals('Returned Callback',[SELECT Suspended_Closed_Reason__c FROM Lead LIMIT 1].Suspended_Closed_Reason__c);
    }

}