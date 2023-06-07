public with sharing class PartnerMemberUploadBatch implements Database.Batchable<SObject>, Schedulable,Database.stateful {
    Set<Id> pmrIdSet = new Set<Id>();
    Set<Id> partnerAccIdSet = new Set<Id>();
    Set<Id> activeClientPmrIdSet = new Set<Id>();
    Map<Id,Integer> hrAccessMap = new Map<Id,Integer>();
    Map<Id,Integer> hsAccessMap = new Map<Id,Integer>();
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name,Assign_How_to_Access_Units__c,CitationSector__c, City__c,Company_Registration_Number__c, Date_Joined_Partner__c,Email__c,First_Name__c,FT_Employees__c,Last_Name__c,Member_id__c,Member_Company_Name__c,Mobile__c,Partner__c,Phone__c,Postcode__c,Salutation__c,	Street__c,Website__c,Partner__r.Name,Email_Domain__c,Branch_Bad_Company_Bad_Domain__c FROM Partner_Member_Upload__c where Is_Processed__c=false';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Partner_Member_Upload__c> pmuList) {
        List<Partner_Member_Upload__c> partList=new List<Partner_Member_Upload__c>();
        Map<Id, Set<Id>> leadRecordMap=new  Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accteRecordMap=new  Map<Id, Set<Id>>();
        Map<Id, Set<Id>> contRecordMap=new  Map<Id, Set<Id>>();
        Map<Id, Lead> leadIdMap = new Map<Id, Lead>();
        Map<Id, Account> accIdMap = new Map<Id, Account>();
        Map<Id, Contact> conIdMap = new Map<Id, Contact>();
        List<Id> leadIdList = new List<Id>();
        List<Id> accIdList = new List<Id>();
        List<Id> conIdList = new List<Id>();
        Partner_Member_Relationship__c pmrObj;
        List<Lead> leadListToUpdate = new List<Lead>();
        List<Lead> leadListToinsert = new List<Lead>();
        //Set<Id> noProspectPmuIdSet = new Set<Id>();
        Set<Id> dupProspectIdSet = new Set<Id>();
        Lead createLeadObj;
        Set<Id> accIdWithOppSet = new Set<Id>();
        Map<Id,Id> accIdWithLatestClosedOppIdMap = new Map<Id,Id>();
        Set<Id> excludeContractPMUIdSet = new Set<Id>();
        Map<Id,Id> pmuIdLeadIdMap = new Map<Id,Id>();
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        List<Partner_Member_Relationship__c> pmrList = new List<Partner_Member_Relationship__c>();
        for(Partner_Member_Upload__c pmuobj: pmuList){ 
            partList.add(pmuobj);
            for (Datacloud.FindDuplicatesResult findDupeResult : Datacloud.FindDuplicates.findDuplicates(partList)) {
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        if(!matchResult.getMatchRecords().isEmpty()){
                            for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {                               
                                String ids=String.valueOf(matchRecord.getRecord().Id);
                                if(ids.startsWithIgnoreCase('001')){
                                    if(!accteRecordMap.containsKey(pmuobj.Id)){
                                        accteRecordMap.put(pmuobj.Id,new set<Id>{matchRecord.getRecord().Id});
                                    }else{
                                        accteRecordMap.get(pmuobj.Id).add(matchRecord.getRecord().Id);
                                    }
                                }
                                if(ids.startsWithIgnoreCase('003')){
                                    if(!contRecordMap.containsKey(pmuobj.Id)){
                                        contRecordMap.put(pmuobj.Id,new Set<Id>{matchRecord.getRecord().Id});
                                    }else{
                                        contRecordMap.get(pmuobj.Id).add(matchRecord.getRecord().Id);
                                    }                                       
                                }
                                if(ids.startsWithIgnoreCase('00Q')){
                                    if(!leadRecordMap.containsKey(pmuobj.Id)){
                                        leadRecordMap.put(pmuobj.Id,new Set<Id>{matchRecord.getRecord().Id});
                                    }else{
                                        leadRecordMap.get(pmuobj.Id).add(matchRecord.getRecord().Id);
                                    }                                        
                                }                                  
                            } 
                        }
                    }
                }
            }
            partList.clear();
        }            
        System.debug('Acc records : ' +accteRecordMap);
        System.debug('contact records : ' +contRecordMap);
        System.debug('lead records : ' +leadRecordMap);
        for(Set<Id> objId:leadRecordMap.values()){
            leadIdList.addAll(objId);
        }
        for(Set<Id> objId:accteRecordMap.values()){
            accIdList.addAll(objId);
        }
        for(Set<Id> objId:contRecordMap.values()){
            conIdList.addAll(objId);
        }
        if(!conIdList.isEmpty()){
            conIdMap.putAll([SELECT Id,AccountId FROM Contact WHERE Id=:conIdList AND AccountId!=null]); 
            for(Contact objCon: conIdMap.values()){
                accIdList.add(objCon.AccountId);
            }
        }
        if(!leadIdList.isEmpty()){
            leadIdMap.putAll([SELECT Id,Status FROM Lead WHERE Id=:leadIdList AND (RecordType.Name='Default Citation Record Type' OR RecordType.Name='Citation Cross Sell' OR RecordType.Name='Citation Employee Referral Record' OR RecordType.Name='Citation Referral Record' OR RecordType.Name='Citation Partner Referral' OR RecordType.Name='Citation Winback Client' OR RecordType.Name='Citation Upsell Client')]);
        }
        if(!accIdList.isEmpty()){
            accIdMap.putAll([SELECT Id FROM Account WHERE Id=:accIdList AND CoreCitationContractMonths__c!=0 AND CoreCitationContractMonths__c!=NULL]);
            for(Opportunity oppObj: [SELECT Id,AccountId,Originating_Closed_Lost_Opportunity_id__c,StageName FROM Opportunity WHERE AccountId=:accIdList AND (RecordType.Name='Default Citation Opportunity' OR RecordType.Name='Renewal / Retention Opportunity - Auto' OR RecordType.Name='Renewal / Retention Opportunity - Non-Auto' OR RecordType.Name='ELAS Renewal / Retention Opportunity - Non-Auto') order by CreatedDate DESC]) {
                if(oppObj.StageName!='Closed Won' && oppObj.StageName!='Closed Lost' && oppObj.StageName!='Lost BDC' && oppObj.StageName!='Closed won (Consolidated)'){
                    accIdWithOppSet.add(oppObj.AccountId); 
                }
                if(!accIdWithLatestClosedOppIdMap.containsKey(oppObj.AccountId) && (oppObj.StageName=='Closed Lost' || oppObj.StageName=='Lost BDC')){
                    accIdWithLatestClosedOppIdMap.put(oppObj.AccountId, oppObj.Id);
                }
            }
        }
        system.debug('accIdMap----'+accIdMap);
        system.debug('accIdWithLatestClosedOppIdMap---'+accIdWithLatestClosedOppIdMap+'----'+accIdWithOppSet);
        for(Partner_Member_Upload__c pmuobj: pmuList){ 
            pmrObj = new Partner_Member_Relationship__c();
            Lead objLead = new Lead();
            pmrObj.Partner__c = pmuobj.Partner__c;
            pmrObj.Partner_Member_Upload_Id__c = pmuobj.Id;
            pmrObj.Member_joined_Partner_date__c = pmuobj.Date_Joined_Partner__c;
            pmrObj.How_To_Hub_Access__c = pmuobj.Assign_How_to_Access_Units__c;
            pmrObj.Member_Id__c = pmuobj.Member_id__c;
            if(accteRecordMap.containsKey(pmuobj.Id)){
                system.debug('1 Account');
                for(Id objId: accteRecordMap.get(pmuobj.Id)){
                    if(accIdMap.containsKey(objId)){
                        pmrObj.Member__c = accIdMap.get(objId).Id;
                        excludeContractPMUIdSet.add(pmuobj.Id);
                        break;
                    }
                }
            }
            if(pmrObj.Member__c==null && contRecordMap.containsKey(pmuobj.Id)){
                 system.debug('1 Contact');
                 for(Id objId: contRecordMap.get(pmuobj.Id)){
                    if(conIdMap.containsKey(objId) && accIdMap.containsKey(conIdMap.get(objId).AccountId)){
                        pmrObj.Member__c = conIdMap.get(objId).AccountId;
                        excludeContractPMUIdSet.add(pmuobj.Id);
                        break;
                    }
                }
            }
            if(pmrObj.Member__c==null && accteRecordMap.containsKey(pmuobj.Id)){
                system.debug('1.1 Account');
                for(Id objId: accteRecordMap.get(pmuobj.Id)){
                    if(accIdWithOppSet.contains(objId)){
                        pmrObj.Member__c = objId;
                        excludeContractPMUIdSet.add(pmuobj.Id);
                        break;
                    }
                }
            }
            if(pmrObj.Member__c==null && contRecordMap.containsKey(pmuobj.Id)){
                system.debug('1.1 Contact');
                for(Id objId: contRecordMap.get(pmuobj.Id)){
                    if(conIdMap.containsKey(objId) && accIdWithOppSet.contains(conIdMap.get(objId).AccountId)){
                        pmrObj.Member__c = conIdMap.get(objId).AccountId;
                        excludeContractPMUIdSet.add(pmuobj.Id);
                        break;
                    }
                }
            }
            if(pmrObj.Member__c ==null && (accteRecordMap.containsKey(pmuobj.Id) || contRecordMap.containsKey(pmuobj.Id))){
                Opportunity opp = new Opportunity();
                if(accteRecordMap.containsKey(pmuobj.Id) ){
                    system.debug('1.2 Account');
                    for(Id objId: accteRecordMap.get(pmuobj.Id)){
                        if(accIdWithLatestClosedOppIdMap.containsKey(objId)){
                            opp.Id = accIdWithLatestClosedOppIdMap.get(objId);
                            opp.affinity_Partner__c = objId;
                            pmrObj.Member__c = objId;
                            break;
                        }
                    }
                    if(leadRecordMap.containsKey(pmuobj.Id) && pmrObj.Member__c!=null){
                        for(Id objId: leadRecordMap.get(pmuobj.Id)){
                            if(leadIdMap.containsKey(objId)){
                                pmrObj.Member_Lead__c = leadIdMap.get(objId).Id;
                                objLead.Id = leadIdMap.get(objId).Id;
                                objLead = PartnerMemberUploadBatchHelper.updateLeadInstance(pmuobj, ObjLead,leadIdMap.get(objId));
                                break;
                            }
                        }
                    }
                }else if(contRecordMap.containsKey(pmuobj.Id)){
                    system.debug('1.2 Contact');
                    for(Id objId: contRecordMap.get(pmuobj.Id)){
                        if(conIdMap.containsKey(objId) && accIdWithLatestClosedOppIdMap.containsKey(conIdMap.get(objId).AccountId)){
                            opp.Id = accIdWithLatestClosedOppIdMap.get(conIdMap.get(objId).AccountId);
                            opp.affinity_Partner__c = conIdMap.get(objId).AccountId;
                            pmrObj.Member__c = conIdMap.get(objId).AccountId;
                            break;
                        }
                    }
                    if(leadRecordMap.containsKey(pmuobj.Id) && pmrObj.Member__c!=null){
                        for(Id objId: leadRecordMap.get(pmuobj.Id)){
                            if(leadIdMap.containsKey(objId)){
                                pmrObj.Member_Lead__c = leadIdMap.get(objId).Id;
                                objLead.Id = leadIdMap.get(objId).Id;
                                objLead = PartnerMemberUploadBatchHelper.updateLeadInstance(pmuobj, ObjLead,leadIdMap.get(objId));
                                break;
                            }
                        }
                    }
                }
                if(opp.Id!=null && objLead.Id==null && pmrObj.Member__c!=null){
                    System.debug('1.3 No Prospect, Closed lost');
                    oppListToUpdate.add(opp);
                }
            }
            if(pmrObj.Member__c==null && leadRecordMap.containsKey(pmuobj.Id)){
                system.debug('2');
                objLead.Session_Notes__c = 'Member of '+pmuobj.Partner__r.Name;
                objLead.Partner_CC_Exclusion__c = pmuobj.Branch_Bad_Company_Bad_Domain__c;
                objLead.How_To_Hub_Member__c = pmuobj.Assign_How_to_Access_Units__c;
                for(Id objId: leadRecordMap.get(pmuobj.Id)){
                    if(leadIdMap.containsKey(objId)){
                        if(leadIdMap.get(objId).Status =='Callback Requested' || leadIdMap.get(objId).Status =='Data Quality' || leadIdMap.get(objId).Status =='Pended' || leadIdMap.get(objId).Status =='Rejected' || leadIdMap.get(objId).Status == 'Approved' || leadIdMap.get(objId).Status == 'Reappointment Required'){
                            pmrObj.Member_Lead__c = leadIdMap.get(objId).Id;
                            objLead.Id = leadIdMap.get(objId).Id;
                            break;
                        }
                    }
                }
                if(pmrObj.Member_Lead__c==null){
                    system.debug('3,4');
                    objLead.Affinity_Partner__c = pmuObj.Partner__c;
                    objLead.LeadSource = 'Partnership';
                    for(Id objId: leadRecordMap.get(pmuobj.Id)){
                        if(leadIdMap.containsKey(objId)){
                            if(leadIdMap.get(objId).Status =='Open'){
                                system.debug('3 open');
                                pmrObj.Member_Lead__c = leadIdMap.get(objId).Id;
                                objLead.Id = leadIdMap.get(objId).Id;
                                break;
                            }
                        }
                    }
                    if(pmrObj.Member_Lead__c==null){
                        for(Id objId: leadRecordMap.get(pmuobj.Id)){
                            if(leadIdMap.containsKey(objId)){
                                if((leadIdMap.get(objId).Status =='Closed' || leadIdMap.get(objId).Status =='Suspended' )){
                                    system.debug('4 Closed,Suspended');
                                    pmrObj.Member_Lead__c = leadIdMap.get(objId).Id;
                                    objLead.Id = leadIdMap.get(objId).Id;
                                    if(pmuObj.Assign_How_to_Access_Units__c){
                                        objLead.Status = 'Open';
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            if(pmrObj.Member__c ==null && pmrObj.Member_Lead__c==null && objLead.Id==null){
                system.debug('6');
                //noProspectPmuIdSet.add(pmuobj.Id);
                leadListToinsert.add(PartnerMemberUploadBatchHelper.createLeadInstance(pmuobj,false));
            }
            if(objLead.Id!=null && !dupProspectIdSet.contains(objLead.Id)){
                leadListToUpdate.add(objLead);
                dupProspectIdSet.add(objLead.Id);
            }
            pmuobj.Is_Processed__c = true;
            pmrList.add(pmrObj);
        }
        system.debug('pmrList---'+pmrList+'----'+leadListToUpdate);
        if(!leadListToUpdate.isEmpty()){
            Database.update(leadListToUpdate,false);
        }
        system.debug('leadListToinsert---'+leadListToinsert);
        if(!leadListToinsert.isEmpty()){
            Database.insert(leadListToinsert,false);
        }
        system.debug('oppListToUpdate---'+oppListToUpdate);
        if(!oppListToUpdate.isEmpty()){
            Database.update(oppListToUpdate);
        }
        for(Lead obj:leadListToinsert){
            pmuIdLeadIdMap.put(obj.Partner_Member_Upload_Id__c, obj.Id);
        }
        system.debug('pmuIdLeadIdMap----'+pmuIdLeadIdMap);
        for(Partner_Member_Relationship__c objPMR: pmrList){
            if(pmuIdLeadIdMap.containsKey(objPMR.Partner_Member_Upload_Id__c)) {
                objPMR.Member_Lead__c = pmuIdLeadIdMap.get(objPMR.Partner_Member_Upload_Id__c);
            } 
        }
        system.debug('final pmrList---'+pmrList);
        if(!pmrList.isEmpty()){
            Database.insert(pmrList,false);
        }
        system.debug('pmrList aftr insert'+pmrList);
        Database.update(pmuList,false);
        for(Partner_Member_Relationship__c objPMR :pmrList){
            if(objPMR.How_To_Hub_Access__c && !excludeContractPMUIdSet.contains(objPMR.Partner_Member_Upload_Id__c)){
                pmrIdSet.add(objPMR.Id);
                if(!partnerAccIdSet.contains(objPMR.Partner__c)){
                    partnerAccIdSet.add(objPMR.Partner__c); 
                }
            }
            if(objPMR.How_To_Hub_Access__c && excludeContractPMUIdSet.contains(objPMR.Partner_Member_Upload_Id__c)){
                activeClientPmrIdSet.add(objPMR.Id);
            }
        }
    }
    public void finish(Database.BatchableContext BC){    
        system.debug('In finish Method===='+pmrIdSet);
        if(!pmrIdSet.isEmpty()){
            system.debug('Create Contract');
            for(Account objAcc: [SELECT Id,Available_H_S_Member_Atlas_Access_Units__c,Available_HR_Member_Atlas_Access_Units__c FROM Account WHERE Id=:partnerAccIdSet AND Is_Active_Partner__c=TRUE]){
                if(objAcc.Available_HR_Member_Atlas_Access_Units__c!=null && objAcc.Available_HR_Member_Atlas_Access_Units__c!=0){
                    hrAccessMap.put(objAcc.Id, Integer.valueOf(objAcc.Available_HR_Member_Atlas_Access_Units__c));
                }
                if(objAcc.Available_H_S_Member_Atlas_Access_Units__c!=null && objAcc.Available_H_S_Member_Atlas_Access_Units__c!=0){
                    hsAccessMap.put(objAcc.Id, Integer.valueOf(objAcc.Available_H_S_Member_Atlas_Access_Units__c));  
                }
            }
			Database.executeBatch(new PartnerMemberContractCreationBatch(pmrIdSet,hrAccessMap,hsAccessMap),Integer.valueOf(System.Label.PartnerMemberContractCreationBatchSize));
        }
        if(!activeClientPmrIdSet.isEmpty()){
            system.debug('PartnerMember Upload Batch email');
            PartnerMemberUploadBatchHelper.failureEmailNotification(activeClientPmrIdSet, true);
        }
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new PartnerMemberUploadBatch(),Integer.valueOf(System.Label.PartnerMemberUploadBatchSize));
    }
}