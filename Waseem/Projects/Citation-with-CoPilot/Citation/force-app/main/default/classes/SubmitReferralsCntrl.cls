/**
 * @File Name          : SubmitReferralsCntrl.cls
 * @Description        : Creates Opportunity Record when a Referral is submitted
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 11/08/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     11/08/2021                  Priyanka               Initial Version
 **/
public without sharing class SubmitReferralsCntrl {
    //Fetches the list of Referral Products based on Product Family
    @AuraEnabled
    public static Map<String, List<Product2>> fetchProducts(){
        try{
            List<Product2> prods = [SELECT Name, Family FROM Product2 where Referral_Product__c=true ORDER BY Family];
            Map<String, List<Product2>> prodFamilyGrp = new Map<String, List<Product2>>();
            for(Product2 prod : prods){
                if(prodFamilyGrp.containsKey(prod.Family)) {
                    (prodFamilyGrp.get(prod.Family)).add(prod);
                }else{
                    prodFamilyGrp.put(prod.Family,new List<Product2>{prod});
                }
            }
            return prodFamilyGrp;
        }catch(Exception ex){
            system.debug('Exception occured in '+ex.getStackTraceString());
            throw new AuraHandledException('Some error occured while fetching Produucts ');
        }  
    }

    //Creates a new Opportunity when a Referral is submitted through UI
    @AuraEnabled
    public static void createOpportunity(Opportunity opportunityRec,List<Id> selectedProds,List<String> selectedProdNames){
        Savepoint sp = Database.setSavepoint();
        try{
            Id accRecId = opportunityRec.AccountId;
            Account acc = [Select Id,Name,Site,Sites__c from Account where Id=:accRecId Limit 1];
            Id recType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Default Citation Opportunity').getRecordTypeId();
            Pricebook2 priceBook = [Select Id from Pricebook2 where Name='Referrals Pricebook'];
            User user = [Select Id,	Referral_Departments__c from User where Id=:UserInfo.getUserId()];
            opportunityRec.AccountId = accRecId;
            opportunityRec.Name = 'AddOn-'+acc.Name+((acc.Site != null) ? '-'+acc.Site : '');
            opportunityRec.StageName = 'Develop';
            Date oppDate = Date.today();
            opportunityRec.CloseDate = oppDate.addMonths(6);
            opportunityRec.Type = 'Add-On';
            opportunityRec.LeadSource = 'Ref_employee_360';
            opportunityRec.Deal_Type__c = 'Add-On';
            opportunityRec.Prospect_Channel__c = 'S360_Referral';
            if(user!=null){
                opportunityRec.Referred_By_Citation_Department__c = user.Referral_Departments__c;
            }
            if(System.label.Mansoor_Kayani!=null){
                opportunityRec.OwnerId = System.label.Mansoor_Kayani;
            }
            opportunityRec.Consultant__c = userInfo.getUserId();
            opportunityRec.ReferringEmployeeFirstName__c = userInfo.getFirstName();
            opportunityRec.ReferringEmployeeLastName__c = userInfo.getLastName();
            opportunityRec.ReferringEmployeeEmail__c = userInfo.getUserEmail();
            opportunityRec.Interested_Products__c = String.join(selectedProdNames,',');
            opportunityRec.RecordTypeId = recType;
            opportunityRec.Sites__c = acc.Sites__c;
            opportunityRec.Referred_By_Citation_Company__c = 'Citation';
            opportunityRec.Pricebook2Id = priceBook.Id;
            insert opportunityRec;        
            
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            if(selectedProds.size()>0){
                for(Id prodId : selectedProds){
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.OpportunityId = opportunityRec.Id;
                    oppLineItem.Quantity = 1;
                    oppLineItem.TotalPrice = 0.00;
                    oppLineItem.Product2Id = prodId;
                    oppLineItems.add(oppLineItem);
                }
            }
            if(oppLineItems.size()>0){
                if (OpportunityLineItem.getSObjectType().getDescribe().isCreateable() && Schema.sObjectType.OpportunityLineItem.fields.OpportunityId.isCreateable()
                    && Schema.sObjectType.OpportunityLineItem.fields.Quantity.isCreateable()
                    && Schema.sObjectType.OpportunityLineItem.fields.Product2Id.isCreateable()) {
                        insert oppLineItems;
                    }
            }
        }catch(Exception ex){
            system.debug('Exception occured-->'+ex.getStackTraceString()+ex.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException('Some error occured in creating the opportunity.');
        }  
    }
    
    //Fetches the Contacts associated to an Account
    @AuraEnabled
    public static List<Contact> fetchContacts(String accId) {
        List<Contact> returnList = new List<Contact>();
        List<Contact> lstOfContacts = [Select Id, Name from Contact where AccountId=:accId];
        
        for (Contact cont: lstOfContacts) {
            returnList.add(cont);
        }
        return returnList;
    }
    
    //Fetches the Contacts based on the ContactId
    @AuraEnabled
    public static Contact fetchContact(String contId) {
        Contact cont = [Select Id, Name from Contact where Id=:contId Limit 1];
        return cont;
    }
}