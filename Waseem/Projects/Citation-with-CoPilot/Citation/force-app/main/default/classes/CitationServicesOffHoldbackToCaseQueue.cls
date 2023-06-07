public with sharing class CitationServicesOffHoldbackToCaseQueue {
    
    @InvocableMethod(label='OffHold Case Queue' description='This method OffHold back to Original Case Queue')
    public static void offHoldbacktoCaseQueue(List<ID> account) {
        
        //List<RecordType> caseReTypeId = [Select id from RecordType where sObjectType = 'Case' and DeveloperName IN ('S360_Atlas_Support','ELT_Advice_Generic','HS_Advice_Generic','Citation_Client_Operations','HR_CYJ','Citation_Contract_Admin','Citation_Common_Request','Reception_General','Reception_Team') ];
        Map<String, Id> myMap = new Map<String, Id>(); 
        List<Case> listbacktoCaseQueueId = new List<Case>();
        Set<Case> csset=new Set<Case>();
        List<Case> listbackfromset = new List<Case>();
        List<RecordType> caseRecTypeId;
        for(Group objCS : [Select DeveloperName, Id From Group where Type='Queue' and DeveloperName in ('Atlas_On_boarding_Support_Line_1','ELT_Advice','H_S_Advice','H_S_Admin','HR_CYJ','Contract_Admin','Field_Support','Reception_Team','On_Hold')])
        {
         myMap.put(objCS.DeveloperName, objCS.Id);
        }
        if(
            RecordType.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.RecordType.fields.Id.isAccessible() 
        ) {
            caseRecTypeId = [Select Id from RecordType where sObjectType = 'Case' and DeveloperName IN ('S360_Atlas_Support','ELT_Advice_Generic','HS_Advice_Generic','Citation_Client_Operations','HR_CYJ','Citation_Contract_Admin','Field_Support','Reception_General') ];
        }
                    
        For(Case cs: [SELECT Id,RecordTypeId,RecordTypeName__c,Status,PreviousOwnerId__c,OwnerId from Case where AccountId in :account and RecordTypeId in :caseRecTypeId and Status in ('In Progress','Awaiting Information','New Info Added','New')]){
         
             /* if((cs.RecordTypeName__c=='Atlas Support' 
                 || cs.RecordTypeName__c=='ELT Advice - Generic' || cs.RecordTypeName__c=='H&S Advice - Generic' || cs.RecordTypeName__c=='Citation Client Operations' || cs.RecordTypeName__c=='HR CYJ' || cs.RecordTypeName__c=='Citation Contract Admin' || cs.RecordTypeName__c=='Citation Common Request' || cs.RecordTypeName__c=='Reception General') && (cs.Status=='In Progress' || cs.Status=='Awaiting Information' || cs.Status=='New Info Added') && cs.PreviousOwnerId__c!=null)
             
                    {
                           System.debug('Test for PreviousOwnerId__c for Open Case ' +cs.PreviousOwnerId__c);
                           System.debug('Test for OwnerId for Open Case ' +cs.OwnerId);
                         
                           cs.OwnerId = cs.PreviousOwnerId__c;
                           listbacktoCaseQueueId.add(cs);
                           
                       }*/
                       listbacktoCaseQueueId = getListsCase( listbacktoCaseQueueId , cs,myMap);
                       listbacktoCaseQueueId = getListsCaseagain( listbacktoCaseQueueId , cs,myMap);
             }
        
         try{
            if (listbacktoCaseQueueId.size()>0 && Case.sObjectType.getDescribe().isUpdateable())
            {
                csset.addAll(listbacktoCaseQueueId);
                listbackfromset.addAll(csset);
                update listbackfromset;
              
            }
            
        }Catch(Exception ex)
        {
            System.debug('Record updated unsuccessfully' +ex.getMessage());            
        }
            
    }
 
 Static List<Case> getListsCase(List<Case> listbacktoCaseQueueId, Case cs,Map<String, Id> myMap )   
 {
    if(cs.RecordTypeName__c=='Atlas Support' &&  (cs.PreviousOwnerId__c==null || cs.PreviousOwnerId__c== myMap.get('On_Hold')))
    {
        cs.OwnerId = myMap.get('Atlas_On_boarding_Support_Line_1');
        listbacktoCaseQueueId.add(cs);
    }
    else if(cs.RecordTypeName__c=='ELT Advice - Generic' &&  (cs.PreviousOwnerId__c==null || cs.PreviousOwnerId__c== myMap.get('On_Hold')))
    {
        cs.OwnerId = myMap.get('ELT_Advice');
        listbacktoCaseQueueId.add(cs);  
    }
    else if(cs.RecordTypeName__c=='H&S Advice - Generic' &&  (cs.PreviousOwnerId__c==null || cs.PreviousOwnerId__c== myMap.get('On_Hold')))
    {
        cs.OwnerId = myMap.get('H_S_Advice');
        listbacktoCaseQueueId.add(cs);
    }
    else if(cs.RecordTypeName__c=='Citation Client Operations' &&  (cs.PreviousOwnerId__c==null || cs.PreviousOwnerId__c== myMap.get('On_Hold')))
    {
        cs.OwnerId = myMap.get('H_S_Admin');
        listbacktoCaseQueueId.add(cs);
    }
    return  listbacktoCaseQueueId;
 }

Static List<Case> getListsCaseagain(List<Case> listbacktoCaseQueueId, Case cs,Map<String, Id> myMap )   
 {
    if(cs.RecordTypeName__c=='HR-CYJ' &&  (cs.PreviousOwnerId__c==null || cs.PreviousOwnerId__c== myMap.get('On_Hold')))
    {
        cs.OwnerId = myMap.get('HR_CYJ');
        listbacktoCaseQueueId.add(cs);
    }
    else if(cs.RecordTypeName__c=='Citation Contract Admin' &&  (cs.PreviousOwnerId__c==null || cs.PreviousOwnerId__c== myMap.get('On_Hold')))
    {
        cs.OwnerId = myMap.get('Contract_Admin');
        listbacktoCaseQueueId.add(cs);
    }
    else if(cs.RecordTypeName__c=='Field Support' &&  (cs.PreviousOwnerId__c==null || cs.PreviousOwnerId__c== myMap.get('On_Hold')))
    {
        cs.OwnerId = myMap.get('Field_Support');
        listbacktoCaseQueueId.add(cs);
    }
    else if(cs.RecordTypeName__c=='Reception General' &&  (cs.PreviousOwnerId__c==null || cs.PreviousOwnerId__c== myMap.get('On_Hold')))
    {
        cs.OwnerId = myMap.get('Reception_Team');
        listbacktoCaseQueueId.add(cs);
    }
    
   /* if(cs.RecordTypeName__c=='Atlas Support'  
         || cs.RecordTypeName__c=='Citation Client Operations' || cs.RecordTypeName__c=='HR CYJ'
        || cs.RecordTypeName__c=='Citation Contract Admin' || cs.RecordTypeName__c=='Citation Common Request' 
         || cs.RecordTypeName__c=='Reception General' && cs.Status=='New' && cs.PreviousOwnerId__c!=null)*/
    else if(cs.PreviousOwnerId__c!=null && cs.PreviousOwnerId__c!=myMap.get('On_Hold'))
               {
                   System.debug('Test for PreviousOwnerId__c for new Case ' +cs.PreviousOwnerId__c);
                   System.debug('Test for OwnerId for new Case ' +cs.OwnerId);
                 
                   cs.OwnerId = cs.PreviousOwnerId__c;
                   listbacktoCaseQueueId.add(cs);
                   
               }
    return  listbacktoCaseQueueId;
 }


}