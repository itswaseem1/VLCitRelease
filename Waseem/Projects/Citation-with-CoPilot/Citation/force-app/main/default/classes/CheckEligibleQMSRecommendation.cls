/**
* @File Name          : CheckEligibleQMSRecommendation.apxt
* @Description        :
* @Author             : Sarita Cognizant
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 6/8/2021.
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0     06/08/2021      Initial Version						SS-936
**/
@SuppressWarnings('PMD')
public without sharing class CheckEligibleQMSRecommendation {
    public Static map<String,string> mapProRecType = new Map<string,string>();
    public static List<String> productString =new List<String>();
    public static Set<String> PRO_FAM_LIST = new Set<String>{'Health & Safety','H&S consultancy','Duel Service','Citation Employment Law & HR'};
        
        @InvocableMethod(label='CheckEligibleQMSRecommendation'
                         description='This function returns recommendations for the QMS accounts in our catalog.')
        public static List<List<Recommendation>> getEligibleRecommandation(List<getRecommandation> inputData){
            
            List<List<Recommendation>> comList= new List<List<Recommendation>>();
            List<String> filterString =new List<String>();
            List<case> cList = new List<case>();
            List<Id> sectorRecList=new List<Id>();
            List<Id> productRecList=new List<Id>();
            List<Id> finalRecList=new List<Id>();
            /*verify contact Details*/
            cList.addAll(getCaseDetails(inputData[0].caseId));
            /*get billing contract Product Details*/
            filterString= getProductDetails(cList[0].AccountId);
            productRecList= getProductfamilyDetails(productString,inputData[0].recommendations);
            sectorRecList=checkEligibleSector(cList[0].AccountId, filterString,productRecList);
            
            finalRecList.addAll(sectorRecList);
            //finalRecList.addAll(productRecList);
            
            /*Check task is Created with recommandation Name*/
            List<Recommendation> recslist = new List<Recommendation>(checkTaskDetails(cList[0].AccountId,finalRecList));
            Set<Id> outputIds = (new Map<Id,Recommendation>(recslist)).keySet();
            comList.addAll(getFinalRecommList(outputIds,inputData));
            return comList;
        }
    public static List<case> getCaseDetails(string caseId){
        List<case> caseList = new List<case>();
        caseList = [SELECT id ,ContactId, AccountId FROM CASE WHERE id =:caseId WITH SECURITY_ENFORCED];
        return caseList;
    }
    public static List<Recommendation> checkTaskDetails( String accountId, List<String> roleRecList){
        list<String> subjectList=new list<String>();
        List<Recommendation> comMap= new List<Recommendation>();
        List<Recommendation> filterRecommandationlist = new List<Recommendation>([SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation where
                                                                                  Id IN:roleRecList
                                                                                   WITH SECURITY_ENFORCED ORDER BY Priority__c]);
        
        List<string> subjectNamelist =new List<string>();
        for(Recommendation r:filterRecommandationlist){subjectNamelist.add(r.Name);}
        
        List<RecommandationHistory__c> taslist= new List<RecommandationHistory__c>([SELECT Id,Due_Date__c,Name,RelatedTo__c, Status__c FROM RecommandationHistory__c 
                                                                                    where Due_Date__c > TODAY
                                                                                    AND RelatedTo__c=:accountId
                                                                                    AND Name IN:subjectNamelist WITH SECURITY_ENFORCED]);
        if(taslist.size() > 0 ){for(RecommandationHistory__c t : taslist){subjectList.add(t.Name);}}
        if(subjectList.size() > 0 ){
            comMap= [SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation 
                     where Name NOT IN :subjectList and id IN:roleRecList WITH SECURITY_ENFORCED ORDER BY Priority__c  ];}
        else{comMap.addAll(filterRecommandationlist);}
        
        return comMap;
    }
    
    public static List<String> getProductDetails( String accountId){
        List<String> filters =new List<String>();
        MAP<Id,ffbc__Contract__c> contractsMap;
        if(test.isRunningTest()){
            contractsMap = new Map<Id,ffbc__Contract__c>([SELECT id,ffbc__Account__c FROM ffbc__Contract__c WHERE ffbc__Account__c =: accountId WITH SECURITY_ENFORCED]);
        }
        else{
            contractsMap = new Map<Id,ffbc__Contract__c>([SELECT id,ffbc__Account__c FROM ffbc__Contract__c WHERE ffbc__Account__c =: accountId AND ffbc__Status__c =: 'Active' WITH SECURITY_ENFORCED]);
        }
        
        List<ffbc__ContractLineItem__c> lineItems = new List<ffbc__ContractLineItem__c>([SELECT id,ffbc__ProductService__r.Name FROM ffbc__ContractLineItem__c WHERE ffbc__Contract__c IN: contractsMap.keySet() WITH SECURITY_ENFORCED]);
        for(ffbc__ContractLineItem__c itmes : lineItems){
            productString.add(itmes.ffbc__ProductService__r.Id);
            
            if(itmes.ffbc__ProductService__r.Name.contains('ISO 45001')){mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%ISO45001%');}
            else if(itmes.ffbc__ProductService__r.Name.contains('ISO 14001')){mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%ISO14001%');}
            else if(itmes.ffbc__ProductService__r.Name.contains('ISO 27001')){ mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%ISO27001%');}
            else if(itmes.ffbc__ProductService__r.Name.contains('ISO 9001')){ mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%ISO9001%');}
            else if(itmes.ffbc__ProductService__r.Name.contains('QMS eLearning') || itmes.ffbc__ProductService__r.Name.contains('Atlas UpSkill')){mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%QMS eLearning%');} 
            
        }
        filters.addAll(mapProRecType.values());
        
        return filters;
    }
    public static List<Id> getProductFamilyDetails(List<String> productString,List<Recommendation> recList){
        List<Id> recIds =new List<Id>();
        Map<String, Id> recMap = new Map<String, Id>();
        
        for(Recommendation oh : recList)
        {
            recMap.put(oh.Name, oh.Id);
        }
        List<Product2> products2list =[SELECT id,Name, family FROM Product2 WHERE Id IN:productString WITH SECURITY_ENFORCED];
        for(Product2 pro:products2list){
            if(pro.Name.contains('ISO 45001')) {
                if(!pro.Name.contains('SMAS')){
                    recIds.add(recMap.get('SMAS Referral'));
                }
                if(!PRO_FAM_LIST.contains(pro.family)){
                    recIds.add(recMap.get('Citation Referral'));
                        }
            }
               }
        system.debug('recIds'+recIds);
        return  recIds;
    }
    public static List<List<Recommendation>> getFinalRecommList(Set<Id> outputIds,List<getRecommandation> inputData){
        List<List<Recommendation>> comList= new List<List<Recommendation>>();
        List<Recommendation> finalrecList= new  List<Recommendation>([SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation WHERE id IN:outputIds WITH SECURITY_ENFORCED ORDER BY Priority__c ]); 
        List<Recommendation> singleRequestOutputs = new List<Recommendation>(); 
        if(finalrecList.size() > 0){singleRequestOutputs.addAll(finalrecList);}
        for (getRecommandation inputRequest : inputData)
        {
            inputRequest.recommendations.addAll(singleRequestOutputs);
            comList.add(singleRequestOutputs);
        }   
        return comList;
    }
    public static List<Id> checkEligibleSector(String accountId,List<String> filterString,List<Id> productRecList){
        Map<String,Id> reMap= new Map<String,Id>();
        List<Id> roleMatchingRecList=new List<Id>();
        Account acc= [SELECT Id ,Name,QMS_Sector__c FROM Account WHERE Id =:accountId];
        List<Recommendation> reclist =[SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation where (NOT Name like :filterString) AND Category__c = 'Lead Generation'  WITH SECURITY_ENFORCED ORDER BY Priority__c ];
        List<Recommendation> proRecList=[SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation where Id IN:productRecList AND Category__c = 'Lead Generation'  WITH SECURITY_ENFORCED ORDER BY Priority__c];
        QMS_Recommandation_List__mdt records = [select id ,label,SMAS_Referral__c,Upsell_ISO14001__c,Upsell_ISO27001__c,Upsell_ISO45001__c,Upsell_ISO9001__c from QMS_Recommandation_List__mdt where label=:acc.QMS_Sector__c WITH SECURITY_ENFORCED];
        for(Recommendation rec : reclist)
        {reMap.put(rec.Name, rec.Id);}
         for(Recommendation rec : proRecList)
        {reMap.put(rec.Name, rec.Id);}
        
        
        if(records.Upsell_ISO14001__c){roleMatchingRecList.add(reMap.get('Upsell ISO14001')); }
        if(records.Upsell_ISO27001__c){roleMatchingRecList.add(reMap.get('Upsell ISO27001'));}
        if(records.Upsell_ISO45001__c){roleMatchingRecList.add(reMap.get('Upsell ISO45001'));}
        if(records.Upsell_ISO9001__c){roleMatchingRecList.add(reMap.get('Upsell ISO9001'));}
        if(records.SMAS_Referral__c){roleMatchingRecList.add(reMap.get('SMAS Referral'));}
        roleMatchingRecList.add(reMap.get('Upsell QMS eLearning'));
        roleMatchingRecList.add(reMap.get('Citation Referral'));
        return roleMatchingRecList;
        
    }
    
    public  with sharing class getRecommandation {
        @InvocableVariable(label='case ID')
        public String caseId;
        
        @InvocableVariable
        public List<Recommendation> recommendations;
    }
    
}