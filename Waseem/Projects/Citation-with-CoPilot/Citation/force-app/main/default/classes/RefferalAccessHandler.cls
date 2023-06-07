/**
 * @File Name          : RefferalAccessHandler.cls
 * @Description        : Provides Referrer read access to Opportunity and Lead records
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021               Priyanka Koshti          Initial Version
 **/
public without sharing class RefferalAccessHandler {
    //Provides Referrer read access to  Opportunity records when new Referrals are created
    public static void enableOppRecsAccess(List<Opportunity> opps, Map<Id,Opportunity> oldOpps){
        Set<String> refEmailIds = new Set<String>();
        Map<Id,String> userEmail = new Map<Id,String>();
        Map<String,Id> recDetails = new Map<String,Id>();
        List<OpportunityShare> oppList = new List<OpportunityShare>();
        for(Opportunity currOpp : opps){
            if((Trigger.isInsert && currOpp.Owner.Email != currOpp.ReferringEmployeeEmail__c) || 
               (Trigger.isUpdate && ((currOpp.Owner.Email != currOpp.ReferringEmployeeEmail__c && oldOpps.get(currOpp.Id).ReferringEmployeeEmail__c != currOpp.ReferringEmployeeEmail__c) || (currOpp.OwnerId != oldOpps.get(currOpp.Id).OwnerId)))){
                   refEmailIds.add(currOpp.ReferringEmployeeEmail__c);
                   recDetails.put(currOpp.ReferringEmployeeEmail__c,currOpp.Id);
            }
        }
        if(refEmailIds.size()>0){
            userEmail = fetchUserDetails(refEmailIds);
            if(userEmail.size()>0){
                for(Id userId : userEmail.keySet()){
                    OpportunityShare oppShare = new OpportunityShare();
                    oppShare.OpportunityId = recDetails.get(userEmail.get(userId));
                    oppShare.UserOrGroupId = userId;
                    oppShare.OpportunityAccessLevel = 'Edit';
                    oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;
                    oppList.add(oppShare);
                }
                Database.SaveResult[] oppInsertResult = Database.insert(oppList,false);
            }
        }
    }
    
    //Fetches the User details based on the Emailid
    public static Map<Id,String> fetchUserDetails(Set<String> refEmailIds){
        Map<Id,String> userEmail = new Map<Id,String>();
        List<User> userDetails = new List<User>();
        if(User.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.User.fields.Id.isAccessible() 
          && Schema.SObjectType.User.fields.Email.isAccessible()){
            userDetails = [SELECT Id,Email FROM User WHERE Email IN: refEmailIds];
        }
        if(userDetails!=null && userDetails.size()>0){
            for(User uss : userDetails){
                userEmail.put(uss.Id, uss.Email);
            }
        }
        return userEmail;
    }
    
    //Provides Referrer read access to  Lead records when new Referrals are created
    public static void enableLeadRecsAccess(List<Lead> leads, Map<Id,Lead> oldLeads){
        Set<String> refEmailIds = new Set<String>();
        Map<Id,String> userEmail = new Map<Id,String>();
        Map<String,Id> recDetails = new Map<String,Id>();
        List<LeadShare> leadList = new List<LeadShare>();
        for(Lead currLead : leads){
            if((Trigger.isInsert && currLead.Owner.Email != currLead.Referred_By_Email__c) || 
               (Trigger.isUpdate && ((currLead.Owner.Email != currLead.Referred_By_Email__c && oldLeads.get(currLead.Id).Referred_By_Email__c != currLead.Referred_By_Email__c) || (currLead.OwnerId != oldLeads.get(currLead.Id).OwnerId)))){
                   refEmailIds.add(currLead.Referred_By_Email__c);
                   recDetails.put(currLead.Referred_By_Email__c,currLead.Id);
               }
        }
        if(refEmailIds.size()>0){
            userEmail = fetchUserDetails(refEmailIds);
            if(userEmail.size()>0){
                for(Id userId : userEmail.keySet()){
                    LeadShare leadShare = new LeadShare();
                    leadShare.LeadId = recDetails.get(userEmail.get(userId));
                    leadShare.UserOrGroupId = userId;
                    leadShare.LeadAccessLevel = 'Read';
                    leadShare.RowCause = Schema.LeadShare.RowCause.Manual;
                    leadList.add(leadShare);
                }
                Database.SaveResult[] leadInsertResult = Database.insert(leadList,false);
            }
        }
    }
}