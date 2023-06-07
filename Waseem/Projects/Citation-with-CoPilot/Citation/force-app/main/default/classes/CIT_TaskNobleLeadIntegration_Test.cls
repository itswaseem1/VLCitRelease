@isTest
private class CIT_TaskNobleLeadIntegration_Test {
    private static testmethod void validateCIT_TaskNobleLeadIntegration() {
        
        // Profile platformUser2 = [select id, description, name, usertype from Profile where Name = 'Citation Contact Centre BDC'];
        // User platformRoleUser2 = [select id, UserRoleId from User where UserRoleId = '00ED00000014CxD' limit 1];
        // system.debug(platformUser2);
        // system.debug(platformRoleUser2);
                
        // User testUser2 = CIT_PH1_Trigger_Utils.createTestUser('BDCtest', 'BDCUser', 'BDCtestUser2@citationtest.co.uk', 'BDCtestUser2@citationtest.co.uk', platformUser2.Id, platformRoleUser2.UserRoleId);

        // insert testUser2;
        // testUser2 = [SELECT
        //     Id, FirstName, LastName, Email, Username, ProfileId, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey,
        //     LanguageLocaleKey
        // FROM User WHERE Email = 'BDCtestUser2@citationtest.co.uk' limit 1];    

        // String ContId = testUser2.Id;
        // String Cont15Digit = ContId .substring(0, 15);    
    
        // Profile platformUser = [select id, description, name, usertype from Profile where Name = 'Citation BDM'];
        // User platformRoleUser = [select id, UserRoleId from User where UserRoleId = '00ED00000015Q6J' limit 1];
        // system.debug(platformUser);
        // system.debug(platformRoleUser);
                
        // User testUser = CIT_PH1_Trigger_Utils.createTestUser('test', 'User', 'testUser@citationtest.co.uk', 'testUser@citationtest.co.uk', platformUser.Id, platformRoleUser.UserRoleId);

        // insert testUser;
        // testUser = [SELECT
        //     Id, FirstName, LastName, Email, Username, ProfileId, UserRoleId, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey,
        //     LanguageLocaleKey
        // FROM User WHERE Email = 'testUser@citationtest.co.uk' limit 1];

        User testUser2 = bg_User_TestUtils.createCitationContactCentreBDCUser('testuser2');
        insert testuser2;
        User testUser = bg_User_TestUtils.createCitationContactCentreBDCUser('testuser1');
        insert testuser;
        
        Lead testLead = new Lead(LastName = 'Lead', FirstName = 'test', Company = 'testCompany', Email = 'testLead@testCompany.co.uk', Callback_Date_Time__c = date.today(), RecordTypeID = '012D0000000NbJs' );
        System.runAs ( testUser ) {
        insert testLead;
        testLead = [SELECT Id, LastName, FirstName, Company, Email, bdc__c, Callback_Date_Time__c, RecordTypeID  FROM Lead WHERE Email = 'testLead@testCompany.co.uk'];
        }
/*
        Task testTask10 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = 'Callback Scheduled - DMC Callback',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST10'    
        ); */
        
        List<Task> taskList = CIT_PH1_Trigger_Utils.createNobleTaskTestData(10, 10, testLead, testUser);
 //       taskList.Add(testTask10);
        
        Task testTask1 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = 'Callback Scheduled - DMC Callback',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST1' 
        );
        
        Task testTask2 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = 'Callback Scheduled - NON DMC Callback',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST2' 
        );
/*        
        Task testTask3 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = 'Open - Decision Maker Unav',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST3' 
        );
        
        Task testTask4 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = 'Closed - Bad Sector',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Note:' +
                            'THIS IS TEST4' 
        ); 
        
        Task testTask5 = new Task(
            Subject = 'Outbound Cal', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = 'Callback Scheduled - DMC Callback',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST5' 
        );
        
        Task testTask6 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = 'Callback Schedule - DMC Callback',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST6' 
        );
        
        Task testTask7 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = '',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST7' 
        );
        
        Task testTask8 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = null,
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST8' 
        );
        
        Task testTask9 = new Task(
            Subject = '     Outbound Call   ', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = '      Callback Scheduled - NON DMC Callback ',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST9' 
        );
        
        Task testTask11 = new Task(
            Subject = '     Outbound Call   ', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = '     No Answer  ',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST11'    
        );
        
        Task testTask12 = new Task(
            Subject = 'Outbound Call', 
            WhoId = testLead.Id,
            OwnerId = testUser.Id,
            CallDisposition = 'Member of the public',
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = date.today(),
            Description = 'Callback call to 44-(133)2374527 at 11:45:59 AM on 7/25/2014.\n Disposition: Callback Scheduled - DMC Callback \n Agent Notes:' +
                            'THIS IS TEST12'    
        ); */

        system.runAs(testUser) {

            insert testTask1;
            Lead updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, Callback_Date_Time__c, RecordTypeID   FROM Lead WHERE Id = :testLead.Id];
            system.assertEquals(testUser.Id, updatedLead.BDC__c);
            system.assertEquals('Callback Requested', updatedLead.Status);
            system.assertEquals(date.today(), updatedLead.Callback_Date_Time__c);
            system.assertEquals('DM Callback', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            
            insert testTask2;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, Callback_Date_Time__c, RecordTypeID  FROM Lead WHERE Id = :testLead.Id];
            system.assertEquals(testUser.Id, updatedLead.BDC__c);
            system.assertEquals('Callback Requested', updatedLead.Status);
            system.assertEquals(date.today(), updatedLead.Callback_Date_Time__c);            
            //system.assertEquals('Non DM Callback', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            //system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            
 /*           insert testTask3;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, RecordTypeID FROM Lead WHERE Id = :testLead.Id];
            system.assertNOTEquals(null, updatedLead.BDC__c);
            system.assertEquals('Open', updatedLead.Status);
            system.assertEquals('Decision Maker Unavailable', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3'));  
            
            insert testTask4;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, RecordTypeID FROM Lead WHERE Id = :testLead.Id];
            system.assertNotEquals(null, updatedLead.BDC__c);
            system.assertEquals('Suspended', updatedLead.Status);
            system.assertEquals('Bad Sector', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            
            insert testTask5;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, RecordTypeID FROM Lead WHERE Id = :testLead.Id];
            system.assertNotEquals(null, updatedLead.BDC__c);
            system.assertEquals('Suspended', updatedLead.Status);
            system.assertEquals('Bad Sector', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST5'));
            
            insert testTask6;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, RecordTypeID FROM Lead WHERE Id = :testLead.Id];
            system.assertNotEquals(null, updatedLead.BDC__c);
            system.assertEquals('Suspended', updatedLead.Status);
            system.assertEquals('Bad Sector', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST5'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST6'));
            
            insert testTask7;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, RecordTypeID FROM Lead WHERE Id = :testLead.Id];
            system.assertNotEquals(null, updatedLead.BDC__c);
            system.assertEquals('Suspended', updatedLead.Status);
            system.assertEquals('Bad Sector', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST5'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST6'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST7'));
            
            insert testTask8;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, RecordTypeID FROM Lead WHERE Id = :testLead.Id];
            system.assertNotEquals(null, updatedLead.BDC__c);
            system.assertEquals('Suspended', updatedLead.Status);
            system.assertEquals('Bad Sector', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST5'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST6'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST7'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST8'));
            
            insert testTask9;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, Callback_Date_Time__c, RecordTypeID  FROM Lead WHERE Id = :testLead.Id];
            system.assertEquals(testUser.Id, updatedLead.BDC__c);
            system.assertEquals('Callback Requested', updatedLead.Status);
            system.assertEquals(date.today(), updatedLead.Callback_Date_Time__c);
            system.assertEquals('Non DM Callback', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST5'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST6'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST7'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST8'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST9'));
            
            insert taskList;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, Callback_Date_Time__c, RecordTypeID  FROM Lead WHERE Id = :testLead.Id];
            system.assertEquals(testUser.Id, updatedLead.BDC__c);
            system.assertEquals('Callback Requested', updatedLead.Status);
            system.assertEquals(date.today(), updatedLead.Callback_Date_Time__c);
            system.assertEquals('DM Callback', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST5'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST6'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST7'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST8'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST9'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST10'));
            
            insert testTask11;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, RecordTypeID FROM Lead WHERE Id = :testLead.Id];
            system.assertNotEquals(null, updatedLead.BDC__c);
            system.assertEquals('Open', updatedLead.Status);
            system.assertEquals('No Answer', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST5'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST6'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST7'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST8'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST9'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST10'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST11'));
        
            insert testTask12;
            updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c, RecordTypeID FROM Lead WHERE Id = :testLead.Id];
            system.assertNotEquals(null, updatedLead.BDC__c);
            system.assertEquals('Closed', updatedLead.Status);
            system.assertEquals('Member of the public', updatedLead.Suspended_Closed_Reason__c);
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST1')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST2')); 
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST3')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST4')); 
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST5'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST6'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST7'));
            system.assert(!updatedLead.Notes__c.contains('THIS IS TEST8'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST9'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST10'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST11'));
            system.assert(updatedLead.Notes__c.contains('THIS IS TEST12'));
*/        }
        
        
        testTask1 = [SELECT
            Id,             
            Subject, 
            WhoId,
            OwnerId,
            CallDisposition,
            Status,
            Priority,
            Description,
            CreatedById,
            LastModifiedById FROM Task WHERE Subject = 'Outbound Call' limit 1];
        
        Lead updatedLead = [SELECT Id, BDC__c, Notes__c, Status, Suspended_Closed_Reason__c FROM Lead WHERE Id = :testLead.Id];
        
        system.debug(testLead);
        system.debug(testUser);
        system.debug(testTask1);
        system.debug(updatedLead); 
        
      system.debug('NOTES__c');
        system.debug(updatedLead.Notes__c);
        
        List<Task> taskList2 = [SELECT
            Id,             
            Subject, 
            WhoId,
            OwnerId,
            CallDisposition,
            Status,
            Priority,
            Description,
            CreatedById,
            LastModifiedById FROM Task WHERE Subject = 'Outbound Call'];
        
        system.assertEquals(2,taskList2.size()); 
        
    }
}