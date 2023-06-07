public class LeadTriggerHandler{
    
    public static void processSector(list<lead> ldList, map<id,lead> oldMap) {
        User currentUser = [Select FirstName, Id from User where Id =: UserInfo.getUserId() limit 1];
        for(Lead objLead : ldList) {
            if(currentUser.FirstName != 'Salesforce' && currentUser.FirstName != 'Adobe' && ((oldMap == null && objLead.Sector__c != null) || (oldMap != null && !oldMap.isEmpty() && objLead.Sector__c != oldMap.get(objLead.Id).Sector__c))){
                objLead.SectorLastSubmittedBy__c = currentUser.Id;
            }          
            if(objLead.SectorRejected__c == true) {
                objLead.SectorRejected__c = false;
                objLead.Sector__c = objLead.CitationSector__c;
            }
            else if (objLead.SectorUpdate__c == true) {
                objLead.SectorUpdate__c = false;
                objLead.CitationSector__c = objLead.Sector__c;
            }
        }
    }
    
    public list<lead> checktoCallUpdateIndividual(list<lead> ldList,map<id,lead> oldMap){
        map<id,lead> maplead =new map<id,lead>();
        list<lead> finLead = new list<lead>();
        maplead = oldMap;
        for(lead ld: ldList){
            if(maplead.size()>0 && maplead.containsKey(ld.id)){
                
                if((ld.name != maplead.get(ld.id).name) || (ld.email!= maplead.get(ld.id).email) || (ld.recordtypeid!= maplead.get(ld.id).recordtypeid)){   
                    finLead.add(ld);
                }
                
            }
        }
        
        if(finLead.size() > 0){
            finLead = populateIndividual(finLead);    
        } 
        
        return null; 
        
    }
    
    public list<lead> populateIndividual(List<Lead> leads){
        
        Map < ID, Schema.RecordTypeInfo > recordTypeMap = Schema.SObjectType.Lead.getRecordTypeInfosById();
        Map < ID, Schema.RecordTypeInfo > recordTypeIndMap = Schema.SObjectType.Individual.getRecordTypeInfosById();
        Set < String > recordTypeNameSet = new Set < String > ();
        Map < String, Individual > IndividualMap = new Map < String, Individual > ();
        list<individual> indList = new list<individual>();
        // Individual Maps
        Map < String, Individual > DefaultCitationRecordTypeMapInd = new Map < String, Individual > ();
        // Lead Maps 
        Map < String, Lead > DefaultCitationRecordTypeMap = new Map < String, Lead > ();
        
        map<string,lead> leadEmailMap =  new map<string,lead>();
        for (Lead ld: leads) {
            
            if (ld.RecordTypeId != null) {
                recordTypeNameSet.add(recordTypeMap.get(ld.RecordTypeId).getName());
            }
            String recordTypeName=recordTypeMap.get(ld.RecordTypeId).getName();
            if(ld.Email!=null && recordTypeName=='Default Citation Record Type'){
                DefaultCitationRecordTypeMap.put(ld.Email, ld);
                leadEmailMap.put(ld.Email, ld);
                
            }
        }
        
        for (Individual ind: [SELECT Id, Email__c, Name, Group_Company_Name__c,recordtypeid FROM Individual where Email__c != null AND Email__c IN: leadEmailMap.keyset() and recordtypeid !=null]) {
            indList.add(ind);
        }
        if(indList.size() >0 && indList != null ){
            for(individual ld:indList){
                
                if(recordTypeIndMap.get(ld.RecordTypeId).getName() == 'Default Citation Record Type'){
                    DefaultCitationRecordTypeMapInd.put(ld.email__c,ld);
                }
            }
        }
        
        List < Lead > leadList = new List < Lead > ();
        List < Individual > indvidualListToInsert = new List < Individual > ();
        List < RecordType > rtypes = [Select Name, Id From RecordType where sObjectType = 'Individual' and isActive = true];
        Map < String, Id > individualRecTypeMap = new Map < String, Id > ();
        for (RecordType rec: rtypes) {
            individualRecTypeMap.put(rec.Name, rec.Id);
        }
        for (Lead ld:DefaultCitationRecordTypeMap.values()) {
            system.debug('ld+++DefaultCitationRecordTypeMap'+ld);
            if (DefaultCitationRecordTypeMapInd.containskey(ld.Email)) {
                ld.Individualid =DefaultCitationRecordTypeMapInd.get(ld.Email).id;
                ld.Copy_of_Individual__c = DefaultCitationRecordTypeMapInd.get(ld.Email).Id;
                leadList.add(ld);
                if(ld.HasOptedOutOfEmail == true){
                    individual idl = new individual();
                    idl = DefaultCitationRecordTypeMapInd.get(ld.Email);
                    idl.Atlas_platform_updates_legit_soft__c=false;
                    idl.Citation_Partner_Offers_Soft_Opt_in__c=false;
                    idl.Events_webinars_legit_soft__c=false;
                    idl.New_product_offer_legit_soft__c=false;
                    idl.News_service_updates_legit_soft__c=false;
                    idl.PR_Surveys_legit_soft__c=false;
                    idl.Referral_scheme_updates_legit_soft__c=false;
                    indvidualListToInsert.add(idl);
                }
            }
            
            /*else if(ld.Individualid != null){
                individual indd = new Individual();
                indd.id = ld.Individualid;
                indd.email__c = ld.email;
                indd.Group_Company_Name__c = 'Citation';
                indvidualListToInsert.add(indd);
            }*/
            else {
                individual indd = new Individual();
                if(individualRecTypeMap.get(recordTypeMap.get(ld.RecordTypeId).getName()) != null){
                    indd.RecordTypeId = individualRecTypeMap.get('Default Citation Record Type');
                }
                indd.Email__c = ld.email;
                indd.lastName = ld.lastname;
                indd.FirstName = ld.firstname;
                indd.Group_Company_Name__c = 'Citation';
                if(ld.HasOptedOutOfEmail == false){
                    indd.Atlas_platform_updates_legit_soft__c=true;
                    indd.Citation_Partner_Offers_Soft_Opt_in__c=true;
                    indd.Events_webinars_legit_soft__c=true;
                    indd.New_product_offer_legit_soft__c=true;
                    indd.News_service_updates_legit_soft__c=true;
                    indd.PR_Surveys_legit_soft__c=true;
                    indd.Referral_scheme_updates_legit_soft__c=true;
                }
                ld.individualid = null;
                ld.Copy_of_Individual__c = '';
                indvidualListToInsert.add(indd);
                leadList.add(ld);
            }
        }
        system.debug('leadList+++'+leadList);
        if (indvidualListToInsert.size()>0) {
            upsert indvidualListToInsert;
        }
        Map < String, Individual > finalIndividualMap = new Map < String, Individual > ();
        Map < String, Individual > CitationMap = new Map < String, Individual > ();
        DefaultCitationRecordTypeMapInd.clear();
        
        for (Individual ind: indvidualListToInsert) {
            finalIndividualMap.put(ind.Email__c, ind);      
            if(recordTypeIndMap.containskey(ind.RecordTypeId)&& recordTypeIndMap.get(ind.RecordTypeId).getName() == 'Default Citation Record Type'){
                DefaultCitationRecordTypeMapInd.put(ind.Email__c, ind);
            } 
            
        }
        
        system.debug('size+CitationMap'+CitationMap.size());
        list<lead> flist = new list<lead>();
        for (Lead ldnotInd: leadList) {
            
            If(ldnotInd.individualid == null && recordTypeMap.get(ldnotInd.RecordTypeId).getName() == 'Default Citation Record Type' && DefaultCitationRecordTypeMapInd.containskey(ldnotInd.Email)) {
                ldnotInd.individualid = DefaultCitationRecordTypeMapInd.get(ldnotInd.Email).Id;
                ldnotInd.Copy_of_Individual__c = DefaultCitationRecordTypeMapInd.get(ldnotInd.Email).Id;
                flist.add(ldnotInd); 
            }
        }
        
        if(!flist.isEmpty()){
            return flist;
        }
        else if(!leadList.isEmpty()){
            return leadList;
        }
        else 
            return null;
    }
    /**
    * @author Raghunath Utpala
    * @date August 8th 2019
    * @description fired on Lead update
    * @return void
    * @param newObjects: trigger.new - list of all new records being inserted/updated
    * @param newObjectsMap: trigger.new - map of all new records that being inserted/updated
	* @param oldObjectsMap: trigger.old - map of all old records that being inserted/updated
	* @param isInsert : boolean variable to identify insert /update operation
    */
    public static void updateSalesMarketingChannel(List<Lead> newobjects,final Map<Id, Lead> newObjectsMap,final Map<Id, Lead> oldObjectsMap, boolean isInsert) {
        List<Lead> leads=new List<Lead>();
        Map<String,String> prospectToMarketingChannel=new Map<String,String>();
        Map<String,String> ProspectToSalesChannel=new Map<String,String>();
        Set<String> channels=new Set<String>();
        List<Prospect_Source_Data__mdt> prospectSourceMDT=new List<Prospect_Source_Data__mdt>();
        prospectSourceMDT=[SELECT Label,Marketing_Channel__c,Sales_Channel__c from Prospect_Source_Data__mdt];
        list<Group_Configuration__mdt> gcm = [select masterlabel,DeveloperName,Keywords__c from Group_Configuration__mdt];
        system.debug(gcm);
        map<string,string> keyMap = new map<string,string>();
        for(Group_Configuration__mdt gm: gcm){
            if(gm.Keywords__c.containsAny(',')){
                
                list<string> kstring = gm.Keywords__c.split(',');
                for(string str: kstring){
                    keyMap.put(str,gm.masterLabel);
                }
            }
            else{
                keyMap.put(gm.Keywords__c,gm.masterLabel);
            }
           
        }
        system.debug(keyMap.keySet());
        for(Prospect_Source_Data__mdt pmdt:prospectSourceMDT){
            prospectToMarketingChannel.put(pmdt.Label,pmdt.Marketing_Channel__c);
            ProspectToSalesChannel.put(pmdt.Label,pmdt.Sales_Channel__c);
            channels.add(pmdt.Sales_Channel__c);
        }
        Map<String,String> mapCampaignToLead=new Map<String,String>();
        for(Lead l:newobjects){
            if(l.Source_Campaign__c!=null){
                mapCampaignToLead.put(l.Id,l.Source_Campaign__c);
            }
        }
        Map<Id,Campaign> mapCampaigns=new Map<Id,Campaign>([SELECT Id,Name FROM Campaign WHERE Id IN :mapCampaignToLead.values()]);
        for(Lead l:newobjects){
            boolean scupdated=false;
            if(l.LeadSource!=null && prospectToMarketingChannel.containsKey(l.LeadSource)){
                l.Marketing_Channel__c=prospectToMarketingChannel.get(l.LeadSource);
            }
            if(l.LeadSource==null || l.LeadSource==''|| (l.LeadSource!=null && !prospectToMarketingChannel.containsKey(l.LeadSource))){
                l.Marketing_Channel__c='';
            }
            //SDT-2211 - Commented the below line as part of the metioned story
            /*
            if(l.Source_Campaign__c!=null && mapCampaignToLead.containsKey(l.Id)){
                String campaignName=mapCampaigns.get(mapCampaignToLead.get(l.Id)).Name;
                if(campaignName.contains('EPM') || campaignName.contains('QMS') || campaignName.contains('SMAS')){
                    l.Sales_Channel__c='Cross Sell';
                    scupdated=true;
                }
            }*/
            for(string strMap: keyMap.keySet()){
            
                if(l.LeadSource!=null && l.LeadSource.containsIgnoreCase(strMap)){
                    l.Sales_Channel__c='Cross Sell';
                    scupdated=true;
                }
                if(l.ReferredByCompanyInternal__c!=null && l.ReferredByCompanyInternal__c.containsIgnoreCase(strMap)){
                    l.Sales_Channel__c='Cross Sell';
                    scupdated=true;
                }
                if(l.Source__c!=null && l.Source__c.containsIgnoreCase(strMap)){
                    l.Sales_Channel__c='Cross Sell';
                    scupdated=true;
                }
                if(l.Data_Supplier__c!=null && l.Data_Supplier__c.containsIgnoreCase(strMap)){
                    l.Sales_Channel__c='Cross Sell';
                    scupdated=true;
                }

            }
            if(l.LeadSource!=null && (l.LeadSource.contains('SEM') || l.LeadSource.contains('Seminar')) && !scupdated){
                l.Sales_Channel__c='Seminar';
                scupdated=true;
            }
            if(l.LeadSource!=null && l.Sales_Criterion__c!=null 
                && ProspectToSalesChannel.containsKey(l.LeadSource) 
                && ProspectToSalesChannel.get(l.LeadSource).equals('Outbound or Inbound') && !scupdated){
                l.Sales_Channel__c=l.Sales_Criterion__c;
                scupdated=true;
            }
            if(l.LeadSource!=null && ProspectToSalesChannel.containsKey(l.LeadSource) && !scupdated){
                l.Sales_Channel__c=ProspectToSalesChannel.get(l.LeadSource);
                scupdated=true;
            }
            if(!scupdated){
                l.Sales_Channel__c='Data Incomplete';
            }          
        }
    }
    public static void setDialListFields(List<Lead> Leads){
        DialListCriteriaFieldsHelper.buildownerIdToNameMap(Leads);
        DialListCriteriaFieldsHelper.setDialListFields(Leads);
    }
}