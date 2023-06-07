public class triggerAutomationConfigurationHandler {
    
    public set<id> dialListformularecType = new Set<id>();
    
    public triggerAutomationConfigurationHandler(){     
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
        
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(ListTypeRecTypeName).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(toxicSic2007RecTypeName).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(toxicSic2007_3RecTypeName).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(sectorToExcludeRecTypeName).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(sectorToLimit).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(critBdmOveride).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(critDefaultThreshold).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritSrcExclTypeName).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritOutcodeRecTypName).getRecordTypeId());
        dialListformularecType.add(Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritDSExclTypName).getRecordTypeId());
    }
    
    public void handleinsertDeleteUndelete(List<Automation_Configuration__c> acList){
        Boolean scheduleapex = false;
        for(Automation_Configuration__c ac :acList){
            if(dialListformularecType != null && dialListformularecType.contains(ac.recordTypeid)){
               scheduleapex = true;
               continue;
            }
        }
        if(scheduleapex){
            scheduleApexJob.scheduleDialListCriteriaFieldsBatch('DialListCriteriaFieldsBatch');
        }
        
    }
    
    public void handleupdate(List<Automation_Configuration__c> acNewList, List<Automation_Configuration__c> acOldList, Map<id, Automation_Configuration__c> acNewMap, Map<id,Automation_Configuration__c> acOldMap){
        Boolean scheduleapex = false;
        for(Automation_Configuration__c ac :acNewList){
            Automation_Configuration__c oldAc = acOldMap.get(ac.id);
            if(dialListformularecType != null && dialListformularecType.contains(ac.recordTypeid) &&
              ( (ac.RecordTypeId != oldAc.RecordTypeId) || (ac.Citation_Sector__c != oldAc.Citation_Sector__c) || 
               (ac.List_Type__c != oldAc.List_Type__c) || (ac.SIC2007_Code3__c != oldAc.SIC2007_Code3__c) ||
               (ac.SIC2007_Code__c != oldAc.SIC2007_Code__c) || (ac.FT_Employees_Lower__c != oldAc.FT_Employees_Lower__c) ||
               (ac.FT_Employees_Higher__c != oldAc.FT_Employees_Higher__c) || (ac.BDM__c != oldAc.BDM__c) ||
               (ac.Source__c != oldAc.Source__c) || (ac.Outcode__c != oldAc.Outcode__c) ||(ac.Data_Supplier__c != oldAc.Data_Supplier__c))
              ){
                scheduleapex = true;
                continue;
            }
        }
        if(scheduleapex){
            scheduleApexJob.scheduleDialListCriteriaFieldsBatch('DialListCriteriaFieldsBatch');
        }
    }
	

}