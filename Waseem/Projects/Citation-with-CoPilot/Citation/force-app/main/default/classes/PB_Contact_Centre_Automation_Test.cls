@isTest
private class PB_Contact_Centre_Automation_Test {

    static user CreateUserForProfile(profile p) {

         user validUser = new user(ProfileId = p.id , 
						username = 'Prof_TestUser@citation.co.uk', 
						lastname = 'TestUser',
						email = 'testuser@citation.co.uk',
						alias = 'pbtest', isactive = true ,
						timezonesidkey = 'Europe/London',
						localeSidKey = 'en_GB',
						EmailEncodingKey = 'ISO-8859-1',
						LanguageLocaleKey = 'en_US'
                ) ;
        insert ValidUser  ; 
        return validUser ;

    }

    static user CreateUSerForProfileAndRole(profile p, userrole r) {
        user validUser = new user(ProfileId = p.id , UserRoleID = r.id,
						username = 'RoleAndPRof_TestUser@citation.co.uk', 
						lastname = 'TestUser',
						email = 'testuser@citation.co.uk',
						alias = 'pbtest', isactive = true ,
						timezonesidkey = 'Europe/London',
						localeSidKey = 'en_GB',
						EmailEncodingKey = 'ISO-8859-1',
						LanguageLocaleKey = 'en_US'
                ) ;
        insert ValidUser  ; 
        return validUser ;
    }
	
    static user getValidPBUser() {
        Profile p = [select id from Profile where name = 'Citation Data Quality & Diary Mgmt (inc MI)'] ;        
        return CreateUserForProfile(p) ;
    }

    static user getCitationDataAdminUser() {
        Profile p = [select id from Profile where name = 'Citation Data Admin'] ;
        return CreateUserForProfile(p) ;        
    }

    static user getASTUser() {
        Profile p = [select id from Profile where name = 'Citation Data Quality & Diary Mgmt (inc MI)'] ; 
        UserRole r = [select id from USerRole where name = 'Add-On Sales'] ;
        return CreateUSerForProfileAndRole(p,r) ;        
    }

    static user getQMSUser() {
        Profile p = [select id from Profile where name = 'QMS Sales Team'] ;
        return CreateUserForProfile(p) ;
    }

    

    static testmethod void BulkTest_Node1_Callback_Status_Test() {
        list<lead> LeadList = new list<Lead>() ;
        user testUser = getValidPBUser() ;
        for(integer i = 0; i < 10; i++) {
                LeadList.add(new Lead(postalcode='S42 6FG',lastname='Smith' + i, company = 'Acme Ltd' + i,Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Callback Requested',Visit_Type__c = 'Virtual')) ;
        }

        test.starttest() ;
        system.runas(testUser) {
            insert LeadList ;
        }
        test.stoptest() ;

        list<lead> TestLeadList = [select id,bdc__c,Callback_Date_Time__c,createdbyid from Lead ] ;
        for(Lead L : TestLeadList) {
            system.assertEquals(testUser.id,L.bdc__c) ;            
        }


    }

    static testmethod void BulkTest_Node1_Callback_Status_Test_As_Admin() {
        list<lead> LeadList = new list<Lead>() ;
        user AdminUser = getCitationDataAdminUser() ;
        
        for(integer i = 0; i < 10; i++) {
                LeadList.add(new Lead(postalcode='S42 6FG',lastname='Smith' + i, company = 'Acme Ltd' + i,Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Callback Requested',Visit_Type__c = 'Virtual')) ;
        }

        test.starttest() ;
             system.runas(adminUser) {
                insert LeadList ;
             }
        test.stoptest() ;

        list<lead> TestLeadList = [select id,bdc__c,Callback_Date_Time__c,createdbyid from Lead ] ;
        for(Lead L : TestLeadList) {
            system.assertEquals(null,L.bdc__c) ;            
        }


    }
	
		 
	static testmethod void Node1_Callback_Status_Check_AST() {		
        user testUser = getASTUser() ;
		Lead testLead = new lead() ;

        test.starttest() ;
		system.runas(testUser) {
			TestLead = new Lead(postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Callback Requested') ;
	    	Insert testLead ;			
		}
		test.stoptest() ;
		Lead CheckTestLead = [select id,bdc__c,Callback_Date_Time__c,createdbyid from Lead limit 1] ;
		
        system.assertequals(null,CheckTestLead.bdc__c) ;		
	}
    	
	static testmethod void Node2_Callback_Status_Check() {		
        user testUser = getValidPBUser() ;
		Lead testLead = new lead() ;

        test.starttest() ;
		system.runas(testUser) {
			TestLead = new Lead(postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Callback Requested') ;
	    	Insert testLead ;
			
		}
        test.stoptest() ;
		
		Lead CheckTestLead = [select id,bdc__c,Callback_Date_Time__c,createdbyid from Lead limit 1] ;
		
        system.assertEquals(testUser.id,CheckTestLead.bdc__c) ;
		system.assertEquals(testUser.id,CheckTestLEad.createdbyid) ;
	}


    static testmethod void Node3_DQ_To_Pended_Check() {		
        user testUser = getValidPBUser() ;
		Lead testLead = new lead() ;
        Lead PendedLead = new lead() ;
       
        test.starttest() ;
		system.runas(testUser) {
            TestLead = new Lead(Appointment_Type__c='Combined',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Data Quality',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid(),Visit_Type__c = 'Virtual') ;
	        Insert testLead ;

            PendedLead = [select id,status from Lead where id = :testLead.id] ;
			
            PendedLead.status = 'Pended' ;

            update PendedLead ;
			
		}
        test.stoptest() ;
		
		Lead CheckTestLead = [select id,pended_date__c from Lead limit 1] ;
		
        system.assertNotEquals(null,CheckTestLEad.pended_date__c) ;

	}

    static testmethod void Node3_DQ_To_Pended_Check_AsAdmin() {		
        user testUser = getCitationDataAdminUser() ;
		Lead testLead = new lead() ;
        Lead PendedLead = new lead() ;
       
        test.starttest() ;
		system.runas(testUser) {
            TestLead = new Lead(Appointment_Type__c='Combined',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Data Quality',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid(),Visit_Type__c = 'Virtual') ;
	        Insert testLead ;

            PendedLead = [select id,status from Lead where id = :testLead.id] ;
			
            PendedLead.status = 'Pended' ;

            update PendedLead ;
			
		}
        test.stoptest() ;
		
		Lead CheckTestLead = [select id,pended_date__c from Lead limit 1] ;
		
        system.assertEquals(null,CheckTestLEad.pended_date__c) ;

	}


    


    static testmethod void Node4_Rejected_Status_Check() {		
        user testUser = getValidPBUser() ;
		Lead testLead = new lead() ;
        Lead RejectedLead = new lead() ;       

        test.starttest() ;
		system.runas(testUser) {
            TestLead = new Lead(Appointment_Type__c='Combined',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Data Quality',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid(),Visit_Type__c = 'Virtual') ;
	        Insert testLead ;

            RejectedLead = [select id,status from Lead where id = :testLead.id] ;
			
            RejectedLead.status = 'Data Quality' ;

            update RejectedLead ;
			
		}

        test.stoptest() ;

        /* unable to assert this as the only action for this node is an email alert */

	}

    


    static testmethod void Node5_Data_Quality_Check() {		
        user testUser = getValidPBUser() ;
		Lead testLead = new lead() ;
        Lead DQLead = new lead() ;       

        test.starttest() ;
		system.runas(testUser) {
            TestLead = new Lead(Appointment_Type__c='Combined',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Callback Requested',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid(),Visit_Type__c = 'Virtual') ;
	        Insert testLead ;

            DQLead = [select id,status from Lead where id = :testLead.id] ;
			
            DQLead.status = 'Data Quality' ;

            update DQLead ;
			
		}

        test.stoptest() ;

        Lead CheckDQLead = [select id,date_made__c,Callback_Date_Time__c from lead limit 1] ;

        system.assertEquals(null,CheckDQLead.Callback_Date_Time__c) ;
        system.AssertNotEquals(null,CheckDQLead.date_made__c) ;

        

	}

    static testmethod void Node5_Data_Quality_Check_QMSUser() {		
        user testUser = getQMSUser() ;
		Lead testLead = new lead() ;
        Lead DQLead = new lead() ;       

        test.starttest() ;
		system.runas(testUser) {
            TestLead = new Lead(Appointment_Type__c='Combined',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Callback Requested',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid()) ;
	        Insert testLead ;

            DQLead = [select id,status from Lead where id = :testLead.id] ;
			
            DQLead.status = 'Data Quality' ;

            update DQLead ;
			
		}

        test.stoptest() ;

        Lead CheckDQLead = [select id,date_made__c,Callback_Date_Time__c from lead limit 1] ;

         system.AssertEquals(null,CheckDQLead.date_made__c) ;

        

	}

    static testmethod void Node6_NonISO_Approved_Check() {		
        user testUser = getValidPBUser() ;
		Lead testLead = new lead() ;
        Lead ApprovedLead = new lead() ;       

        test.starttest() ;
		system.runas(testUser) {
            TestLead = new Lead(sector__c='Accommodation', CitationSector__c = 'ACCOMMODATION',Appointment_Type__c='Combined',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Data Quality',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid(),Visit_Type__c = 'Virtual') ;
	        Insert testLead ;

            ApprovedLead = [select id,status from Lead where id = :testLead.id] ;
			
            ApprovedLead.status = 'Approved' ;

            update ApprovedLead ;
			
		}

        test.stoptest() ;

        Lead CheckApprovedLead = [select id,approved_By__c, approved_date__c from lead limit 1] ;

        list<Task> LeadList = new List<Task>([select id,ActivityDate from task where Subject = 'Confirmation email sent'  and createddate = today]) ;

        System.assertNotEquals(null,CheckApprovedLead.approved_by__c) ;
        System.assertNotEquals(null,CheckApprovedLead.approved_date__c) ;
        System.AssertEquals(1,LeadList.size()) ;
        

       

	}

    static testmethod void Node6_NonISO_Approved_QMSUser_Check() {		
        user testUser = getQMSUser() ;
		Lead testLead = new lead() ;
        Lead QMSApprovedLead = new lead() ;       

        
        TestLead = new Lead(ownerid=testuser.id,date_made__c = date.today(),sector__c='Accommodation', CitationSector__c = 'ACCOMMODATION',Appointment_Type__c='Combined',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'Inbound - 1',Status='Data Quality',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid(),Visit_Type__c = 'Virtual') ;
        Insert testLead ;

        Id[] unlockRecordIds = new Id[0] ;
        unlockRecordIds.add(testLEad.id) ;

        Approval.UnlockResult[] results = Approval.unlock(unlockRecordIds, false);

        test.starttest() ;

		system.runas(testUser) {

            QMSApprovedLead = [select id,status from Lead ] ;
			
            QMSApprovedLead.status = 'Approved' ;

            update QMSApprovedLead ;
			
		}

        test.stoptest() ;

        Lead CheckQMSApprovedLead = [select id,approved_By__c, approved_date__c from lead limit 1] ;

        System.assertEquals(null,CheckQMSApprovedLead.approved_by__c) ;
        System.assertEquals(null,CheckQMSApprovedLead.approved_date__c) ;
        System.AssertEquals(0,[select id from task where Subject = 'Confirmation email sent'].size()) ;
       

	}


    static testmethod void Node7_ISO_Approved_Check() {		
        user testUser = getValidPBUser() ;
		Lead testLead = new lead() ;
        Lead ApprovedLead = new lead() ;       

        test.starttest() ;
		system.runas(testUser) {
            TestLead = new Lead(sector__c='Accommodation', CitationSector__c = 'ACCOMMODATION',Appointment_Type__c='ISO',postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'ISO - MADE',Status='Data Quality',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid(),Visit_Type__c = 'Virtual') ;
	        Insert testLead ;

            ApprovedLead = [select id,status from Lead where id = :testLead.id] ;
			
            ApprovedLead.status = 'Approved' ;

            update ApprovedLead ;
			
		}

        test.stoptest() ;

        Lead CheckApprovedLead = [select id,approved_By__c, approved_date__c from lead limit 1] ;

        System.assertNotEquals(null,CheckApprovedLead.approved_by__c) ;
        System.assertNotEquals(null,CheckApprovedLead.approved_date__c) ;
        System.AssertEquals(0,[select id from task where Subject = 'Confirmation email sent'].size()) ;
       

	}

    static testmethod void Node7_ISO_Approved_Check_ASTUser() {		
        user testUser = getASTUser() ;
		Lead testLead = new lead() ;
        Lead ApprovedLead = new lead() ;       
		
        test.starttest() ;
		system.runas(testUser) {
            TestLead = new Lead(sector__c='Accommodation',CitationSector__c = 'ACCOMMODATION', Appointment_Type__c='ISO',date_made__c = date.today(),postalcode='S42 6FG',lastname='Smith', company = 'Acme Ltd',Leadsource='Advert',Made_Criteria__c = 'ISO - MADE',Status='Data Quality',email='test@test.test',salutation='Mr',position__c='Accountant',street='TestStreet',bdc__c = userinfo.getuserid()) ;
	        Insert testLead ;

            ApprovedLead = [select id,status from Lead where id = :testLead.id] ;
			
            ApprovedLead.status = 'Approved' ;
			system.debug(testUser) ;
            update ApprovedLead ;
			
		}

        test.stoptest() ;

        Lead CheckApprovedLead = [select id,approved_By__c, approved_date__c from lead limit 1] ;

        System.assertEquals(null,CheckApprovedLead.approved_by__c) ;
        System.assertEquals(null,CheckApprovedLead.approved_date__c) ;
        System.AssertEquals(0,[select id from task where Subject = 'Confirmation email sent'].size()) ;
       

	}

    



    




    
	
}