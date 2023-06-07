public class CreateContractButtonController {
    @AuraEnabled
    public static List<ContractInfo> executeQuery(String rid){
        string theQuery;
        string theLineQuery;
        try{        
            theQuery = 'Select Id,SBQQ__Account__c,SBQQ__PrimaryContact__r.Account.Id, SBQQ__Account__r.CitationSector__c,SBQQ__Account__r.AnnualRevenue,SBQQ__Account__r.PT_Employees__c,SBQQ__Account__r.FT_Employees__c,SBQQ__Account__r.Sites__c,Quote_Line_Item_Rollup__c,Opportunity_Stage__c, SBQQ__Primary__c, SBQQ__StartDate__c, Contract_Details_Complete__c, Owner_Department__c From SBQQ__Quote__c WHERE Id = \'' + rid + '\''; 
            theLineQuery = 'select id,SBQQ__Quote__c,SBQQ__SubscriptionPricing__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = \'' + rid + '\''; 
            
            SBQQ__Quote__c cpqQt = Database.query(theQuery);
            list<SBQQ__QuoteLine__c> cpqQtL = Database.query(theLineQuery);
            system.debug('cpql errors' + cpqQtL);
            list<ContractInfo> lcIf = new list<ContractInfo>();
            lcIf.add(new ContractInfo(cpqQt,cpqQtL,cpqQt.SBQQ__Account__r.AnnualRevenue,cpqQt.SBQQ__Account__r.PT_Employees__c,cpqQt.SBQQ__Account__r.FT_Employees__c,cpqQt.SBQQ__Account__r.Sites__c,cpqQt.SBQQ__Account__r.CitationSector__c,cpqQt.SBQQ__PrimaryContact__r.Account.Id));
            system.debug('printing the wrapper list'+lcIf);
            return lcIf;
            
        }catch(Exception e){
            AuraHandledException exp = new AuraHandledException('Unable to get the details for the quote please contact adminitrator for more details');
        	exp.setMessage('Unable to get the details for the quote please contact adminitrator for more details');
            throw exp;
        }
    }
   
    public class ContractInfo{
        @AuraEnabled
        public SBQQ__Quote__c cpqq {get;set;}
        @AuraEnabled
        public boolean subs {get;set;}
        @AuraEnabled
        public decimal annrevenue {get;set;}
        @AuraEnabled
        public decimal pte {get;set;}
        @AuraEnabled
        public decimal fte {get;set;}
        @AuraEnabled
        public decimal nsites {get;set;}
        @AuraEnabled
        public string csector {get;set;}
        @AuraEnabled
        public boolean difContact {get;set;}
        @AuraEnabled
        public id accId {get;set;}
        
         
            public ContractInfo(SBQQ__Quote__c CPQ_Quote, list<SBQQ__QuoteLine__c> CPQ_QuoteLines, decimal annrevenue, decimal pte,decimal fte,decimal nsites,string csector,id accId){
            	this.cpqq = CPQ_Quote;
                this.subs = true;
                this.annrevenue = annrevenue;
                this.pte = pte;
                this.fte = fte;
                this.nsites = nsites;
                this.csector = csector;
                this.accId = accId;
                this.difContact = false;
                
                for(SBQQ__QuoteLine__c cpqQL: CPQ_QuoteLines){
                    if(!(cpqQL.SBQQ__SubscriptionPricing__c != null && cpqQL.SBQQ__SubscriptionPricing__c != '')){
                        system.debug('cpqQL'+cpqQL);
                     	this.subs = false;   
                    }
                     
                }
                if(cpqq.SBQQ__Account__c != accId){
                    difContact = true;
                }
                }
                    
      }    
}