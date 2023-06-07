@isTest //(seeAllData = true)

public class TestFactory {

    public static Account createAccount ( String sector, String postalCode, Decimal fullTimeEmployees, Decimal partTimeEmployees){
        Account acc = new Account(
                                  Name = 'TestCitation',
                                  Industry = sector,
                                  NumberOfEmployees = 10,
                                  Phone = '09876543210',
                                  Type = 'Client',
                                  AnnualRevenue = 50000,
                                  BillingPostalCode =postalCode,
                                  CitationSector__c = sector,
                                  FT_Employees__c = fullTimeEmployees,
                                  PT_Employees__c = partTimeEmployees
                                  );
        return acc;
    }
    
    public static Contact createContact (Id accountId){
        Contact con = new Contact(
                                  AccountId = accountId,
                                  LastName = 'TestLName',
                                  FirstName = 'TestFName',
                                  Phone = '111111111',
                                  Email = 'test@test.com'
                                 );
                                 
        return con;   
    }
    

    public static Opportunity createOpportunity(string opportunityName, string setStageName, string recordtype, Account acc) {
        
        bg_RecordTypeMap opportunityRecordTypeMap = new bg_RecordTypeMap('Opportunity');         
        Opportunity opp = new Opportunity();
        opp.Name = opportunityName;
        if (recordtype == 'Default Citation Opportunity') {
            opp.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Default Citation Opportunity'); 
        } 
        else if(recordtype == 'Renewal / Retention Opportunity - Auto'){
            opp.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Renewal / Retention Opportunity - Auto');
        }
        else if(recordtype == 'Renewal / Retention Opportunity - Non-Auto'){
            opp.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('Renewal / Retention Opportunity - Non-Auto');
        }
        else if(recordtype == 'QMS'){
            opp.RecordTypeId =  opportunityRecordTypeMap.getIdFromName('QMS');
        }
        
        opp.AccountId = acc.id;
        opp.Name = opportunityName;
        opp.Type = 'New Business';
        opp.CloseDate = system.now().addMonths(1).date();
        opp.Deal_Type__c = 'Combined';
        opp.StageName = setStageName;
        
        return opp;
    }

    public static Product2 createProduct (String category, String type, String service){
        Product2 prod = new Product2(
                                    Name = category,
                                    Family = type,
                                    Service_Type__c = service
                                    );
                                 
        return prod;   
    }

    public static SBQQ__Quote__c createQuote(Id accId, Id oppId, Id contractID, Id recTyId ){
        
        
        SBQQ__Quote__c SBQQq = new SBQQ__Quote__c();
        SBQQq.sbqq__account__c = accId;
        SBQQq.SBQQ__Opportunity2__c = oppId;
        SBQQq.contract__c = contractID;
        SBQQq.recordtypeid = recTyId;
        
        return SBQQq;            
    }

    public static Pricebook2 createPricebook(String i, Decimal maximum, Decimal minimum){

        return new Pricebook2(
                                Name = 'test ' + i,
                                Annual_Turnover_Maximum__c = maximum,
                                Annual_Turnover_Minimum__c = minimum,
                                Term__c = '5',
                                isActive = true
                            );
    }

    public static Pricebook2 createPricebook(String i, Decimal maximum, Decimal minimum, String termValue){

        return new Pricebook2(
                                Name = 'test ' + i,
                                Annual_Turnover_Maximum__c = maximum,
                                Annual_Turnover_Minimum__c = minimum,
                                Term__c = termValue,
                                isActive = true
                            );
    }
    
    public static Contract createContract (Id accountId, Id RecTypeName, String RenewType, Integer ContTerm, Id signContactId){

        Contract cont = new Contract(AccountID = accountId,
                                    Name = 'Test Contract Citation',
                                    RecordTypeId = RecTypeName,
                                    Renewal_Type__c = RenewType,
                                    StartDate = Date.today().addMonths(15), 
                                    FOC_Period_Mths__c =2,
                                    FOC_Period_Mths_End__c=0,
                                    CustomerSignedId = signContactId,
                                    ContractTerm = ContTerm
                                    );
                                 
        return cont;   
    }

    public static User createUserRec (string userprofieName){
        
        Profile p = [SELECT Id FROM Profile WHERE Name=: userprofieName]; 
         
        
        User createURec = new User( Alias = 'testD',
                                    Email = 'testuser25@citation.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'user',
                                    LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US',
                                    ProfileId = p.Id,
                                    TimeZoneSidKey = 'GMT',
                                    UserName='testuser25@citation.com'
                                   );
        return createURec ;   
    }



    public static Cluster__C createCluster (String ClusterName, String prefixPostCodes, String userLastName ){

        user u = [select id, name, LastName from User Where usertype = 'Standard' and isActive = true limit 1];
        Cluster__C cls = new Cluster__C(Name = ClusterName,
                                        Owner__c = u.Id,
                                        Region__c='North West',
                                        Cluster_Prefix_Postcodes__c = prefixPostCodes
                                        );
                                 
        return cls;   
    }
    
    public static Cluster__C createClusterWithRole (String ClusterName, String prefixPostCodes, String userLastName , String Role){

        user u = [select id, name, LastName from User Where usertype = 'Standard' and isActive = true limit 1];
        Cluster__C cls = new Cluster__C(Name = ClusterName,
                                        Owner__c = u.Id,
                                        Region__c='North West',
                                        Cluster_Prefix_Postcodes__c = prefixPostCodes,
                                        Role__c = Role
                                        );
                                 
        return cls;   
    }


    Public static SBQQ__QuoteTemplate__c createTemplate(){
        SBQQ__QuoteTemplate__c SBQQt = new SBQQ__QuoteTemplate__c();
    
        return SBQQt;    
    }

    public static Case createCase (Id recTypeId, Id accountId, Id contactId){
        Case caseRec = new Case(RecordTypeId = recTypeId,
                                AccountId = accountId,
                                ContactId = contactId,
                                Status = 'New',
                                Subject = 'Test Case',
                                Description = 'Test Case'
                               );
                                 
        return caseRec;   
    }

    public static Case createCaseWithEmail (Id recTypeId, Id accountId, Id contactId ,string suppliedEmail){
        Case caseRec = new Case(RecordTypeId = recTypeId,
                                AccountId = accountId,
                                ContactId = contactId,
                                Status = 'New',
                                SuppliedEmail = suppliedEmail,
                                Subject = 'Test Case',
                                Description = 'Test Case'
                               );
                                 
        return caseRec;   
    }
    
    
    public static Task createTask (Id taskRecordTypeId){
        Task t = new Task();
        t.Subject = 'task test';
        t.Description = 'task test';
        t.Priority = 'Normal';
        t.Status = 'In Progress';
        t.ActivityDate = Date.Today();
        t.RecordTypeId = taskRecordTypeId;
        return t;
    }
    
    public static User createUserRec (){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Citation Relationship Exec']; 
         
        
        User createURec = new User(
                                        Alias = 'testD',
                                        Email = 'testuser25@citation.com',
                                        EmailEncodingKey = 'UTF-8',
                                        LastName = 'user',
                                        LanguageLocaleKey = 'en_US',
                                        LocaleSidKey = 'en_US',
                                        ProfileId = p.Id,
                                        TimeZoneSidKey = 'GMT',
                                        UserName='testuser25@citation.com'
                                   );
        return createURec ;   
    }
    
}