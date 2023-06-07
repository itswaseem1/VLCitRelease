public class DialListCriteriaFieldsHelper {
    //get lead owner name
        private static String listTypeRecTypeName = DataConstants.AUTOMATION_CONFIGURATION_LIST_TYPE_ASSIGNMENT_RECORD_TYPE;
        private static String toxicSic2007RecTypeName = DataConstants.AUTOMATION_CONFIGURATION_TOXIC_SIC_2007_CODE_RECORD_TYPE;
        private static String toxicSic2007_3RecTypeName = DataConstants.AUTOMATION_CONFIGURATION_TOXIC_SIC_2007_CODE_3_RECORD_TYPE;
        private static String sectorToExcludeRecTypeName = DataConstants.AUTOMATION_CONFIGURATION_FTECRIT_SECTOR_EXCLUSION_RECORD_TYPE; 
        private static String sectorToLimit = DataConstants.AUTOMATION_CONFIGURATION_FTECRIT_SECTOR_LIMITS_RECORD_TYPE; 
        private static String critBdmOveride = DataConstants.AUTOMATION_CONFIGURATION_FTECRIT_BDM_OVERRIDE_RECORD_TYPE; 
        private static String critDefaultThreshold = DataConstants.AUTOMATION_CONFIGURATION_FTECRIT_DAFAULT_THRESHOLD_RECORD_TYPE; 
        private static String basicCritSrcExclTypeName = DataConstants.AUTOMATION_CONFIGURATION_BASICCRIT_SOURCE_EXCLUSION_RECORD_TYPE;
        private static String basicCritOutcodeRecTypName = DataConstants.AUTOMATION_CONFIGURATION_BASICCRIT_OUTCODE_EXCLUSION_RECORD_TYPE;
        private static String basicCritDSExclTypName = DataConstants.AUTOMATION_CONFIGURATION_BASICCRIT_DS_EXCLUSION_RECORD_TYPE;
        private static String defaultCitationRecordTypeName = DataConstants.LEAD_DEFAULT_CITATION_RECORD_TYPE;
        //SDT-6992
        private static String basicCritProspectSrcRecordTypeName = DataConstants.AUTOMATION_CONFIGURATION_BASICCRIT_PROSPECT_SOURCE_EXCLUSION_RECORD_TYPE;
        private static String basicCritPartnerCCRecordTypeName = DataConstants.AUTOMATION_CONFIGURATION_BASICCRIT_PARTNER_CC_EXCLUSION_RECORD_TYPE;
        
        private static ID ListTypeRecordTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(ListTypeRecTypeName).getRecordTypeId();
        private static ID toxicSic2007RecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(toxicSic2007RecTypeName).getRecordTypeId();
        private static ID toxicSic2007_3RecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(toxicSic2007_3RecTypeName).getRecordTypeId();
        private static ID sectorToExcludeRecTypeId  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(sectorToExcludeRecTypeName).getRecordTypeId();
        private static ID sectorToLimitRecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(sectorToLimit).getRecordTypeId();
        private static ID critBdmOverideRecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(critBdmOveride).getRecordTypeId();
        private static ID critDefaultThresholdRecTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(critDefaultThreshold).getRecordTypeId();
        private static ID basicCritSrcExclTypeID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritSrcExclTypeName).getRecordTypeId();
        private static ID basicCritOutcodeRecTypID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritOutcodeRecTypName).getRecordTypeId();
        private static ID basicCritDSExclTypID  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritDSExclTypName).getRecordTypeId();
        private static ID defaultCitationRecordTypeId  = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(defaultCitationRecordTypeName).getRecordTypeId();
         //SDT-6992
        private static ID basicCritProspectSrcRecordTypeId  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritProspectSrcRecordTypeName).getRecordTypeId();
        private static ID basicCritPartnerCCRecordTypeId  = Schema.SObjectType.Automation_Configuration__c.getRecordTypeInfosByName().get(basicCritPartnerCCRecordTypeName).getRecordTypeId();
        
        public static Map<String,List<Automation_Configuration__c>> mapRecordTypeToAutomationConfig = new Map<String,List<Automation_Configuration__c>>();
        public static Map<id,Boolean> leadIdToToxicSIC = new Map<id,Boolean>();
        public static Map<id,String> ownerIdToName = new Map<id,String>();
        
        public Static void BuildData(){
            For(Automation_Configuration__c ac: [SELECT id, RecordTypeId, Citation_Sector__c, List_Type__c,SIC2007_Code3__c,SIC2007_Code__c,FT_Employees_Lower__c,FT_Employees_Higher__c,BDM__c,Source__c,Outcode__c,Data_Supplier__c,Partner_CC_Exclusion__c,Prospect_Source__c from Automation_Configuration__c]){
                String RecordType = String.Valueof(ac.RecordTypeId);
                if(mapRecordTypeToAutomationConfig.containsKey(RecordType)){
                    mapRecordTypeToAutomationConfig.get(RecordType).add(ac);
                }else{
                    List<Automation_Configuration__c> acList = new List<Automation_Configuration__c>();
                    acList.add(ac);
                    mapRecordTypeToAutomationConfig.put(RecordType,acList);
                }
            }
        }
        
        public Static void buildownerIdToNameMap(List<Lead> leads){
            set<id> ownerIDS = new set<id>();
            
            for(Lead l : leads){
                if(l.ownerID != NULL && String.valueof(l.ownerID).startswith('005')){
                    ownerIDS.add(l.ownerID);
                }
            }
            if(!ownerIDS.isEmpty()){
                for(user u : [SELECT Id, Name from User where id IN :ownerIDS]){
                    ownerIdToName.put(u.id,u.name);
                }
            }
        }
        public Static List<Lead> setDialListFields(List<Lead> Leads){
            List<Lead> updatedLeads = new List<Lead>();
            
            BuildData();
           
            Map<String, String> mapSectorToListType = new Map<String, String>();
            String listRecordType = String.valueOf(ListTypeRecordTypeID);
            Set<String> toxicSIC2007_values = new Set<String>();
            Set<Double> toxicSIC2007_3values = new Set<Double>();
            String toxicSic2007RecTypeIDvalue = String.valueOf(toxicSic2007RecTypeID);
            String toxicSic2007_3RecTypeIDvalue = String.valueOf(toxicSic2007_3RecTypeID);
            Set<String> excludedSector = new Set<String>();
            Map<String,String> limitSectors = new Map<String,String>();
            Map<String,Double> bdmOveride = new Map<String,Double>();
            Double defaultLT;
            Double defaultHT;
            Set<String> outcodes = new Set<String>();
            Set<String> sources = new Set<String>(); 
            Set<String> dataSuppliers = new Set<String>();
            //SDT-6992
            Set<String> prospectSource = new Set<String>();
            Set<String> partnerCC = new Set<String>();
            String leadpartnerCC='';
            
            if(mapRecordTypeToAutomationConfig.containsKey(listRecordType)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(listRecordType)){
                    if(ac.Citation_Sector__c != NULL){
                        mapSectorToListType.put(ac.Citation_Sector__c.toLowerCase(),ac.List_Type__c);
                    }
                }
            }
            
            if(mapRecordTypeToAutomationConfig.containsKey(toxicSic2007RecTypeIDvalue)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(toxicSic2007RecTypeIDvalue)){
                    if(ac.SIC2007_Code__c != NULL){
                        toxicSIC2007_values.add(ac.SIC2007_Code__c.toLowerCase());
                    }
                }
            }
            if(mapRecordTypeToAutomationConfig.containsKey(toxicSic2007_3RecTypeIDvalue)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(toxicSic2007_3RecTypeIDvalue)){
                    toxicSIC2007_3values.add(ac.SIC2007_Code3__c); 
                }
            }
            
            if(mapRecordTypeToAutomationConfig.containsKey(sectorToExcludeRecTypeId)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(sectorToExcludeRecTypeId)){
                    If(ac.Citation_Sector__c != null){
                        excludedSector.add(ac.Citation_Sector__c.toLowerCase());
                    }
                }
            }
            if(mapRecordTypeToAutomationConfig.containsKey(sectorToLimitRecTypeID)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(sectorToLimitRecTypeID)){
                    if(ac.Citation_Sector__c != NULL){
                        limitSectors.put(ac.Citation_Sector__c.toLowerCase(),ac.FT_Employees_Lower__c+':'+ac.FT_Employees_Higher__c);
                    }
                }
            }
            if(mapRecordTypeToAutomationConfig.containsKey(critBdmOverideRecTypeID)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(critBdmOverideRecTypeID)){
                    IF(ac.BDM__c != null){
                        bdmOveride.put(ac.BDM__c.toLowerCase(),ac.FT_Employees_Lower__c);
                    }
                }
            }
            if(mapRecordTypeToAutomationConfig.containsKey(critDefaultThresholdRecTypeID)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(critDefaultThresholdRecTypeID)){
                    defaultLT = ac.FT_Employees_Lower__c ;
                    defaultHT = ac.FT_Employees_Higher__c;
                }
            }
            if(mapRecordTypeToAutomationConfig.containsKey(basicCritSrcExclTypeID)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(basicCritSrcExclTypeID)){
                    if(ac.Source__c != NULL){
                        sources.add(ac.Source__c.toLowerCase());
                    }
                }
            }
            
            if(mapRecordTypeToAutomationConfig.containsKey(basicCritOutcodeRecTypID)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(basicCritOutcodeRecTypID)){
                    if(ac.Outcode__c != null){
                        outcodes.add(ac.Outcode__c.toLowerCase());
                    }
                }
            }
            
            if(mapRecordTypeToAutomationConfig.containsKey(basicCritDSExclTypID)){
                For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(basicCritDSExclTypID)){
                    if(ac.Data_Supplier__c != NULL){
                        dataSuppliers.add(ac.Data_Supplier__c.toLowerCase());
                    }
                }
            }
            // SDT-6992
         if(mapRecordTypeToAutomationConfig.containsKey(basicCritProspectSrcRecordTypeId)){
            For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(basicCritProspectSrcRecordTypeId)){
                if(ac.Prospect_Source__c != NULL){
                    prospectSource.add(ac.Prospect_Source__c.toLowerCase());
                }
            }
        }
        if(mapRecordTypeToAutomationConfig.containsKey(basicCritPartnerCCRecordTypeId)){
            For(Automation_Configuration__c ac: mapRecordTypeToAutomationConfig.get(basicCritPartnerCCRecordTypeId)){
                if(ac.Partner_CC_Exclusion__c != NULL){
                    partnerCC.add(ac.Partner_CC_Exclusion__c.toLowerCase());
                }
            }
        }
            
            For (Lead l : Leads){
                if(l.CitationSector__c != NULL && mapSectorToListType != NULL && mapSectorToListType.containskey(l.CitationSector__c.toLowerCase()) ){
                    l.List_Type_New__c = mapSectorToListType.get(l.CitationSector__c.toLowerCase());               
                }
                
                if(toxicSIC2007_values != NULL && l.SIC2007_Code__c != NULL && toxicSIC2007_values.contains(l.SIC2007_Code__c.toLowerCase()) 
                   || ( toxicSIC2007_3values != NULL && l.SIC2007_Code3__c  != NULL && toxicSIC2007_3values.contains(l.SIC2007_Code3__c))){
                       l.Toxic_SIC_New__c = True;    
                   }else{
                       l.Toxic_SIC_New__c = False; 
                   }
                l = FTECrit(l, toxicSIC2007_values ,toxicSIC2007_3values,excludedSector,limitSectors,bdmOveride,defaultLT,defaultHT);
                system.debug('toxicSIC2007_values+++'+toxicSIC2007_values);
                system.debug('toxicSIC2007_3values+++'+toxicSIC2007_3values);
                // SDT-6992
                if(l.Partner_CC_Exclusion__c)
                {
                   leadpartnerCC ='True';
                }else{
                   leadpartnerCC='False';
                }
                if(l.status == 'Open' 
                   && l.IsTPS__c  != 'Yes' 
                   && l.RecordTypeId == defaultCitationRecordTypeId 
                   && l.Phone != ''
                   && l.Phone != NULL
                   && ( l.SIC2007_Code__c == NULL || toxicSIC2007_values == NULL || !toxicSIC2007_values.contains(l.SIC2007_Code__c.toLowerCase())) 
                       && ( l.SIC2007_Code3__c == null || toxicSIC2007_3values == null || !toxicSIC2007_3values.contains(l.SIC2007_Code3__c)) 
                   && (l.Assigned_BDC__c == NULL) 
                   && (l.BDC__c == NULL)){
                       l.Basic_Crit_New__c = true;
                       system.debug('I have been set here first');
                       if(l.Source__c != NULL && !sources.isEmpty() && sources.contains(l.Source__c.toLowerCase()) 
                          || l.OutCode__c != NULL && !outcodes.isEmpty() && outcodes.contains(l.OutCode__c.toLowerCase()) 
                          || l.Data_Supplier__c != NULL && !dataSuppliers.isEmpty() && dataSuppliers.contains(l.Data_Supplier__c.toLowerCase())
                          || l.Partner_CC_Exclusion__c !=NULL && !partnerCC.isEmpty() && partnerCC.contains(leadpartnerCC.toLowerCase())                          
                          || l.LeadSource !=NULL && !prospectSource.isEmpty() && prospectSource.contains(l.LeadSource.toLowerCase())){
                           l.Basic_Crit_New__c = false;
                           system.debug('Im changed here second time');
                       }
                       else if(l.OutCode__c == NULL || l.OutCode__c == ''){
                        l.Basic_Crit_New__c = false;
                       } else {
                           Boolean skip = false;
                           if(l.Source__c != NULL){
                               for(String source : sources){
                                   if(l.Source__c.containsIgnoreCase(source)){ 
                                       l.Basic_Crit_New__c = false;
                                       skip = true;
                                       continue;
                                   }
                               }
                           }
                           if(!skip  && l.OutCode__c != NULL){
                               for(String outcode : outcodes){
                                   if(l.OutCode__c.containsIgnoreCase(outcode)){
                                       l.Basic_Crit_New__c = false;
                                       skip = true;
                                       continue;
                                   } 
                               }
                           }
                           if(!skip && l.Data_Supplier__c != NULL){
                               for(String datasupplier : dataSuppliers){
                                   if(l.Data_Supplier__c.containsIgnoreCase(datasupplier)){
                                       l.Basic_Crit_New__c = false;
                                       continue;
                                   } 
                               }
                           }
                          if(!skip && leadpartnerCC != NULL){
                                  for(String partnerCCs : partnerCC){
                                      if(leadpartnerCC.toLowerCase() ==partnerCCs.toLowerCase()){
                                          l.Basic_Crit_New__c = false;
                                          continue;
                                      } 
                                  }
                              }
                           if(!skip && l.LeadSource != NULL){
                                  for(String prospectSources : prospectSource){
                                      if(l.LeadSource.toLowerCase() ==prospectSources.toLowerCase()){
                                          l.Basic_Crit_New__c = false;
                                          continue;
                                      } 
                                  }
                              }
                       }
                   } else{
                       system.debug('Poorly Im inside of this');
                       l.Basic_Crit_New__c = false;
                   }
            }
            return Leads;
        }
        
    
        public static Lead FTECrit(Lead l , Set<String> toxicSIC2007_values ,Set<Double> toxicSIC2007_3values,Set<String> excludedSector, Map<String,String> limitSectors, Map<String,Double> bdmOveride,Double defaultLT,Double defaultHT){
    
            if((toxicSIC2007_values != NULL && l.SIC2007_Code__c != NULL && toxicSIC2007_values.contains(l.SIC2007_Code__c.toLowerCase()) 
                   || ( toxicSIC2007_3values != NULL && l.SIC2007_Code3__c  != NULL && toxicSIC2007_3values.contains(l.SIC2007_Code3__c)))
               || (l.CitationSector__c != NULL && excludedSector.contains(l.CitationSector__c.toLowerCase()))){
                   l.FTE_Crit_New__c = False;
                   return l;
               }
            if(limitSectors != NULL && l.CitationSector__c != NULL && limitSectors.containskey(l.CitationSector__c.toLowerCase())){
                List<String> limits = limitSectors.get(l.CitationSector__c.toLowerCase()).split(':');
                if(limits != NULL && (limits[0] == NULL || l.FT_Employees__c >= Double.valueof(limits[0])) && (limits[1] == NULL || l.FT_Employees__c <= Double.valueof(limits[1]))){
                    L.FTE_Crit_New__c = TRUE; 
                    return l;
                }
            }
            system.debug('Lead Owner Name map'+bdmOveride);
            if(bdmOveride != NULL && l.Ownerid != null && ( (!(l.Owner.name == NULL) && bdmOveride.containskey(l.Owner.name.toLowerCase())) 
                                                           || (!(ownerIdToName == null ) && ownerIdToName.containskey(l.Ownerid)  && bdmOveride.containskey(ownerIdToName.get(l.Ownerid).toLowerCase()))))
            {
                Double lowLimit;
                
               if(ownerIdToName != null && ownerIdToName.containsKey(l.Ownerid)){
                    if(bdmOveride.get(ownerIdToName.get(l.ownerid).toLowerCase()) != NULL){
                        lowLimit = bdmOveride.get(ownerIdToName.get(l.ownerid).toLowerCase());
                    }
                }
                else if(bdmOveride.containsKey(l.owner.name.toLowerCase())){
                    lowLimit = bdmOveride.get(l.owner.name.toLowerCase());
                }
                if(!(l.FT_Employees__c == NULL)){
                    if( ((lowLimit == NULL) || (lowLimit <= l.FT_Employees__c)) && ((defaultHT == NULL) ||(defaultHT >= l.FT_Employees__c)) ){
                        system.debug('lowLimit---'+lowLimit);
                        L.FTE_Crit_New__c = TRUE;
                        return l;
                    }
                }
            }
            if(!(l.FT_Employees__c == NULL) && (defaultLT == NULL || defaultLT <= l.FT_Employees__c) 
               &&   (defaultHT == NULL || defaultHT >= l.FT_Employees__c) ){
                   L.FTE_Crit_New__c = TRUE;
                   return l;
               }
            l.FTE_Crit_New__c = FALSE;
            return l;
        }
    }