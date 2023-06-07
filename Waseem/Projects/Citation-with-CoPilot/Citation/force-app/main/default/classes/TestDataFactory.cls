@isTest
public class TestDataFactory{

    public static List<Lead> getLeads(Integer noOfLeads,String leadName,String companyName,Boolean doInsert){
        List<Lead> leadList = new List<Lead>();
        for(Integer i=0; i<noOfLeads ; i++){
            Lead l            = new Lead();
            l.LastName        = leadName+' ' + i;
            l.Company         = 'Citation';
            l.Renewal_Date__c = System.today().adddays(5);
            l.Status          = 'Open';
            l.Suspended_Closed_Reason__c = 'Future Third Party';
            l.Date_Made__c    = System.today();
            leadList.add(l);
        }
        if(doInsert){
            insert leadList;
        }
        return leadList;
    }

    public static List<Account> getAccounts(Integer noOfAcc,String accName,Boolean doInsert){
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<noOfAcc; i++){
            Account a = new Account();
            a.Name    = accName+' '+i;
            accList.add(a);
        }
        if(doInsert){
            insert accList;
        }
        return accList;
    }

    public static List<Contact> getContacts(Integer noOfCon,String firstName,String lastName,Id accountId,Boolean doInsert){
        List<Contact> conList = new List<Contact>();
        for(Integer i=0; i<noOfCon; i++){
            Contact c   = new Contact();
            c.FirstName = firstName;
            c.LastName  = lastName+' '+i;
            c.AccountId = accountId;
            conList.add(c);
        }
        if(doInsert){
            insert conList;
        }
        return conList;
    }

    public static list<contact> generateAccountWithContacts(String accName,Integer numContacts,String firstName,String lastName,Boolean doInsert){
        Account a = getAccounts(1,accName,true)[0];
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numContacts; i++){
            String lastNameCon = lastName+' '+i;
            contacts.addAll(getContacts(numContacts,firstName,lastNameCon,a.Id,false));
        }
        if(doInsert){
            insert contacts;
        }

        return contacts;
    }

    public static List<Opportunity> generateOppsForAccount(Id accountId,Decimal amount,Integer noOfOpps,Boolean doInsert){
        List<Opportunity> oppoList = new List<Opportunity>();       
        for(Integer i = 0; i<noOfOpps; i++){
            Opportunity o = new Opportunity();
            o.Name        = 'Account ' + i;
            o.AccountId   = accountid;
            o.Amount      = amount;
            o.CloseDate   = Date.today().addDays(5);
            o.StageName   = 'Prospecting';
            oppoList.add(o);
        }
        if(doInsert){
            insert oppoList;
        }
        return oppoList;
    }

    public static List<Task> generateTask_Lead(String leadName,String companyName,Integer noOfTasks,Boolean doInsert){
        Lead l = new Lead(
            LastName        = 'Kumar',
            Company         = 'Citation',
            Renewal_Date__c = System.today().adddays(5),
            Status          = 'Open',
            Suspended_Closed_Reason__c = 'Future Third Party',
            Date_Made__c    = System.today()
        );
        insert l;
        List<Task> taskList = new List<Task>();        
        for(Integer i=0; i<noOfTasks; i++){
            Task t = new Task();
                t.Subject              = 'Call';
                t.Reporting_Subject__c = 'Subject Call = '+i;
                t.WhoId                = l.Id;
                t.Status__c            = 'Open';
                t.Rating__c            = 'Hot';
                t.Suspended_Close__c   = 'Answer Machine';
                t.FullTimeEmployees__c = 299;
                t.CallbackDateTime__c  = Datetime.newInstance(2019, 14, 10, 12, 30, 2);
                t.CallObject         = 'Example Task';
                taskList.add(t);
        }
        if(doInsert){
            insert taskList;
        }
        return taskList;
    }

    public static list<event> generateEvents(Integer nofevents,string stsubject,datetime sttime,datetime edtime,string ctType,string evstatus,id whocid,id whataid){
        list<event> evtList = new list<event>();
        for(integer i=0;i<nofevents;i++){
            event et = new event();
            et.StartDateTime = sttime;
            et.EndDateTime = edtime;
            et.subject = stsubject;
            et.Contact_Type__c = ctType;
            et.Event_Status__c = evstatus;
            et.whoid = whocid;
            et.whatid = whataid;
            et.type = 'Renewal';
            evtList.add(et);
        }
        
        return evtList;
    }

    public static User generateUser(){
        UserRole userRole = new UserRole(DeveloperName = 'CitationDeveloper', Name = 'Citation Limited');
        insert userRole;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='Citation Contact Centre Manager' LIMIT 1].Id,
            FirstName       = 'Glenn',
            LastName        = 'Maxwell',
            Email           = 'glennmaxwell@citation.co.uk',
            Username        = 'glennmaxwell@citation.co.uk',
            CompanyName     = 'Citation Company',
            Title           = 'Captian',
            Alias           = 'glem',
            TimeZoneSidKey  = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey    = 'en_US',
            UserRoleId      = userRole.Id
        );
        insert u;
        return u;
    }

    public static List<ffbc__Contract__c> getBillingContracts(Id companyId){
        Account accRec = new Account();
        accRec.Name = 'Citation Account';
        insert accRec;
        List<ffbc__Contract__c> con = new List<ffbc__Contract__c>();
        for(Integer i=1;i<7;i++){
            ffbc__Contract__c contract = new ffbc__Contract__c();
            contract.ffbc__Account__c = accRec.Id;
            contract.ffbc__Company__c = companyId;
            contract.Contract_Type__c = 'New';
            con.add(contract);
        }
        return con;
    }

    public static List<Revenue_Recognition_Logic__c> getRevRecLogic(String Name,String newRenewal,String pro,String company){
        List<Revenue_Recognition_Logic__c> rec = new List<Revenue_Recognition_Logic__c>();
        Revenue_Recognition_Logic__c recrev;
        for(Integer i=0;i<50;i++){
            recrev = new Revenue_Recognition_Logic__c();
            recrev.Name = Name;
            recrev.New_or_Renewal__c = newRenewal;
            recrev.Product_Grouping__c = pro;
            recrev.Selling_Company__c = company;
            recrev.Month_9__c = 120.00000;
            recrev.Month_10__c = 120.00000;
            recrev.Month_23__c = 240.00000;
            recrev.Month_24__c = 240.00000;
            recrev.Month_25__c = 240.00000;
            recrev.Month_26__c = 240.00000;
            recrev.Term_months__c = 10;
            rec.add(recrev);
        }
        return rec;
    }

    public static List<ffbc__ContractLineItem__c> getContractLineItems(Id billContract, Id proId, Id revrecId){
        List<ffbc__ContractLineItem__c> contractList = new List<ffbc__ContractLineItem__c>();
        for(Integer i=1;i==1;i++){
            ffbc__ContractLineItem__c ffbc = new ffbc__ContractLineItem__c();
            ffbc.ffbc__Contract__c = billContract;
            ffbc.ffbc__ProductService__c = proId;
            ffbc.Service_Start_Date__c = Date.newInstance(2018,12,14);
            ffbc.Service_End_Date__c = Date.newInstance(2019,10,14);
            ffbc.ffbc__BillingType__c = 'Recurring Fixed';
            ffbc.ffbc__Quantity__c = 10;
            ffbc.Revenue_Recognition_Logic__c = revrecId;
            contractList.add(ffbc);
        }
        return contractList;
    }

    public static List<fferpcore__Company__c> getCompanys(String companyName){
        List<fferpcore__Company__c> ffer = new List<fferpcore__Company__c>();
        fferpcore__Company__c ffer1 = new fferpcore__Company__c();
        ffer1.Name = companyName;
        ffer.add(ffer1);
        return ffer;
    }

    public static List<Product2> getProducts(String prodName,String groupName){
        List<Product2> prod = new List<Product2>();
            Product2 pro1 = new Product2();
            pro1.Name = prodName;
            pro1.Product_Grouping__c = groupName;
            prod.add(pro1);
            Product2 pro2 = new Product2();
            pro2.Name = prodName+' 1';
            pro2.Product_Grouping__c = groupName;
            prod.add(pro2);
            if(prod.size()>0){
                insert prod;
            }
        return prod;
    }

    public static List<Pricebook2> getPricebooks(){
        List<Pricebook2> priceList = new List<Pricebook2>();
        for(Integer i=0;i<1;i++){
            Pricebook2 price = new Pricebook2();
            price.Name = '£0 - £75,000 (CPQ) '+i;
            price.IsActive = true;
            priceList.add(price);
        }
        if(!priceList.isEmpty()){
            insert priceList;
        }
        return priceList;
    }

    public static SBQQ__Quote__c getQuotesNoDML(Id oppoId,Id accId,Id conId,Id priceId){
            SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c();
            cpqQuote.SBQQ__Primary__c = true;
            cpqQuote.SBQQ__StartDate__c = Date.today();
            cpqQuote.SBQQ__Status__c = 'Draft';
            cpqQuote.SBQQ__Account__c = accId;
            cpqQuote.SBQQ__Opportunity2__c = oppoId;
            cpqQuote.SBQQ__PrimaryContact__c = conId;
            cpqQuote.Preferred_Payment_Date__c = '7';
            cpqQuote.SBQQ__PriceBook__c = priceId;
            cpqQuote.Initial_Payment_Date__c = Date.today();
        return cpqQuote;
    }
    
    public static SBQQ__Quote__c getQuotes(Id oppoId,Id accId,Id conId,Id priceId){
            SBQQ__Quote__c cpqQuote = getQuotesNoDML(oppoId, accId, conId, priceId);
            insert cpqQuote;
        return cpqQuote;
    }

    public static List<SBQQ__QuoteLineGroup__c> getQuoteLine(Id cpqQuoteId){
        List<SBQQ__QuoteLineGroup__c> quoteGroup = new List<SBQQ__QuoteLineGroup__c>();
            SBQQ__QuoteLineGroup__c groupName1 = new SBQQ__QuoteLineGroup__c();
            groupName1.Name = 'Group 1';
            groupName1.SBQQ__Quote__c = cpqQuoteId;
            quoteGroup.add(groupName1);
            SBQQ__QuoteLineGroup__c groupName2 = new SBQQ__QuoteLineGroup__c();
            groupName2.Name = 'Option 1';
            groupName2.SBQQ__Quote__c = cpqQuoteId;
            groupName2.SBQQ__SubscriptionTerm__c = 300;
            quoteGroup.add(groupName2);
        if(!quoteGroup.isEmpty()){
            insert quoteGroup;
        }
        return quoteGroup;
    }

    public static List<SBQQ__QuoteLine__c> getQuoteLines(Id quoteId,Id prodId,Id groupId){
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineUpList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLineGroup__c> groupNames = getQuoteLine(quoteId);
        List<Product2> prods = getProducts('BS 10012 - Additional Company - Certification','Consultancy - Contract');
            SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
            quoteLine1.SBQQ__Product__c = prodId;
            quoteLine1.SBQQ__Quote__c = quoteId;
            quoteLine1.SBQQ__Quantity__c = 2;
            quoteLine1.FOC_Period__c = 'Start';
            quoteLine1.SBQQ__StartDate__c = Date.newInstance(2019, 03, 10);
            quoteline1.Service_Start_Date__c = Date.today();
            quoteline1.SBQQ__Group__c = groupNames[1].Id;
            quoteLine1.Billing_Frequency__c = 'Annual';
            quoteLine1.SBQQ__BillingFrequency__c = 'Monthly';
            quoteLine1.SBQQ__RequiredBy__c = null;
            quoteLine1.SBQQ__NetPrice__c = 600;
            quoteLine1.SBQQ__SubscriptionTerm__c = 60;
            quoteLine1.Sum_of_Children_Price_Per_Billing__c = 300;
            insert quoteLine1;
          /*  SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
            quoteLine2.SBQQ__Product__c = prodId;
            quoteLine2.SBQQ__Quote__c = quoteId;
            quoteLine2.SBQQ__Quantity__c = 2;
            quoteLine2.FOC_Period__c = 'Start';
            quoteLine2.SBQQ__StartDate__c = Date.newInstance(2019, 03, 10);
            quoteline2.Service_Start_Date__c = Date.today()+5;
            quoteline2.SBQQ__Group__c = groupNames[1].Id;
            quoteLine2.Billing_Frequency__c = 'Annual';
            quoteLine2.SBQQ__BillingFrequency__c = 'Monthly';
            quoteLine2.SBQQ__SpecialPrice__c = 0;
            quoteLine2.SBQQ__RequiredBy__c = quoteLine1.Id;
            quoteLine2.SBQQ__NetPrice__c = 300;
            quoteLine2.SBQQ__SubscriptionTerm__c = 60;
            insert quoteLine2; */
            quoteLineUpList.add(quoteLine1);
           // quoteLineUpList.add(quoteLine2);
        return quoteLineList;
    }
    
     public static List<Campaign> getCampaigns(Integer noOfCampaigns,String campName,String Description, Boolean doInsert){
        List<Campaign> campList = new List<Campaign>();
        for(Integer i=0; i<noOfCampaigns; i++){
            Campaign c = new Campaign();
            c.Name    = campName+' '+i;
            c.Description = Description;
            campList.add(c);
        }
        if(doInsert){
            insert campList;
        }
        return campList;
    }
    
     public static User createUser_Generic(String Profile_Name , String Role_Name , Boolean doInsert){
    	User usr = new User(
		     ProfileId = [SELECT Id FROM Profile WHERE Name = :Profile_Name].Id,
            	
		     LastName = 'last',
		     Email = 'tuser000@citation.co.uk',
		     Username = 'tuser000@citation.co.uk' + System.currentTimeMillis(),
		     CompanyName = 'TEST',
		     Title = 'title',
		     Alias = 'alias',
		     TimeZoneSidKey = 'Europe/London',
		     EmailEncodingKey = 'UTF-8',
		     LanguageLocaleKey = 'en_US',
		     LocaleSidKey = 'en_GB'
		);
         if(Role_Name != NULL && !String.isBlank(Role_Name)){
             ID urId = [select Id from UserRole where Name = :Role_Name].Id;
             if(urID != NULL){
             usr.UserRoleId =   urId; 
             }
         }
         
         if(doInsert){
             insert usr;
         }
        return usr;
    }
		
    
    public static SBQQ__Quote__c createCPQ_Quote_With_Group_and_QLIs(String qName)
    {
        SBQQ__Quote__c q = new SBQQ__Quote__c();		
		
		User salesRep = createUser_Generic('Citation Data Admin' , NULL, true);
		
		q.SBQQ__SalesRep__c = salesRep.Id;       
        insert q;        
        
        SBQQ__QuoteLineGroup__c qg = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = q.Id);
        qg.Name = 'Option 1';
        insert qg;
        
        product2 prod = [select id from product2 where name = :Bg_Constants.PRODUCT_EMPLOYMENT_LAW and sbqq__billingfrequency__C = 'One-Off'] ;
        
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c(sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0,SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1 ) ;
        insert ql ;
        
         SBQQ__Quoteline__c ql2 = new SBQQ__Quoteline__c(sbqq__requiredby__c = ql.id, sbqq__quote__c = q.id, sbqq__group__c = qg.id, sbqq__product__C = prod.id,SBQQ__Quantity__c = 1.0 , SBQQ__CustomerPrice__c = 10.0,SBQQ__SpecialPrice__c = 10.0, sbqq__subscriptionterm__c = 1,SBQQ__NetPrice__c=10.0) ;
        insert ql2 ;
        
        return q;            
      
    }
    
    public static List<Contract> getStandardContracts(){
        List<Contract> contractList = new List<Contract>();
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE Name='E-Commerce' LIMIT 1];
        Account accRec = new Account();
        accRec.Name = 'Citation Account';
        insert accRec;
        Contact contactRec = new Contact(LastName='Karthik',Email='karthikanupoju@citation.co.uk',AccountId=accRec.Id);
        insert contactRec;
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('E-Commerce').getRecordTypeId();
        for(Integer i=0;i==0;i++){
          Contract conRec = new Contract();
          conRec.RecordTypeId = recType[0].Id;
          conRec.Name = 'New Citation Contract';
          conRec.AccountId = accRec.Id;
          conRec.Status = 'Draft';
          conRec.Renewal_Type__c = 'Auto';
          conRec.Business_Type__c = 'New Business';
          conRec.StartDate = Date.today();
          conRec.ContractTerm = 15;
          conRec.FOC_Period_Mths__c = 20;
          conRec.FOC_Period_Mths_End__c = 10;
          conRec.Service_Type__c = 'Citation';
          conRec.Agreement_Type__c = 'Paper';
          conRec.CustomerSignedId = contactRec.Id;
          conRec.RecordTypeId=contractRecordTypeId;
          conRec.Ts_Cs_Version__c = null;
          contractList.add(conRec);
        }
        if(!contractList.isEmpty()){
            insert contractList;
        }
        return contractList;
    }
    
     public static List<Contract> getContracts(decimal noofcont){
        List<Contract> contractList = new List<Contract>();
       
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Client Relations Contract Record Type').getRecordTypeId();
          for(integer i=0;i<noofcont;i++){
                Contract conRec = new Contract();
                conRec.Name = 'New Citation Contract';
                conRec.Status = 'Draft';
                conRec.Renewal_Type__c = 'Auto';
                conRec.Business_Type__c = 'New Business';
                conRec.StartDate = Date.today();
                conRec.ContractTerm = 15;
                conRec.FOC_Period_Mths__c = 20;
                conRec.FOC_Period_Mths_End__c = 10;
                conRec.Service_Type__c = 'Citation';
                conRec.Agreement_Type__c = 'Paper';
                conRec.RecordTypeId=contractRecordTypeId;
                conRec.Ts_Cs_Version__c = null;
                contractList.add(conRec);
          }       
        
        return contractList;
    }
    

    public static Document getDocument(){
        Document doc = new Document();
        doc.Name  = 'E-Commerce Terms and Conditions';
        doc.Body = Blob.valueOf('E-Commerce Terms and Conditions');
        doc.ContentType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        doc.Description = 'This document is attached to a Contract record (When every the record is created).';
        doc.FolderId = [SELECT Id FROM Folder WHERE Type='Document' LIMIT 1].Id;
        insert doc;
        return doc;
    }
    
    public static EmailTemplate getEmailTemplate(){
        EmailTemplate eTemp = new EmailTemplate();
        eTemp.Name = 'Atlas UpSkill Purchase Confirmation';
        eTemp.FolderId = UserInfo.getUserId();
        eTemp.IsActive = true;
        eTemp.Subject = 'Atlas UpSkill Purchase Confirmation';
        eTemp.TemplateType = 'Text';
        eTemp.DeveloperName = 'Atlas_UpSkill';
        insert eTemp;
        return eTemp;
    }

    
    public static void buildCustomSettingsForDialListJobs(String jobname){
       
        Datetime now = system.now();
        now = now.addMinutes(1);
        String strSchedule = '00:00:' + now.hour() + ':' + now.minute() + ':' + now.second();   
        BatchApexController__c bac = new BatchApexController__c();
        bac.Name = jobname;
        bac.Batch_size__c = 200;
        bac.BatchFinalEmail__c = 'test@test.com';
        bac.CreateErrorRecord__c = false;
        bac.EmailCustomHandledExceptions__c = true;
        bac.EmailStandardExceptions__c = true;
        bac.queryfilter__c = 'LIMIT 200';
        bac.Schedule_Time__c = strSchedule;
        bac.singleRun__c = true;
  
        insert bac;
    }

    
    public static List<Automation_Configuration__c> createAutomationConfigurationRecords(){
        
        String listTypeRecTypeName = DataConstants.AUTOMATION_CONFIGURATION_LIST_TYPE_ASSIGNMENT_RECORD_TYPE;
        String toxicSic2007RecTypeName = DataConstants.AUTOMATION_CONFIGURATION_TOXIC_SIC_2007_CODE_RECORD_TYPE;
        String toxicSic2007_3RecTypeName = DataConstants.AUTOMATION_CONFIGURATION_TOXIC_SIC_2007_CODE_3_RECORD_TYPE;
        String sectorToExcludeRecTypeName = DataConstants.AUTOMATION_CONFIGURATION_FTECRIT_SECTOR_EXCLUSION_RECORD_TYPE; 
        String sectorToLimit = DataConstants.AUTOMATION_CONFIGURATION_FTECRIT_SECTOR_LIMITS_RECORD_TYPE; 
        String critBdmOveride = DataConstants.AUTOMATION_CONFIGURATION_FTECRIT_BDM_OVERRIDE_RECORD_TYPE; 
        String critDefaultThreshold = DataConstants.AUTOMATION_CONFIGURATION_FTECRIT_DAFAULT_THRESHOLD_RECORD_TYPE; 
        String basicCritSrcExclTypeName = DataConstants.AUTOMATION_CONFIGURATION_BASICCRIT_SOURCE_EXCLUSION_RECORD_TYPE;
        String basicCritOutcodeRecTypName = DataConstants.AUTOMATION_CONFIGURATION_BASICCRIT_OUTCODE_EXCLUSION_RECORD_TYPE;
        String basicCritDSExclTypName = DataConstants.AUTOMATION_CONFIGURATION_BASICCRIT_DS_EXCLUSION_RECORD_TYPE;
        
       	ID ListTypeRecordTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(ListTypeRecTypeName).getRecordTypeId();
        ID toxicSic2007RecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(toxicSic2007RecTypeName).getRecordTypeId();
        ID toxicSic2007_3RecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(toxicSic2007_3RecTypeName).getRecordTypeId();
        ID sectorToExcludeRecTypeId  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(sectorToExcludeRecTypeName).getRecordTypeId();
        ID sectorToLimitRecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(sectorToLimit).getRecordTypeId();
        ID critBdmOverideRecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(critBdmOveride).getRecordTypeId();
        ID critDefaultThresholdRecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(critDefaultThreshold).getRecordTypeId();
        ID basicCritSrcExclTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritSrcExclTypeName).getRecordTypeId();
        ID basicCritOutcodeRecTypID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritOutcodeRecTypName).getRecordTypeId();
        ID basicCritDSExclTypID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritDSExclTypName).getRecordTypeId();
        
        List<Automation_Configuration__c> sl = new List<Automation_Configuration__c>();
        
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = ListTypeRecordTypeID;
            ac.BDM__c = 'Waseem Test 1';
            ac.List_Type__c = 'List 1a';
            ac.Maximum_Prospects__c=3;
            sl.add(ac);
        } 
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = toxicSic2007RecTypeID;
            ac.SIC2007_Code__c = 'F';
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = toxicSic2007RecTypeID;
            ac.SIC2007_Code3__c = 9009;
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sectorToExcludeRecTypeId;
            ac.Citation_Sector__c = 'Education';
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sectorToLimitRecTypeID;
            ac.Citation_Sector__c = 'Care';
            ac.FT_Employees_Lower__c = 5;
            ac.FT_Employees_Higher__c = 100;
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = critBdmOverideRecTypeID;
            ac.BDM__c = 'Waseem Test 2';
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = critDefaultThresholdRecTypeID;
            ac.FT_Employees_Lower__c = 5;
            ac.FT_Employees_Higher__c = 100;
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = critDefaultThresholdRecTypeID;
            ac.FT_Employees_Lower__c = 5;
            ac.FT_Employees_Higher__c = 100;
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = critBdmOverideRecTypeID;
            ac.BDM__c = 'Waseem Test 2';
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = basicCritSrcExclTypeID;
            ac.Source__c = 'HA Marketing';
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = basicCritOutcodeRecTypID;
            ac.Outcode__c = 'BT';
            sl.add(ac);
        }
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = basicCritDSExclTypID;
            ac.Data_Supplier__c = 'Test Supplier';
            sl.add(ac);
        }
        if(sl!=null && sl.size()>0 ){
            insert sl;
        }
        return sl;
    }
    
    public static List<SBQQ__Subscription__c> getSubscriptions(Integer numOfRec){
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        List<Account> acc = getAccounts(1,'Citation',true);
        List<Product2> pro = getProducts('Atlas UpSkill','Monthly Flat Phased - Contract');
        for(Integer i=0;i<numOfRec;i++){
            SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
            sub.SBQQ__Account__c = acc[0].Id;
            sub.SBQQ__Product__c = pro[0].Id;
            sub.SBQQ__Quantity__c = 1;
            subList.add(sub);
        }
        return subList;
    }
    
    public static List<Terms_and_Conditions__c> getTermsAndConditions(Integer numOfRec){
        List<Terms_and_Conditions__c> updatetc = new List<Terms_and_Conditions__c>();
        Terms_and_Conditions__c tc1 = new Terms_and_Conditions__c();
        tc1.Name = 'Version 1';
        tc1.Start_Date__c = Date.newInstance(2015, 08, 20);
        tc1.Agreement_Type__c = 'Paper';
        updatetc.add(tc1);
        Terms_and_Conditions__c tc2 = new Terms_and_Conditions__c();
        tc2.Name = 'Version 2';
        tc2.Start_Date__c = Date.newInstance(2018, 03, 09);
        tc2.End_Date__c = Date.newInstance(2019, 10, 10);
        updatetc.add(tc2);
        Terms_and_Conditions__c tc3 = new Terms_and_Conditions__c();
        tc3.Name = 'Version 3';
        tc3.Start_Date__c = Date.newInstance(2019, 10, 11);
        tc3.Agreement_Type__c = 'Auto; EchoSign; E-Commerce';
        updatetc.add(tc3);
        return updatetc;
    }

    public static List<Automation_Configuration__c> getSourceExclList(){
        Id sourceRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Source Exclusion').getRecordTypeId();
        List<Automation_Configuration__c> sl = new List<Automation_Configuration__c>();
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sourceRecTypeId;
            ac.Source__c = 'Lost';
            ac.Release_Field__c = 'ALL';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sourceRecTypeId;
            ac.Source__c = 'Existing';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '<';
            ac.Release_Threshold__c = '3';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sourceRecTypeId;
            ac.Source__c = 'Marketing Lost';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '>';
            ac.Release_Threshold__c = '1';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sourceRecTypeId;
            ac.Source__c = 'Won';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '=';
            ac.Release_Threshold__c = '2';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sourceRecTypeId;
            ac.Source__c = 'key';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '>=';
            ac.Release_Threshold__c = '2';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sourceRecTypeId;
            ac.Source__c = 'Industries';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '<=';
            ac.Release_Threshold__c = '2';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sourceRecTypeId;
            ac.Source__c = 'sector';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '<>';
            ac.Release_Threshold__c = '2';
            sl.add(ac);
        }
        if(sl.size()>0 && sl!=null){
            insert sl;
        }
        return sl;
    }

    public static List<Automation_Configuration__c> getSectorExclList(){
        Id sectorRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Sector Exclusion').getRecordTypeId();
        List<Automation_Configuration__c> sl = new List<Automation_Configuration__c>();
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sectorRecTypeId;
            ac.Data_Supplier__c = 'ALL';
            ac.Citation_Sector__c = 'EDUCATION';
            ac.Release_Field__c = 'ALL';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sectorRecTypeId;
            ac.Data_Supplier__c = 'keysector';
            ac.Citation_Sector__c = 'DAY NURSERY';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '>';
            ac.Release_Threshold__c = '4';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = sectorRecTypeId;
            ac.Data_Supplier__c = 'ML_Sweep';
            ac.Citation_Sector__c = 'ALL';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '<';
            ac.Release_Threshold__c = '3';
            sl.add(ac);
        }
        if(sl.size()>0 && sl!=null){
            insert sl;
        }
        return sl;
    }

    public static List<Automation_Configuration__c> getPostalCodeExclList(){
        Id outcodeRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL Outcode Exclusion').getRecordTypeId();
        List<Automation_Configuration__c> sl = new List<Automation_Configuration__c>();
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = outcodeRecTypeId;
            ac.Outcode__c = 'BT92';
            ac.Release_Field__c = 'ALL';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = outcodeRecTypeId;
            ac.Outcode__c = 'BT93';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '<';
            ac.Release_Threshold__c = '3';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = outcodeRecTypeId;
            ac.Outcode__c = 'BT94';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '>';
            ac.Release_Threshold__c = '1';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = outcodeRecTypeId;
            ac.Outcode__c = 'BT95';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '=';
            ac.Release_Threshold__c = '2';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = outcodeRecTypeId;
            ac.Outcode__c = 'BT96';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '>=';
            ac.Release_Threshold__c = '2';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = outcodeRecTypeId;
            ac.Outcode__c = 'BT97';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '<=';
            ac.Release_Threshold__c = '2';
            sl.add(ac);
        }
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = outcodeRecTypeId;
            ac.Outcode__c = 'BT98';
            ac.Release_Field__c = 'OutboundCallCount__c';
            ac.Release_Threshold_Operator__c = '<>';
            ac.Release_Threshold__c = '2';
            sl.add(ac);
        }
        if(sl.size()>0 && sl!=null){
            insert sl;
        }
        return sl;
    }

    public static List<Automation_Configuration__c> getBDMLimits(){
        Id bdmlimitsRecTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('DL BDM Limits').getRecordTypeId();
        List<Automation_Configuration__c> sl = new List<Automation_Configuration__c>();
        for(Integer i=1;i<=1;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = bdmlimitsRecTypeId;
            ac.BDM__c = 'Karthik Test';
            ac.List_Type__c = 'List 1a';
            ac.Maximum_Prospects__c=3;
            sl.add(ac);
        }
        if(sl.size()>0 && sl!=null){
            insert sl;
        }
        return sl;
    }
    
    public static List<Automation_Configuration__c> getListType(){
        Id listTypeId = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get('List Type Assignment').getRecordTypeId();
        List<Automation_Configuration__c> sl = new List<Automation_Configuration__c>();
        for(Integer i=1;i<=2;i++){
            Automation_Configuration__c ac = new Automation_Configuration__c();
            ac.RecordTypeId = listTypeId;
            ac.Citation_Sector__c = 'CARE';
            ac.List_Type__c = 'List 1a';
            sl.add(ac);
        }
        if(sl.size()>0 && sl!=null){
            insert sl;
        }
        return sl;
    }
}