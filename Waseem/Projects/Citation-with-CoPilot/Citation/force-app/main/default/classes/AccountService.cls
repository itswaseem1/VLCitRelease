public inherited sharing class AccountService extends DefaultService implements IAccountService
{
    /*
    *   This implementation of the service will require a selector to handle loading
    *   records that it will need to perform its job.
    */
    public interface ISelector
    {
        Id getRecordTypeId(SObjectType objType, String devName);

        /*
        *   Return tasks that are related to cases for the given account, where the case recordtype
        *   is one of the ones indicated. The task recordtype should be Service_360_Default
        *   @return tasks mapped by ACCOUNT id.
        */
        Map<Id, List<Task>> getTasksWithCaseRecordTypes(List<Account> accounts, List<Id> caseRecordtypes);

        /*
        *   Return a list of fields we want to track history of for an Account
        */
        Set<String> getFieldsForHistoryTracking();

        /*
        *   Load up account information for any accounts, out of the set provided,
        *   that are due a partnership call.  The ids provided may not all require
        *   one.
        */
        List<Account> getAccountsDueForPartnershipCall(Set<Id> accountIds);
        /*
        *   Get all the asscoiated Contacts of an Account
        */
        Map<Id,List<Contact>> getAccountRelatedContacts(List<Account> accounts);
        /*
         *   Get all the asscoiated Service Delivery Plan Records of an Account
         */
        List<Service_Delivery_Plan__c> getAccountswithServiceDeliveryPlan(Set<Id> accountIds);
    }

    /*
    *   Our selector that we were provided by what ever created us.
    */
    private ISelector selector;

    public AccountService(ISelector selector) 
    {
        this.selector = selector;
    }

	/*
    *   see IDomainService
    */
    public override void setDefaults(List<SObject> newRecords)
    {
        new CaptureiHASCOClient((List<Account>)newRecords, NULL).process();
    }
    
    /*
    *   see IDomainService
    */
    public override void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        new CaptureOldRenewalDate(newRecords, oldRecords).process();
        new CaptureiHASCOClient((List<Account>)newRecords, (Map<Id,Account>)oldRecords).process();
        new SetHasCoreContractOrOpp(newRecords).process();
    }

    /*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnNew(List<SObject> newRecords)
    {
        List<Account> newAccounts = (List<Account>)newRecords;

        createAccountantProspect(newAccounts, null);
    }

    /*
    *   see IDomainService
    */
    public override void processRelatedRecordsOnChange(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        List<Account> newAccounts = (List<Account>)newRecords;
        Map<Id, Account> oldAccounts = (Map<Id, Account>)oldRecords;

        updateRelatedTasksSegmentation(newAccounts, oldAccounts);
        createAccountHistory(newAccounts, oldAccounts);
        createAccountantProspect(newAccounts, oldAccounts);
        setOpenCoreOpportunityOnContact(newAccounts, oldAccounts);
        updateRelatedServiceDeliveryPlanName(newAccounts, oldAccounts);
    }

    /*
    *   See IAccountService
    */
    public void createPartnershipCall(Set<Id> ids)
    {
        new PartnershipCall(ids, selector).process();
    }

    /*
    *   Will update the tasks to show the segmentation of the accounts.
    */
    private void updateRelatedTasksSegmentation(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
    {
        new TaskSegmentation(newAccounts, oldObjectsMap, selector).process();
    }

    /*
    *   will create some custom field tracking records.  Distinct from standard SF field tracking
    */
    private void createAccountHistory(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
    {
        new AccountHistory(newAccounts, oldObjectsMap, selector).process();
    }
    
    /*
    *   Will check whether to create a new prospect based on presence of an accountant on the account record.
    */
    private void createAccountantProspect(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
    {
        new AccountantProspect(newAccounts, oldObjectsMap, selector).process();
    }
    
    /*
    *   Will update open Core Opportunity on the Related Contacts
    */
    private void setOpenCoreOpportunityOnContact(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
    {
        new SetOpenCoreOppOnContact(newAccounts, oldObjectsMap, selector).process();
    }
    
    /*
     * @date 28-12-2022
     * @description Updates the Name of the Sevice Delivery Plan Records whenever Name of the account associated with it is Updated
     * @param No Parameters
     * @return Void(Returns Nothing)
     */
    private void updateRelatedServiceDeliveryPlanName(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
    {
        new ServiceDeliveryPlanName(newAccounts, oldObjectsMap, selector).process();
    }

    public class AccountServiceSelector extends RecordTypeSelector implements AccountService.ISelector
    {
        /*
        *   Return tasks that are related to cases for the given account, where the case recordtype
        *   is one of the ones indicated. The task recordtype should be Service_360_Default
        *   @return tasks mapped by ACCOUNT id.
        */
        public Map<Id, List<Task>> getTasksWithCaseRecordTypes(List<Account> accounts, List<Id> caseRecordtypes)
        {
            // there is no easy way of doing this without going through loading the related cases first.
            // the tasks reference them by whatid and you cannot cross join by that. AccountId may be useful,
            // however, that is not guaranteed to be set to the account of the case annoyingly.

            Map<Id, List<Task>> returnMap = new Map<Id, List<Task>>();
            for(Account act: accounts)
            {
                returnMap.put(act.Id, new List<Task>());
            }

            Map<Id, Case> caseMap = getCases(accounts, caseRecordtypes);

            if(caseMap.isEmpty())
                return returnMap;

            List<Task> tasks = getTasks(caseMap);

            if(tasks.isEmpty())
                return returnMap;

            for(Task task: tasks)
            {
                Case relatedCase = caseMap.get(task.whatId);
                List<Task> taskList = returnMap.get(relatedCase.accountId);
                taskList.add(task);
            }

            return returnMap;
        }

        private Map<Id, Case> getCases(List<Account> accounts, List<Id> caseRecordtypes)
        {
            Set<Id> actIds = new Map<Id, Account>(accounts).keySet();
            List<Case> cases = [SELECT ID, accountId
                                    FROM Case 
                                    WHERE accountId IN :actIds 
                                        AND RecordTypeId IN :caseRecordtypes];

            return new Map<Id, Case>(cases);
        }

        private List<Task> getTasks(Map<Id, Case> caseMap)
        {
            Set<ID> caseIds = caseMap.keySet();

            Id recordType = super.getRecordTypeId(Task.SObjectType, 'Service_360_Default');

            List<Task> tasks = [SELECT Id, whatId 
                                FROM Task 
                                WHERE whatId in :caseIds 
                                    AND RecordTypeId = :recordType];
            return tasks;
        }

        public Set<String> getFieldsForHistoryTracking()
        {
            Set<String> standardFieldNames = new Set<String>{'BillingCity','BillingCountry','BillingPostalCode','BillingState','BillingStreet','Name','Owner','Phone','ShippingCity','ShippingCountry','ShippingPostalCode','ShippingState','ShippingStreet','Type'};

            List<Account_History_Field__mdt> accountHistoryMDTypes = [SELECT DeveloperName 
                                                                        FROM Account_History_Field__mdt
                                                                        WHERE DeveloperName != :standardFieldNames];

            Set<String> fieldAPINames = new Set<String>();
            for(Account_History_Field__mdt metadata: accountHistoryMDTypes)
            {
                fieldAPINames.add(metadata.DeveloperName + '__c');
            }

            return fieldAPINames;
        }

        public List<Account> getAccountsDueForPartnershipCall(Set<Id> accountIds)
        {
            Date referenceDate = Date.today().addDays(-30);
            return [SELECT ID, BDC_del__c
                    FROM Account 
                    WHERE Id IN :accountIds 
                        AND LastParternshipCheckIn__c <= :referenceDate];
        }
        
        public Map<Id,List<Contact>> getAccountRelatedContacts(List<Account> accounts){
            Map<Id, List<Contact>> accountIdContactsListMap = new Map<Id, List<Contact>>();
            for(Contact objCon: [SELECT Id,AccountId,Open_Core_Opportunities__c FROM Contact WHERE AccountId=: accounts]){
                if(accountIdContactsListMap.containsKey(objCon.AccountId)){
                    accountIdContactsListMap.get(objCon.AccountId).add(objCon);
                }else{
                    accountIdContactsListMap.put(objCon.AccountId, new List<Contact>{objCon});
                }
            }
            return accountIdContactsListMap;
        }
        /*
         * @date 28-12-2022
         * @description Fetches and returns the ServiceDeliveryPlans related to an Account that Starts With Citation SDP
         * @param Unique Account Ids
         * @return List of ServiceDeliveryPlan Records
         */
        public List<Service_Delivery_Plan__c> getAccountswithServiceDeliveryPlan(Set<Id> accountIds){
           return [SELECT Id, Account__c, Account__r.Name, Name FROM Service_Delivery_Plan__c WHERE Account__c IN : accountIds AND Name Like 'Citation SDP %'];
        }
    }

    class AccountantProspect
    {
        private List<Account> accountsToProcess;
        private ISelector selector;

        AccountantProspect(List<Account> newAccounts, Map<Id, Account> oldObjectsMap, ISelector selector)
        {
            this.accountsToProcess = findAccountsToProcess(newAccounts, oldObjectsMap);
            this.selector = selector;
        }

        private List<Account> findAccountsToProcess(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
        {
            List<Account> accountWithChange = new List<Account>();

            for(Account newAccount: newAccounts)
            {
                if(newAccount.Accountant_Name__c != null)
                {
                    // insert || update with field changed from null
                    if( oldObjectsMap == null || 
                        oldObjectsMap.get(newAccount.Id).Accountant_Name__c == null)
                    {
                        accountWithChange.add(newAccount);
                    }
                }
            }

            return accountWithChange;
        }

        void process()
        {
            List<Lead> prospects = new List<Lead>();

            Id recordType = selector.getRecordTypeId(Lead.SObjectType, 'Default_Citation_Record_Type');

            for(Account act: accountsToProcess)
            {
                Lead prospect = new Lead(
                    LastName = act.Accountant_Name__c,
                    Company =act.Accountant_company__c,
                    City = act.Accountant_city__c,
                    Email = act.Accountant_Email__c,
                    Phone = act.Accountant_Phone_number__c,
                    PostalCode = act.Accountant_Post_Code__c,
                    Referred_By_Company_lookup__c = act.Id,
                    State = act.Accountant_county__c, 
                    Street = act.Accountant_street__c,
                    Status = 'Open',
                    PartnerType__c = 'Potential Introducer',
                    RecordTypeID = recordType
                );

                prospects.add(prospect);
            }

            if(prospects.size() > 0)
            {
                // create unit of work that treats all tasks as allow, irrespective of perms.
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.insertRecords(prospects);
            }
        }
    }

    class AccountHistory
    {
        private List<Account> newAccounts;
        private Map<Id, Account> oldObjectsMap;
        private ISelector selector;

        AccountHistory(List<Account> newAccounts, Map<Id, Account> oldObjectsMap, ISelector selector)
        {
            this.newAccounts = newAccounts;
            this.oldObjectsMap = oldObjectsMap;
            this.selector = selector;
        }

        /*
        *   Some custom history tracking, we create a custom history object for certain fields
        *   changing, which is based on custom metadata.
        */  
        void process()
        {
            Set<String> fieldAPINames = selector.getFieldsForHistoryTracking();
            
            List<Account_History__c> acctHistoryList = new List<Account_History__c>();
            for(Account acct: newAccounts)
            {
                Account oldAccount = oldObjectsMap.get(acct.Id);
                List<Account_History__c> histories = createHistoryForAccount(acct, oldAccount, fieldAPINames);
                acctHistoryList.addAll(histories);
            }

            if(!acctHistoryList.isEmpty())
            {
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.insertRecords(acctHistoryList);
            }
        }

        private List<Account_History__c> createHistoryForAccount(Account newAccount, Account oldAccount, Set<String> fieldAPINames )
        {
            List<Account_History__c> historyList = new List<Account_History__c>();
            Datetime nowTime = System.now();
            Object newValue;
            Object oldValue;

            for(String sfield : fieldAPINames)
            {
                newValue = newAccount.get(sfield);
                oldValue = oldAccount.get(sfield);

                if(newValue != oldValue)
                {
                    // as it is less likely we will be in here we only go to get the describe data now.
                    // This means we 'might' repeat this, but it is cached internally so not too expensive.
                    // Saves time on all the account updates that do not need it.
                    String fieldName = Account.SObjectType.getDescribe().fields.getMap().get(sfield).getDescribe().getLabel();

                    Account_History__c ah = new Account_History__c();
                    ah.Account__c = newAccount.Id;
                    ah.Field_Name__c = fieldName;
                    ah.Modified_By__c = UserInfo.getUserId();
                    ah.Modified_Date_Time__c = nowTime;
                    ah.New_Value__c = String.valueOf(newValue);
                    ah.Old_Value__c = String.valueof(oldValue);

                    historyList.add(ah);
                }
            }

            return historyList;
        }
    }

    class TaskSegmentation
    {
        private List<Account> accountsToProcess;
        private ISelector selector;

        TaskSegmentation(List<Account> newAccounts, Map<Id, Account> oldAccounts, ISelector selector)
        {
            this.accountsToProcess = getSegmentationChanged(newAccounts, oldAccounts);
            this.selector = selector;
        }

        private List<Account> getSegmentationChanged(List<Account> newAccounts, Map<Id, Account> oldAccounts)
        {
            List<Account> changed = new List<Account>();
            
            for(Account act: newAccounts)
            {
                Account oldAct = oldAccounts.get(act.Id);
                if(oldAct == null)
                    continue;
    
                if(act.Segmentation_Status__c != oldAct.Segmentation_Status__c)
                    changed.add(act);
            }
    
            return changed;
        }
    
        /*
        *   Updates the segmentation status of tasks for certain types of cases, so 
        *   they are in sync with the account.
        *   NB there could be a lot of tasks, so be careful refactorig this.
        */
        void process()
        {
            List<Account> accounts = accountsToProcess;
    
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(selector.getRecordTypeId(Case.SObjectType, 'ELT_Advice_Generic'));
            recordTypes.add(selector.getRecordTypeId(Case.SObjectType, 'HR_CYJ'));
    
            Map<Id, List<Task>> tasksToChange = selector.getTasksWithCaseRecordTypes(accounts, recordTypes);
    
            List<Task> updateList = new List<Task>();
            for(Account act: accounts)
            {
                List<Task> tasks = tasksToChange.get(act.Id);
                if(tasks == null || tasks.isEmpty())
                    continue;
                
                for(Task task: tasks)
                {
                    task.Segmentation_Status__c = act.S__c;
                }
                updateList.addAll(tasks);
            }
    
            if(updateList.size() > 0)
            {
                // create unit of work that treats all tasks as allow, irrespective of perms.
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.updateRecords(updateList);
            }            
        }
    }

    class PartnershipCall
    {
        private List<Account> accounts;
        private ID recordType;

        PartnershipCall(Set<Id> ids, ISelector selector)
        {
            this.accounts = selector.getAccountsDueForPartnershipCall(ids);
            this.recordtype = selector.getRecordTypeId(Task.SObjectType, 'Partnership_Task');
        }

        void process()
        {
            if(accounts == null || accounts.isEmpty())
                return;

            List<Task> taskCreated = new List<Task>();

            Date today = Date.today();
            Date activityDate = Date.today().addDays(7);

            for(Account act: accounts)
            {
                act.LastParternshipCheckIn__c = today;

                Task task = new Task(
                    ActivityDate = activityDate,
                    OwnerId = act.BDC_del__c,
                    Priority = 'Normal',
                    RecordTypeId = this.recordtype,
                    Snapshot__c = 'Task to remind to check in to see how introducing is going.',
                    Status = 'Not Started',
                    Subject = 'Introducer Check In',
                    WhatId = act.Id
                );

                taskCreated.add(task);
            }

            Savepoint sp = Database.setSavePoint();
            try
            {
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.updateRecords(accounts);
                uow.insertRecords(taskCreated);
            } 
            catch (Exception e)
            {
                Database.rollBack(sp);
                throw e;
            }
            
        }
    }

    class CaptureOldRenewalDate
    {
        private List<Account> newRecords;
        private Map<Id, Account> oldRecords;

        CaptureOldRenewalDate(List<SObject> newRecords, Map<Id, SObject> oldRecords)
        {
            this.newRecords = (List<Account>)newRecords;
            this.oldRecords = (Map<Id, Account>)oldRecords;
        }

        void process()
        {
            if(newRecords == null)
                return;

            for(Account act: newRecords)
            {
                Account oldAct = oldRecords.get(act.Id);

                if(oldAct == null)
                    continue;

                if(act.Renewal_Date__c != oldAct.Renewal_Date__c)
                    act.Old_Renewal_Date__c = oldAct.Renewal_Date__c;
            }
        }
    }

     class CaptureiHASCOClient
    {
        private List<Account> accountsToProcess;

        CaptureiHASCOClient(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
        {
            this.accountsToProcess = findAccountsToProcess(newAccounts, oldObjectsMap);
        }

        private List<Account> findAccountsToProcess(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
        {
            List<Account> accountWithChange = new List<Account>();

            for(Account newAccount: newAccounts)
            {
                if(newAccount.iHASCO_Account_Manager__c != null && !newAccount.iHASCO_Client__c)
                {
                    //Insert || update with field changed from null
                    if( oldObjectsMap == null || 
                        oldObjectsMap.get(newAccount.Id).iHASCO_Account_Manager__c == null)
                    {
                        accountWithChange.add(newAccount);
                    }
                }
            }

            return accountWithChange;
        }

        void process()
        {
            
            for(Account act: accountsToProcess)
            {
               act.iHASCO_Client__c = true ;
            }

        }
    }
    
    class SetHasCoreContractOrOpp
    {
        private List<Account> newRecords;

        SetHasCoreContractOrOpp(List<SObject> newRecords)
        {
            this.newRecords = (List<Account>)newRecords;
        }

        void process()
        {
            for(Account act: newRecords)
            {
                act.Open_Core_Opportunities__c = act.CoreCitationContractMonths__c > 0 || act.Number_of_Core_Opps__c > 0;
            }
        }
    }
    
    class SetOpenCoreOppOnContact
    {
        private List<Account> accountsToProcess;
        private ISelector selector;

        SetOpenCoreOppOnContact(List<Account> newAccounts, Map<Id, Account> oldObjectsMap, ISelector selector)
        {
            this.accountsToProcess = findAccountsToProcess(newAccounts, oldObjectsMap);
            this.selector = selector;
        }

        private List<Account> findAccountsToProcess(List<Account> newAccounts, Map<Id, Account> oldObjectsMap)
        {
            List<Account> filteredAccountList = new List<Account>();

            for(Account newAccount: newAccounts)
            {
                if(newAccount.Open_Core_Opportunities__c != oldObjectsMap.get(newAccount.Id).Open_Core_Opportunities__c)
                {
                    filteredAccountList.add(newAccount);
                }
            }
            return filteredAccountList;
        }

        void process()
        {
            if(accountsToProcess.isEmpty())
                return;
            
            Map<Id, List<Contact>> accIdContactListMap = selector.getAccountRelatedContacts(accountsToProcess);
    		
            List<Contact> updateContactList = new List<Contact>();
            for(Account objAct: accountsToProcess)
            {
                List<Contact> relatedContactsList = accIdContactListMap.get(objAct.Id);
                
                if(relatedContactsList != null && !relatedContactsList.isEmpty()){
                    for(Contact objCon: relatedContactsList)
                    {
                        String coreOpp = String.valueOf(objAct.Open_Core_Opportunities__c).capitalize();
                        if(objCon.Open_Core_Opportunities__c != coreOpp){
                            objCon.Open_Core_Opportunities__c = coreOpp;
                            updateContactList.add(objCon);
                        }
                    }
                }
            }
            
            if(!updateContactList.isEmpty())
            {
                IUnitOfWork uow = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                uow.updateRecords(updateContactList);
            }
        }
    }
    
    /*
     * @date 28-12-2022
     * @description This Class Updates the Name of the Sevice Delivery Plan Records whenever Name of the account associated with it is Updated
     */
    class ServiceDeliveryPlanName
    {
        private Set<Id> setofAccountIds;
        private ISelector selector;
        
        ServiceDeliveryPlanName(List<Account> newAccounts, Map<Id, Account> oldAccounts, ISelector selector)
        {
            this.setofAccountIds = getAccountswithNameUpdate(newAccounts, oldAccounts);
            this.selector = selector;
        }
        
        /*
         * @date 28-12-2022
         * @description This Method is Used to Filter the Accounts whose name is Updated
         * @param newAccounts-Accounts Updated,oldAccounts-Accounts Prior to Updation
         * @return set of Account Ids
         */
        private Set<Id> getAccountswithNameUpdate(List<Account> newAccounts, Map<Id, Account> oldAccounts)
        {
            Set<Id> filteredAccountIds = new Set<Id>();
            
            for(Account eachAccount: newAccounts)
            {
                Account eachOldAcccount = oldAccounts.get(eachAccount.Id);
                if(eachOldAcccount != null && eachAccount.Name != eachOldAcccount.Name){
                    filteredAccountIds.add(eachAccount.Id);
                }
            }
            
            return filteredAccountIds;
        }
        
        /*
         * @date 28-12-2022
         * @description Updates the Name of the Sevice Delivery Plan Records whenever Name of the account associated with it is Updated
         * @param No Parameters
         * @return Void(Returns Nothing) 
         */
        void process()
        {
            if(setofAccountIds.isEmpty())
            {
                return;
            }
            
            List<Service_Delivery_Plan__c> serviceDeliveryPlantobeUpdated = new List<Service_Delivery_Plan__c>();
            List<Service_Delivery_Plan__c> serviceDeliveryPlansToUpdate = selector.getAccountswithServiceDeliveryPlan(setofAccountIds);
            
            for(Service_Delivery_Plan__c serviceDeliveryPlanToUpdate: serviceDeliveryPlansToUpdate)
            {
                serviceDeliveryPlanToUpdate.Name = 'Citation SDP ' + serviceDeliveryPlanToUpdate.Account__r.Name;
                serviceDeliveryPlantobeUpdated.add(serviceDeliveryPlanToUpdate);
            }
            
            if(!serviceDeliveryPlantobeUpdated.isEmpty())
            {
                // create unit of work that treats all servicedeliveryplans as allow, irrespective of permissions.
                IUnitOfWork unitofWork = UnitOfWork.createInstance(new SecurityCheck.AllowAllSecurity());
                unitofWork.updateRecords(serviceDeliveryPlantobeUpdated);
            }          
        }
    }
}