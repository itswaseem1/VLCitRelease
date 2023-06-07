@isTest
private class TestLeadTriggerHandler{
    
    public static ID recId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default Citation Record Type').getRecordTypeId();
    public static ID IndirecId = Schema.SObjectType.Individual.getRecordTypeInfosByName().get('Default Citation Record Type').getRecordTypeId();
    
    public static void createTestData(){
        list<lead> ld = new list<lead>();
        list<lead> leadList = new list<lead>();
        
        for(integer i=0;i<10;i++){
            lead led = new lead();
            led.RecordTypeId =recId;
            led.CurrencyIsoCode='EUR';
            led.FT_Employees__c=2;
            led.PT_Employees__c=3;
            led.Directors__c=4;
            led.Renewal_Date__c = System.today().adddays(5);
            led.Date_Made__c    = System.today();
            led.Subcontractors__c=7;
            led.LeadSource='3rd_party';
            led.Email='test016@'+i+'gmail.com';
            led.Lastname = 'Test lead'+i;
            led.company = 'Test company'+i;
            led.HasOptedOutOfEmail = true;
            //led.DFE_Area__c = '370';
            ld.add(led);
        }
        //insert ld;    
        system.assert(ld != null,'Lead Records Inserted sucessfully');
        
        List<Individual> indList = new List<Individual>();
        for (Integer i=0;i<=10;i++) {
            indList.add(new Individual(RecordTypeId = IndirecId ,LastName='last',FirstName='first',Email__c ='Test981@gmail.com',Group_Company_Name__c ='Citation'));
        }
        insert indList;
        system.assert(indList != null ,'Indiviudal record inserted successfully');
        ld[0].Email= 'Test981@gmail.com';
        ld[0].individualId = indList[0].Id;
        ld[0].SectorRejected__c = true;
        ld[0].SectorUpdate__c = true;
        //leadList.add(ld[0]);
        
        ld[1].Email= 'Test982@gmail.com';
        ld[1].individualId = indList[1].Id;
        ld[1].Sector__c = 'Cleaning';
        //leadList.add(ld[1]);
        
        ld[2].Email= 'Test983@gmail.com';
        ld[2].individualId = indList[2].Id;
        //ld[2].Sector__c = 'Cleaning';
        //leadList.add(ld[2]);
        
        //update leadList;
        insert ld;
    }
    @isTest
    static void TestUpdateSalesMarketingChannel(){
        List<Lead> leads=TestDataFactory.getLeads(1,'Test Lead','Test Company',false);
        leads[0].RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Default_Citation_Record_Type').getRecordTypeId();
        leads[0].LeadSource='Cross Sell - Citation';
        leads[0].Status = 'Pended';
        leads[0].Email = 'Test98@gmail.com';
        Test.startTest();
        insert leads;
        Lead l=[SELECT LeadSource,Marketing_Channel__c,Sales_Channel__c from Lead  where Id=:leads[0].Id];
        //System.assertEquals(l.Marketing_Channel__c, 'Citation', 'Marketing Channel Not updated');
        //System.assertEquals(l.Sales_Channel__c, 'Cross Sell', 'Sales Channel Not updated');
        l.Sector__c='Care';
        l.LeadSource='Cross Sell - QMS';
        update l;
        l=[SELECT Marketing_Channel__c,Sales_Channel__c from Lead where Id=:l.Id];
        //System.assertEquals(l.Marketing_Channel__c, 'QMS', 'Marketing Channel Not updated');
        //System.assertEquals(l.Sales_Channel__c, 'Cross Sell', 'Sales Channel Not updated');
        l.Sales_Channel__c=l.Marketing_Channel__c=null;
        update l;
        database.executeBatch(new BatchUpdateSalesMarketingChannelLead(),200);
        Test.stopTest();
    }
    
    @isTest
    static void testSectorLastSubmittedBy_WhenSectorUpdatedBySameUser() {
        User iHASCOUser = bg_User_TestUtils.createQMSSalesUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        insert iHASCOUser;
        
        System.runAs(iHASCOUser) {
            createTestData();
            Lead objLead = [Select Id, SectorUpdate__c, SectorRejected__c, Sector__c, CitationSector__c, LastModifiedById,SectorLastSubmittedBy__r.Id  from Lead where Email = 'Test981@gmail.com'];
            objLead.Sector__c = 'Security';
            objLead.SectorUpdate__c = true;
            Test.startTest();
            update objLead;
            
            Lead objLead2 = [Select Id, SectorUpdate__c, SectorRejected__c, Sector__c, CitationSector__c, LastModifiedById,SectorLastSubmittedBy__r.Id  from Lead where Email = 'Test981@gmail.com'];
            
            Test.stopTest();
            system.assertEquals(objLead2.SectorUpdate__c, false);
            system.assertEquals(objLead2.SectorRejected__c, false);
            system.assertEquals(objLead2.SectorLastSubmittedBy__r.Id, objLead2.LastModifiedById);
            
        }
        
        
        List<Lead> leads = TestDataFactory.getLeads(1,'Test Lead','Test Company',false);
        List<String> ihascoIntegrationusers = new List<String>(System.Label.iHascoLeadDataIntegrationUsers.split(','));
        if(ihascoIntegrationusers.size() > 0) {
            User ihascoIntegrationUser = [Select Name from User where Id =: ihascoIntegrationusers[0]];
            system.runAs(ihascoIntegrationUser) {
                insert leads;    
                system.assert( leads[0].Id != null ,'Lead Records Inserted sucessfully');
            }
        }
        
        
    }
    
    @isTest
    static void testSectorLastSubmittedBy_WhenSectorUpdatedByAnotherUser() {
        createTestData();
        Lead objLead = [Select Id, SectorUpdate__c, SectorRejected__c, Sector__c, CitationSector__c, LastModifiedById,SectorLastSubmittedBy__r.Id  from Lead where Email = 'Test982@gmail.com'];
        objLead.Sector__c = 'Security';
        objLead.SectorUpdate__c = true;
        
        system.assertEquals(objLead.SectorLastSubmittedBy__r.Id, objLead.LastModifiedById);
        
        Test.startTest();
        
        List<String> ihascoIntegrationusers = new List<String>(System.Label.iHascoLeadDataIntegrationUsers.split(','));
        if(ihascoIntegrationusers.size() > 0) {
            User ihascoIntegrationUser = [Select Name from User where Id =: ihascoIntegrationusers[0]];
            system.runAs(ihascoIntegrationUser) {
                update objLead;  
            }
        }
        Lead objLead2 = [Select Id, SectorUpdate__c, SectorRejected__c, Sector__c, CitationSector__c, LastModifiedById,SectorLastSubmittedBy__r.Id  from Lead where Email = 'Test982@gmail.com'];
        
        Test.stopTest();
        system.assertEquals(objLead2.SectorUpdate__c, false);
        system.assertEquals(objLead2.SectorRejected__c, false);
        system.assertEquals(objLead2.SectorLastSubmittedBy__r.Id, objLead2.LastModifiedById);
    }
    
    @isTest
    static void testSectorLastSubmittedBy_WhenSectorIsNotUpdatedOnLead() {
        User iHASCOUser = bg_User_TestUtils.createQMSSalesUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        insert iHASCOUser;
        
        createTestData();
        Lead objLead = [Select Id, SectorUpdate__c, SectorRejected__c, Sector__c, CitationSector__c, LastModifiedById,SectorLastSubmittedBy__r.Id  from Lead where Email = 'Test982@gmail.com'];
        Test.startTest();
        
        System.runAs(iHASCOUser) {
            update objLead;  
        }
        
        Lead objLead2 = [Select Id, SectorUpdate__c, SectorRejected__c, Sector__c, CitationSector__c, LastModifiedById,SectorLastSubmittedBy__r.Id  from Lead where Email = 'Test982@gmail.com'];
        
        Test.stopTest();
        system.assertNotEquals(objLead2.SectorLastSubmittedBy__r.Id, objLead2.LastModifiedById);
    }
    
    @isTest
    static void testSectorLastSubmittedBy_WhenSectorIsPopulatedWhileInsertion() {
        User iHASCOUser = bg_User_TestUtils.createQMSSalesUser('1');
        iHASCOUser.profileid=[select id from Profile where name='System Administrator'].id;
        iHASCOUser.Division ='iHASCO';
        insert iHASCOUser;
        
        System.runAs(iHASCOUser) {
            createTestData();
            Lead objLead2 = [Select Id, SectorUpdate__c, SectorRejected__c, Sector__c, CitationSector__c, LastModifiedById,SectorLastSubmittedBy__r.Id  from Lead where Email = 'Test982@gmail.com' and SectorLastSubmittedBy__c != null];
            system.assertEquals(objLead2.SectorUpdate__c, false);
            system.assertEquals(objLead2.SectorRejected__c, false);
            system.assertEquals(objLead2.SectorLastSubmittedBy__r.Id, objLead2.LastModifiedById);	            
        }
    }
    
    @isTest
    static void testSectorLastSubmittedBy_WhenSectorIsNotPopulatedWhileInsertion() {
        createTestData();
        Lead objLead2 = [Select Id, SectorUpdate__c, SectorRejected__c, Sector__c, CitationSector__c, LastModifiedById,SectorLastSubmittedBy__r.Id  from Lead where Email = 'Test983@gmail.com'];
        system.debug(objLead2);
        system.assertEquals(objLead2.Sector__c, null);
        system.assertEquals(objLead2.SectorUpdate__c, false);
        system.assertEquals(objLead2.SectorRejected__c, false);
        system.assertEquals(objLead2.SectorLastSubmittedBy__c, null);
    }
    
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel for Based on LeadSource on Lead
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonLeadBasedonLeadSource(){
        //List to store all Leads to Insert
        List<Lead> leadstoInsert=new List<Lead>();
        //All Picklist Values of LeadSource that are related to the values in Group_Configuration__mdt Records
        List<String> LeadSourcedesirredValues=new List<String>{'Cross Sell - Mitigate','ELAS','Cross Sell_uCheck','EPM Cross Sell','Food Alert','HS Direct','Cross Sell_iHASCO','Cross Sell_P&R','Cross Sell - QMS','Cross Sell_SMAS','Cross Sell - Southalls'};
        //Leads to Test Sales Channel Based on different Values in LeadSource
        List<Lead> leadwithLeadSource=TestDataFactory.getLeads(LeadSourcedesirredValues.size(),'TestLeadonLeadSource','TestCompanyonLeadSource',false);
        //Update the LeadSource for all the Leads with Picklist Values in LeadSourcedesirredValues List
        for(Integer i=0;i<LeadSourcedesirredValues.size();i++){
            leadwithLeadSource[i].status = 'Approved';
            leadwithLeadSource[i].Appointment_Type__c='Combined';
            leadwithLeadSource[i].CitationSector__c='ACCOMMODATION';
            leadwithLeadSource[i].MADE_Criteria__c='Franchises - 1';
            leadwithLeadSource[i].LeadSource=LeadSourcedesirredValues[i];
            leadstoInsert.add(leadwithLeadSource[i]);
        }
        //Insert Lead
        Test.startTest();
        insert leadstoInsert;
        Test.stopTest();
        //Get all the Leads inserted to Verify SalesChannel
        List<Lead> leadsInserted=[Select Id,Sales_Channel__c,LeadSource From Lead where Id IN :leadstoInsert];
        //All above Leads should have SalesChannel as "Cross Sell"
        for(Lead eachLead: leadsInserted){
            System.assertEquals('Cross Sell',eachLead.Sales_Channel__c, 'Sales Channel is Expected to be Cross Sell But It is '+eachLead.Sales_Channel__c+' Where LeadSource is '+eachLead.LeadSource);
        }  
    }
    
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel for Based on Referred_By_Citation_Company__c on Lead
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonLeadBasedonReferredbyCitationCompany(){
        //List to store all Leads to Insert
        List<Lead> leadstoInsert=new List<Lead>();
        //All Picklist Values of ReferredByCompanyInternal__c that are related to the values in Group_Configuration__mdt Records
        List<String> ReferredbyccdesirredValues=new List<String>{'QMS','ELAS','EPM','Food Alert','HS Direct/EL Direct','iHASCO','SMAS','Southalls','uCheck','Mitigate'};
            //Leads to Test Sales Channel Based on different Values in "Referred By Citation Company"
            List<Lead> leadswithReferredbycc=TestDataFactory.getLeads(ReferredbyccdesirredValues.size(),'TestLead','TestCompany',false);
            //Update the ReferredByCompanyInternal__c for all the Leads with Picklist Values in ReferredbyccdesirredValues List
            for(Integer i=0;i<ReferredbyccdesirredValues.size();i++){
                leadswithReferredbycc[i].status = 'Approved';
                leadswithReferredbycc[i].Appointment_Type__c='Combined';
                leadswithReferredbycc[i].CitationSector__c='ACCOMMODATION';
                leadswithReferredbycc[i].MADE_Criteria__c='Franchises - 1';
                leadswithReferredbycc[i].ReferredByCompanyInternal__c=ReferredbyccdesirredValues[i];
                leadstoInsert.add(leadswithReferredbycc[i]);
            }
            //Insert Leads
            Test.startTest();
            Insert leadstoInsert;
            Test.stopTest();
            //Get all the Leads Updated to Verify SalesChannel
            List<Lead> leadsInserted=[Select Id,Sales_Channel__c,ReferredByCompanyInternal__c From Lead where Id IN :leadstoInsert];
            //All above Leads should have SalesChannel as "Cross Sell"
            for(Lead eachLead: leadsInserted){
                System.assertEquals('Cross Sell',eachLead.Sales_Channel__c, 'Sales Channel is Expected to be Cross Sell But It is '+eachLead.Sales_Channel__c+' Where Referred By Citation Company is '+eachLead.ReferredByCompanyInternal__c);
            }
    }
    
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel for Based on Values in Source__c and Data_Supplier__c on Lead
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonLeadforSourceandDataSuplier(){
        //List to store all Leads to Insert
        List<Lead> leadstoInsert=new List<Lead>();
        //List of String values fron Group_Configuration__mdt Records
        List<string> keyMap = TriggerOpportunityHandlerTest.verifySalesChannelonOppHelper();
        //Get the Leads for Insertion
        List<Lead> leadswithSource=TestDataFactory.getLeads(keyMap.size(),'TestLeadforSource','TestCompanyforSource',false);
        //Update the Source__c for all the Leads with Strings from Group_Configuration__mdt Records
        for(Integer i=0;i<keyMap.size();i++){
            leadswithSource[i].status = 'Approved';
            leadswithSource[i].Appointment_Type__c='Combined';
            leadswithSource[i].CitationSector__c='ACCOMMODATION';
            leadswithSource[i].MADE_Criteria__c='Franchises - 1';
            leadswithSource[i].Source__c= keyMap[i];
            leadstoInsert.add(leadswithSource[i]);
        }
        //Leads to Test Sales Channel Based on different Values in Data Supplier
        List<Lead> leadswithDataSupplier=TestDataFactory.getLeads(keyMap.size(),'TestLeadforDataSuplier','TestCompanyforDataSuplier',false);
        //Update the Data_Supplier__c for all the Leads with Strings from Group_Configuration__mdt Records
        for(Integer i=0;i<keyMap.size();i++){
            leadswithDataSupplier[i].status = 'Approved';
            leadswithDataSupplier[i].Appointment_Type__c='Combined';
            leadswithDataSupplier[i].CitationSector__c='ACCOMMODATION';
            leadswithDataSupplier[i].MADE_Criteria__c='Franchises - 1';
            leadswithDataSupplier[i].Data_Supplier__c= keyMap[i];
            leadstoInsert.add(leadswithDataSupplier[i]);
        }
        //Insert Leads
        Test.startTest();
        insert leadstoInsert;
        Test.stopTest();
        //Get all the Leads inserted to Verify SalesChannel
        List<Lead> leadsInserted=[Select Id,Sales_Channel__c,Data_Supplier__c,Source__c From Lead where Id IN :leadstoInsert];
        //All above Leads should have SalesChannel as "Cross Sell"
        for(Lead eachLead: leadsInserted){
            System.assertEquals('Cross Sell',eachLead.Sales_Channel__c, 'Sales Channel is Expected to be Cross Sell But It is '+eachLead.Sales_Channel__c+'Where Source is '+eachLead.Source__c+' and Data_Supplier__C is '+eachLead.Data_Supplier__c);
        }
    }
    
    /**
     * @date 28-09-2022
     * @description This Method is used to Test value in SalesChannel when Lead doesn't contain values in Keywords
     * @param No Parameters
     * @return void(returns nothing)
     */
    @isTest public static void verifySalesChannelonOppwhennotinKeyword(){
        //Lead to Test Sales Channel
        List<Lead> leadstoVerify=TestDataFactory.getLeads(1,'TestLead','TestCompany',false);
        leadstoVerify[0].status = 'Approved';
        leadstoVerify[0].Appointment_Type__c='Combined';
        leadstoVerify[0].CitationSector__c='ACCOMMODATION';
        leadstoVerify[0].MADE_Criteria__c='Franchises - 1';
        //insert Lead
        insert leadstoVerify[0];
        //Get the Lead inserted to Verify SalesChannel
        Lead leadInserted=[Select Id,Sales_Channel__c From Lead where Id=:leadstoVerify[0].Id];
        //Above Lead shouldn't have SalesChannel as "Cross Sell"
        System.assertNotEquals('Cross Sell',leadInserted.Sales_Channel__c, 'Sales Channel is Expected to be not Cross Sell But It is Cross Sell');
    }
}