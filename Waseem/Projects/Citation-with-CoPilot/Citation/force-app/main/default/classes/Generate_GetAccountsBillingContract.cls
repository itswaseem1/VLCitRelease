/**
    * @File Name          : Generate_GetAccountsBillingContract.apxt
    * @Description        : get recommandation based on product of active billing contract
    * @Author             : Sarita Cognizant
    * @Group              :
    * @Last Modified By   :
    * @Last Modified On   : 10/8/2021.
    * @Modification Log   :
    *==============================================================================
    * Ver         Date                     Author                 Modification
    *==============================================================================
    * 1.0     06/08/2021      Initial Version						SS-878/SS-847
    **/
    public without sharing class Generate_GetAccountsBillingContract {
        public Static map<string,string> mapProRecType = new Map<string,string>();
        public static List<String> productString =new List<String>();
        public static Boolean isActiveContract=false;
        
        @InvocableMethod(label='GetAccountsBillingContract'
                         description='This function returns recommendations for the accounts in our catalog.')
        public static List<List<Recommendation>> getAccountsBillingContract(List<GenerateRequest> inputData){
            
            List<List<Recommendation>> comList= new List<List<Recommendation>>();
            List<String> filterString =new List<String>();
            List<case> cList = new List<case>();
            List<Id> roleRecList=new List<Id>();
            String userRoleName= checkUserDetails();
            /*verify contact Details*/
            cList.addAll(getCaseDetails(inputData[0].caseId));
            mapProRecType.putAll( getValidContacts(cList[0].ContactId));
            /*get billing contract Product Details*/
            filterString= getProductDetails(cList[0].AccountId);
            
            /*check role wise recommandation Details*/
            roleRecList.addAll(CheckEligibleRecommendation.checkEligibleRecomm(filterString,userRoleName,productString,isActiveContract));
            /*Check task or lead is Created with recommandation Name*/
            
            List<Recommendation> recslist = new List<Recommendation>(checkTaskDetails(cList[0].AccountId,roleRecList));
            Set<Id> outputIds = (new Map<Id,Recommendation>(recslist)).keySet();
            comList.addAll(getFinalRecommList(outputIds,inputData));
            return comList;
        }
        public static List<case> getCaseDetails(string caseId){
            List<case> caseList = new List<case>();
            caseList = [SELECT id ,ContactId, AccountId FROM CASE WHERE id =:caseId WITH SECURITY_ENFORCED];
            return caseList;
        }
        public static List<List<Recommendation>> getFinalRecommList(Set<Id> outputIds,List<GenerateRequest> inputData){
            List<List<Recommendation>> comList= new List<List<Recommendation>>();
            List<Recommendation> finalrecList= new  List<Recommendation>([SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation WHERE id IN:outputIds]); 
            List<Recommendation> singleRequestOutputs = new List<Recommendation>(); 
            if(finalrecList.size() > 0){singleRequestOutputs.addAll(finalrecList);}
            for (GenerateRequest inputRequest : inputData)
            {
                inputRequest.recommendations.addAll(singleRequestOutputs);
                comList.add(singleRequestOutputs);
            }   
            return comList;
        }
        
        public static String checkUserDetails( ){
            String userId = UserInfo.getUserId();
            User userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userId AND (NOT UserRole.name like'QMS%') WITH SECURITY_ENFORCED];
            string userRoleName =userDetails.UserRole.Name;
            return userRoleName;
        }
        
        public static map<string,string> getValidContacts(string contactId){
            map<string,string> mapProdRecType = new Map<string,string>();
            
            List<Contact> conList= new List<Contact>([SELECT Id,Email,Phone,MobilePhone,Position__c FROM Contact WHERE Id=:contactId]);
            if(conList.size() > 0){
                for(Contact ca: conList) {
                    if(String.isNOtBlank(ca.Email) && String.isNotBlank(ca.MobilePhone) && String.isNotBlank(ca.Phone) && String.isNotBlank(ca.Position__c)){
                        mapProdRecType.put('contactDetailNotEmpty','%contact details%');
                    }
                }}
            else{ mapProdRecType.put('client review','%Ask for an online client review%');
                 mapProdRecType.put('contactDetailNotEmpty','%contact details%');}
            return mapProdRecType;
        }
        public static List<Recommendation> checkTaskDetails( String accountId, List<String> roleRecList){
            list<String> subjectList=new list<String>();
            List<Recommendation> comMap= new List<Recommendation>();
            List<Recommendation> filterRecommandationlist = new List<Recommendation>([SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation where
                                                                                      Id IN:roleRecList
                                                                                      ORDER BY Priority__c]);
            
            List<string> subjectNamelist =new List<string>();
            for(Recommendation r:filterRecommandationlist){subjectNamelist.add(r.Name);}
            
            List<RecommandationHistory__c> taslist= new List<RecommandationHistory__c>([SELECT Id,Due_Date__c,Name,RelatedTo__c, Status__c FROM RecommandationHistory__c 
                                                                                        where Due_Date__c > TODAY
                                                                                        AND RelatedTo__c=:accountId
                                                                                        AND Name IN:subjectNamelist WITH SECURITY_ENFORCED]);
            if(taslist.size() > 0 ){for(RecommandationHistory__c t : taslist){subjectList.add(t.Name);}}
            if(subjectList.size() > 0 ){
                comMap= [SELECT AcceptanceLabel,ActionReference,Category__c,Description,id,ImageId,IsActionActive,Name,Priority__c,RejectionLabel FROM Recommendation 
                         where Name NOT IN :subjectList and id IN:roleRecList WITH SECURITY_ENFORCED ORDER BY Priority__c ];}
            else{comMap.addAll(filterRecommandationlist);}
            
            return comMap;
        }
        public static MAP<Id,ffbc__Contract__c> getActiveContractDetails( String accountId){
            MAP<Id,ffbc__Contract__c> contractsMap;
            if(test.isRunningTest()){
                contractsMap = new Map<Id,ffbc__Contract__c>([SELECT id,ffbc__Account__c FROM ffbc__Contract__c WHERE ffbc__Account__c =: accountId]);
            }
            else{
                contractsMap = new Map<Id,ffbc__Contract__c>([SELECT id,ffbc__Account__c FROM ffbc__Contract__c WHERE ffbc__Account__c =: accountId AND ffbc__Status__c =: 'Active']);
            }
            if(contractsMap.size() > 0){isActiveContract=true;}
            return contractsMap;
        }
        
        public static List<String> getProductDetails( String accountId){
            List<String> filters =new List<String>();
            MAP<Id,ffbc__Contract__c> contractMaps= new MAP<Id,ffbc__Contract__c>();
            contractMaps=getActiveContractDetails(accountId);
            List<ffbc__ContractLineItem__c> lineItems = new List<ffbc__ContractLineItem__c>([SELECT id,ffbc__ProductService__r.Name FROM ffbc__ContractLineItem__c WHERE ffbc__Contract__c IN: contractMaps.keySet()]);
            for(ffbc__ContractLineItem__c itmes : lineItems){
                productString.add(itmes.ffbc__ProductService__r.Name);
                if(itmes.ffbc__ProductService__r.Name.contains('ISO')){mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%ISO%');}
                else if(itmes.ffbc__ProductService__r.Name.contains('Atlas UpSkill')){mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%Atlas%');}
                else if(itmes.ffbc__ProductService__r.Name.contains('On-Site Health & Safety')){ mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%On-Site H&S%');}
                else if(itmes.ffbc__ProductService__r.Name.contains('On-Site HR')){ mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%On-Site HR%');}
                else if(itmes.ffbc__ProductService__r.Name.contains('Fire Risk Assessment')){mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%FRA%');}
                else if(itmes.ffbc__ProductService__r.Name.contains('Employee Assistance Programme')){mapProRecType.put(itmes.ffbc__ProductService__r.Name,'%EAP%');}
            }
            filters.addAll(mapProRecType.values());
            return filters;
        }
        
        public  with sharing class GenerateRequest {
            @InvocableVariable(label='case ID')
            public String caseId;
            
            @InvocableVariable
            public List<Recommendation> recommendations;
        }
    }