global with sharing class SMP_DirectDebitHelper{
    global static Map<Id, Income_Direct_Debit__c> getParentDirectDebitsFromHistories(List<Income_Debit_History__c> historiesMap)
    {
        System.debug('#### getParentDirectDebitsFromHistories');

        Set<Id> directDebitIds = new Set<Id>();

        for(Income_Debit_History__c history : historiesMap){
            directDebitIds.add(history.Income_Direct_Debit__c);
        }

        Map<Id, Income_Direct_Debit__c> directDebits = new Map<Id, Income_Direct_Debit__c>([SELECT Id, Account__c, Company__c, Default_Company_Direct_Debit__c, DD_Account_Email__c, DD_Status__c, DD_First_Collection_Date__c, DD_Last_Collected_Date__c, DD_Next_Collection_Date__c,
                                                                                                DD_Final_Collection_Amount__c, DD_First_Collection_Amount__c, DD_Ongoing_Collection_Amount__c
                                                                                            FROM Income_Direct_Debit__c
                                                                                            WHERE Id IN :directDebitIds]);

        return directDebits;
    }

    global static List<Income_Direct_Debit__c> getDirectDebitsByStatus(List<Income_Direct_Debit__c> directDebits, Map<Id, Income_Direct_Debit__c> oldDirectDebits, Set<String> statusSet)
    {
        System.debug('#### getDirectDebitsByStatus');
        System.debug('#### directDebits: ' + directDebits);
        System.debug('#### oldDirectDebits: ' + oldDirectDebits);
        System.debug('#### status: ' + statusSet);

        List<Income_Direct_Debit__c> collectionsList = new List<Income_Direct_Debit__c>();

        for(Income_Direct_Debit__c debits : directDebits)
        {
            for (String status : statusSet) 
            {
                if(String.isNotBlank(debits.DD_Status__c) && debits.DD_Status__c.contains(status) && (oldDirectDebits == null || oldDirectDebits.get(debits.Id) == null || debits.DD_Status__c != oldDirectDebits.get(debits.Id).DD_Status__c))
                {
                    collectionsList.add(debits);
                }
            }
        }

        System.debug('#### Returning: ' + collectionsList);
        return collectionsList;
    }

    global static List<Income_Debit_History__c> getNewInstructions(List<Income_Debit_History__c> newhistories, Map<Id, Income_Debit_History__c> oldDDHistories)
    {
        System.debug('#### getNewInstructions');
        System.debug('#### newhistories: '+newhistories);
        System.debug('#### oldDDHistories: '+oldDDHistories);

        Set<String> statusCollections = new Set<String>();
        statusCollections.add('New Instruction');

        return getHistoriesByStatus(newhistories, oldDDHistories, statusCollections);
    }
    
    global static List<Income_Debit_History__c> getNewInstructionsByStage(List<Income_Debit_History__c> newDDHistories, Map<Id, Income_Debit_History__c> oldDDHistories, Set<String> stageList)
    {
        System.debug('#### getNewInstructionsByStage');
        System.debug('#### newDDHistories: ' + newDDHistories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### stageList: ' + stageList);
        

        List<Income_Debit_History__c> newInstructionsList = getNewInstructions(newDDHistories, null);

        newInstructionsList = getHistoriesByStage(newInstructionsList, oldDDHistories, stageList);

        return newInstructionsList;
    }

    global static List<Income_Debit_History__c> getCollections(List<Income_Debit_History__c> histories, Map<Id, Income_Debit_History__c> oldDDHistories)
    {
        System.debug('#### getCollections');
        System.debug('#### histories: '+histories);

        Set<String> statusCollections = new Set<String>();
        statusCollections.add('First Collection');
        statusCollections.add('Ongoing Collection');
        statusCollections.add('Final Collection');
        statusCollections.add('First Represent');
        statusCollections.add('Second Represent');
        statusCollections.add('Third Represent');

        return getHistoriesByStatus(histories , oldDDHistories, statusCollections);
    }

    global static List<Income_Debit_History__c> getCollectionsByStage(List<Income_Debit_History__c> newDDHistories, Map<Id, Income_Debit_History__c> oldDDHistories, Set<String> stages)
    {
        System.debug('#### getCollectionsByStage');
        System.debug('#### newDDHistories: ' + newDDHistories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### stages: ' + stages);
        
        List<Income_Debit_History__c> collections = getCollections(newDDHistories, null);

        collections = getHistoriesByStage(collections, null, stages);

        System.debug('#### getCollectionsByStage Returning: ' + collections);

        return collections;
    }

    global static List<Income_Debit_History__c> getHistoriesByStage(List<Income_Debit_History__c> newDDHistories, Map<Id, Income_Debit_History__c> oldDDHistories, Set<String> stages)
    {
        System.debug('#### getHistoriesByStage');
        System.debug('#### newDDHistories: ' + newDDHistories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### stages: ' + stages);
        
        List<Income_Debit_History__c> collections = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : newDDHistories)
        {
            for (String stage : stages) 
            {
               if(String.isNotBlank(history.DD_Stage__c) && history.DD_Stage__c == stage && (oldDDHistories == null || oldDDHistories.get(history.Id) == null || oldDDHistories.get(history.Id).DD_Stage__c != stage))
                {
                    collections.add(history);
                }               
            }
        }

        System.debug('#### getHistoriesByStage Returning: ' + collections);

        return collections;
    }

    global static List<Income_Debit_History__c> getHistoriesByStatus(List<Income_Debit_History__c> histories, Map<Id, Income_Debit_History__c> oldDDHistories, Set<String> statusSet)
    {
        System.debug('#### getHistoriesByStatus');
        System.debug('#### histories: ' + histories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### status: ' + statusSet);

        List<Income_Debit_History__c> collectionsList = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : histories)
        {
            for (String status : statusSet) 
            {
                if(String.isNotBlank(history.DD_Status__c) && history.DD_Status__c.contains(status) && (oldDDHistories == null || oldDDHistories.get(history.Id) == null || history.DD_Status__c != oldDDHistories.get(history.Id).DD_Status__c))
                {
                    collectionsList.add(history);
                }
            }
        }

        System.debug('#### getHistoriesByStatus Returning: ' + collectionsList);
        return collectionsList;
    }    

    global static List<Income_Debit_History__c> getHistoriesByReasonCode(List<Income_Debit_History__c> histories, Map<Id, Income_Debit_History__c> oldDDHistories, Set<String> reasonCodes)
    {
        System.debug('#### getHistoriesByReasonCode');
        System.debug('#### histories: ' + histories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### reasonCodes: ' + reasonCodes);

        List<Income_Debit_History__c> collectionsList = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : histories)
        {
            for (String reasonCode : reasonCodes) 
            {     
                if(String.isNotBlank(history.DD_Code__c) && history.DD_Code__c.contains(reasonCode) 
                    && (oldDDHistories == null || oldDDHistories.get(history.Id) == null || history.DD_Code__c != oldDDHistories.get(history.Id).DD_Code__c))
                {
                    collectionsList.add(history);
                }
            }
        }

        return collectionsList;
    }

    global static List<Date> calculateDirectDebitSchedule(String numberOfCollections, Date startDate, String collectionDay, String collectionPeriod, String collectionStretch, String numberOfDaysToWaitFromNewInstruction)
    {
        System.debug('#### numberOfCollections ' + numberOfCollections);
        System.debug('#### startDate ' + startDate);
        System.debug('#### collectionDay ' + collectionDay);
        System.debug('#### collectionPeriod ' + collectionPeriod);
        System.debug('#### collectionStretch ' + collectionStretch);

        List<Date> scheduleDates = new List<Date>();
        
        if(String.isBlank(collectionStretch)){
            collectionStretch = '1';
        }

        Integer collectionStretchInt = Integer.ValueOf(collectionStretch);
        Integer noOfCollectionsInt = Integer.ValueOf(numberOfCollections);
        
        SMP_DDServiceHandler.SingleCollectionDateWrapper dateToSearch = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
        dateToSearch.CollectionDay = collectionDay;
        dateToSearch.StartDate = String.valueOf(startDate);
        dateToSearch.CollectionPeriod = collectionPeriod;
        dateToSearch.NumberOfDaysToWaitFromNewInstruction = numberOfDaysToWaitFromNewInstruction;
        SMP_DDServiceNextCollectionModel firstDirectDebitDate = SMP_DDServiceHandler.getNextCollectionDate(dateToSearch);
        Date firstCollectionDate = Date.valueOf(firstDirectDebitDate.CollectionDateResult.CollectionDate);
         
        scheduleDates.add(firstCollectionDate);

        if(noOfCollectionsInt > 1)
        {
            Date lastDateCalculated;
            
            if(collectionPeriod == 'Monthly')
            {
                lastDateCalculated = Date.newInstance(firstCollectionDate.Year(), firstCollectionDate.month(), Integer.valueOf(collectionDay));
            }
            else 
            {
                lastDateCalculated = firstCollectionDate;
            }            

            List<SMP_DDServiceHandler.SingleCollectionDateWrapper> dataListWrapper = new List<SMP_DDServiceHandler.SingleCollectionDateWrapper>();
            for(Integer i = 1; i < noOfCollectionsInt; i++)
            {        
                Date calculatedDate;   
                SMP_DDServiceHandler.SingleCollectionDateWrapper temp = new SMP_DDServiceHandler.SingleCollectionDateWrapper();

                if(collectionPeriod == 'Monthly')
                {
                    calculatedDate = lastDateCalculated.addMonths(collectionStretchInt);
                }
                else
                {                    
                    calculatedDate = lastDateCalculated.addDays(7 * collectionStretchInt);                    
                }

                temp.CollectionDay = collectionDay;
                temp.StartDate = String.valueOf(calculatedDate);
                temp.CollectionPeriod = collectionPeriod;
                temp.NumberOfDaysToWaitFromNewInstruction = numberOfDaysToWaitFromNewInstruction;

                lastDateCalculated = calculatedDate;

                System.debug('#### temp ' + temp);
                dataListWrapper.add(temp);
            }

            system.debug('#### dataListWrapper ' + dataListWrapper);

            SMP_DDServiceNextCollectionModelList response = SMP_DDServiceHandler.getNextCollectionDate(dataListWrapper);
            system.debug('#### response ' + response);

            for (SMP_DDServiceNextCollectionModelList.CollectionDatesResult result : response.CollectionDatesResult) 
            {
                scheduleDates.add(Date.valueOf(result.CollectionDate));
            }
        }   
        
        System.debug('#### scheduleDates ' + scheduleDates);

        return scheduleDates;
    }
}