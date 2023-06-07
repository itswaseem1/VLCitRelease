public without sharing class qms_ContractProductPrices {
	
	public List<SBQQ__QuoteLine__c> quoteLine {get;set;} 
	public SBQQ__Quote__c quote {get;set;} 
	public Decimal totalAmount {get;set;}
	public Integer totalSites {get;set;}
	public Integer additionSites {get;set;}
	public Decimal primarySiteGADays {get;set;}
	public String certificationNames {get;set;}
	public Map<id,list<SBQQ__QuoteLine__c>>  parentQLIMap {get;set;}
	public List<Service_Detail__c> serviceDetailsList {get;set;}
	public Map<id,Service_Detail__c> productServiceDetailsMap {get;set;}
	public Map<String,String> productSTypeServiceDetailsMap {get;set;}
	public List<list<wrapQLI>>  parentWQLIList {get;set;}
	public List<list<SBQQ__QuoteLine__c>>  listParentQLI {get;set;}
	
	
	public qms_ContractProductPrices() {
		totalAmount = 0;
		totalSites = 0;
		additionSites = 0;
		primarySiteGAdays = 0;
		map<string,string>   parentproductcodes = new map<string,string>();
		string exlOneoff = System.Label.Exclude_One_Off;
		list<string> listexclOneoff = exlOneoff.split(',');
		for(string prd: listexclOneoff){
			parentproductcodes.put(prd,prd);
		}
		Id quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
		List<String> uniqueServiceType =new List<String> {'Content Update','Support','Upgrade','Additional Site Compliance audit – Existing Client'};
		//Quote
		quote = [SELECT SBQQ__SalesRep__c, SBQQ__BillingName__c, SBQQ__ExpirationDate__c, CreatedDate, Name, Account_Annual_Revenue__c, 
				 SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Email, SBQQ__PrimaryContact__r.Phone,
				 SBQQ__Account__c, Staff__c,  SBQQ__Account__r.TotalNoUKoffices__c, SBQQ__Account__r.TotalNoInternationalOffices__c,
				 SBQQ__Account__r.Company_VAT_Number__c, SBQQ__Account__r.Company_Registration_Number__c, SBQQ__Account__r.Website,
				 Number_Of_Full_Time_Employees__c, Number_of_Part_Time_Employees__c, Number_of_Complex_Sites__c, Number_of_Standard_Sites__c,
				 SBQQ__Account__r.BillingStreet, SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingPostalCode, SBQQ__Account__r.BillingCountry,SBQQ__Account__r.Name,
		 			SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, SBQQ__BillingCountry__c,
				 SBQQ__BillingFrequency__c, Contract__c,  Contract__r.ContractNumber,Account_Total_Employees__c,SBQQ__Opportunity2__r.Sites__c,
				 Deal_Start_Date__c, Subsidiary_and_associated_companies__c, FTE__c, Payroll__c, Total_Sites__c, SBQQ__StartDate__c,SBQQ__Opportunity2__r.Care_Home_Sites__c,SBQQ__AverageCustomerDiscount__c,SBQQ__Opportunity2__r.Subsidiary_Companies__c
				 FROM SBQQ__Quote__c
				 WHERE Id = :quoteId
				];
		
		//Quote Line
		quoteLine = [SELECT Id, SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__Product__r.Description, SBQQ__Quote__r.Account_No_Of_Sites__c,
					 Total_Quote_Line__c , SBQQ__ProductName__c, SBQQ__Quantity__c , QMS_Connect_Term__c ,Price_per_Billing_Frequency__c,
					 SBQQ__Quote__r.SBQQ__Opportunity2__r.Sites__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c,
					 Base_Product_Name__c ,Billing_Frequency__c,Regular_Payment__c,QMS_CPQ_Regular_Payment__c,Parent_product_name__c,
					 Service__c,SBQQ__ListPrice__c,SBQQ__CustomerPrice__c,SBQQ__NetTotal__c,SBQQ__Product__c,SBQQ__RequiredBy__r.SBQQ__Product__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Billing_Frequency__c,SBQQ__ProductCode__c,QMS_Discount_Applied__c,Custom_Discount_Percentage__c,Custom_Discount_Amount__c
					 FROM SBQQ__QuoteLine__c
					 WHERE SBQQ__Quote__c = :quoteId 					 
					];

		totalSites = quote.SBQQ__Opportunity2__r.Sites__c != NULL ? (Integer)quote.SBQQ__Opportunity2__r.Sites__c : 0;
		totalSites = quote.SBQQ__Opportunity2__r.Care_Home_Sites__c != NULL ? totalSites +(Integer)quote.SBQQ__Opportunity2__r.Care_Home_Sites__c : totalSites;
		Map<id,list<SBQQ__QuoteLine__c>> parentQLIMapcntlr = new Map<id,list<SBQQ__QuoteLine__c>>();
		Map<id,id> parentProductIds = new Map<id,id>();
		Map<id,Service_Detail__c> productServiceDetailsMap = new Map<id,Service_Detail__c>();
		for( SBQQ__QuoteLine__c qli:quoteLine){
			if(qli.SBQQ__RequiredBy__c != null){
				if(parentQLIMapcntlr !=null && parentQLIMapcntlr.containsKey(qli.SBQQ__RequiredBy__c)){
					List<SBQQ__QuoteLine__c> tempQLI = parentQLIMapcntlr.get(qli.SBQQ__RequiredBy__c);
					tempQLI.add(qli);
					parentQLIMapcntlr.put(qli.SBQQ__RequiredBy__c,tempQLI);
					ParentProductIds.put(qli.SBQQ__Product__c,qli.id);
				}
				else{
					List<SBQQ__QuoteLine__c> newpQLI = new List<SBQQ__QuoteLine__c>();
					newpQLI.add(qli);
					parentQLIMapcntlr.put(qli.SBQQ__RequiredBy__c,newpQLI); 
				}
			}
			else{
				List<SBQQ__QuoteLine__c> newpQLI = new List<SBQQ__QuoteLine__c>();
				newpQLI.add(qli);
				parentQLIMapcntlr.put(qli.id,newpQLI);
				ParentProductIds.put(qli.SBQQ__Product__c,qli.id);
			}
		}
		parentQLIMap = parentQLIMapcntlr;
		listParentQLI = parentQLIMapcntlr.values();
		Map<string,string> productSTypeServiceDetailsMap = new Map<string,string>();
		serviceDetailsList =[SELECT id,Product__c,Service_Details__c,Type_of_Service__c,Billing_frequency__c,Name FROM Service_Detail__c WHERE Product__c in:ParentProductIds.keyset() /*OR Type_of_Service__c in:uniqueServiceType*/ ];
		
		for(Service_Detail__c sd:serviceDetailsList){
			productServiceDetailsMap.put(sd.Product__c ,sd);
			String idServiceType = sd.Product__c  +'-'+sd.Billing_frequency__c +'-'+ sd.Type_of_Service__c;
			String idBF = sd.Product__c  +'-'+sd.Billing_frequency__c ;
			productSTypeServiceDetailsMap.put(idServiceType,sd.Service_Details__c);
			productSTypeServiceDetailsMap.put(idBF,sd.Service_Details__c);
			productSTypeServiceDetailsMap.put(sd.Type_of_Service__c,sd.Service_Details__c);
			productSTypeServiceDetailsMap.put(sd.Type_of_Service__c+'_'+Sd.Name,sd.Service_Details__c);
		} 
		Map<id,list<wrapQLI>>  parentWQLICntrlMap = new Map<id,list<wrapQLI>>();
		string bfreq = '';
		for(id qliId:parentQLIMapcntlr.keyset()){
			
			for(SBQQ__QuoteLine__c sqLine:parentQLIMapcntlr.get(qliId)){

				if(sqLine.SBQQ__ProductName__c.contains('Surveillance Audit')){
					
					if(sqLine.SBQQ__RequiredBy__r.Billing_Frequency__c =='Variable' && sqLine.Billing_Frequency__c =='Monthly'){
						bfreq = 'Deposit Monthly';
						
						break;

					}
					else{
						bfreq = sqLine.Billing_Frequency__c;
					}

				}
			}
		
			List<SBQQ__QuoteLine__c> qliList =parentQLIMapcntlr.get(qliId);
			List<wrapQLI> wrapperQLIList = new  List<wrapQLI>();
			Boolean sdAssign = true;
			Integer listSize =qliList.size();
			Integer i =0;
			
			decimal totalRegPayment =0.0;
			decimal totalCC =0.0;
			decimal totalCCLis =0.0;
			decimal totalSA =0.0; 
			decimal totalSALis =0.0; 
			decimal totalCCRegPay =0.0;
			decimal totalSARegPay =0.0;
			
			for(SBQQ__QuoteLine__c qli :qliList){
				
				i++;
				if(qli.SBQQ__ProductCode__c != null && qli.SBQQ__ProductCode__c.contains('-AS'))
				{
					if(qli.SBQQ__ProductName__c.CONTAINS('Surveillance'))
					{
						 totalSA = totalSA + qli.SBQQ__CustomerPrice__c;
						 totalSALis = totalSALis + qli.SBQQ__ListPrice__c;
						 totalSARegPay = totalSARegPay + qli.Regular_Payment__c ;
						
					}
					else
					{
						totalCC = totalCC + qli.SBQQ__CustomerPrice__c;
						if(qli.SBQQ__ListPrice__c != null){
							totalCCLis = totalCCLis + qli.SBQQ__ListPrice__c;
						}
						totalCCRegPay = totalCCRegPay + qli.QMS_CPQ_Regular_Payment__c ;
					}
				}       
				if(qli.QMS_CPQ_Regular_Payment__c > 0){
					totalRegPayment =totalRegPayment+qli.QMS_CPQ_Regular_Payment__c;
				}
				if((qli.SBQQ__ProductCode__c != null && 
					!((qli.SBQQ__ProductCode__c.contains('ISO') || qli.SBQQ__ProductCode__c.contains('BS') || qli.SBQQ__ProductCode__c.contains('QMS-Connect-LO') ||  qli.SBQQ__ProductCode__c =='GDPR' || qli.SBQQ__ProductCode__c =='Business Continuity-CPQ-J' || !(parentproductcodes.containsKey(qli.Parent_product_name__c))) 
					&& qli.SBQQ__RequiredBy__r.SBQQ__Product__c == NULL)
					&& !qli.SBQQ__ProductCode__c.contains('-AS')) || qli.SBQQ__ProductName__c == System.label.Atlas_ISO_eLearning_Product || qli.SBQQ__ProductCode__c =='ISOtrain' || qli.SBQQ__ProductCode__c =='CyEss-QMS' || qli.SBQQ__ProductCode__c =='CyEssPlus-QMS' || qli.SBQQ__ProductCode__c =='CyEssSup-QMS')
					
				{
				 
					wrapQLI wQLI = new wrapQLI();
					wQLI.qli = qli;
					wQLI.qliSIize = listSize;
					wQLI.totalRegularPayment = totalRegPayment;
					wQLI.totalCCSAPrice      = qli.SBQQ__CustomerPrice__c;
					if(qli.SBQQ__RequiredBy__c != null && (qli.SBQQ__ProductName__c == 'Business Continuity Assesment Core' || qli.SBQQ__ProductName__c == System.label.Atlas_ISO_eLearning_Product || !(parentproductcodes.containsKey(qli.Parent_product_name__c)))){
					  wQLI.totalCCSARegularpayment = qli.QMS_CPQ_Regular_Payment__c;
					}
					else if(qli.SBQQ__ProductName__c == System.label.Atlas_ISO_eLearning_Product || qli.SBQQ__ProductCode__c =='ISOtrain' || qli.SBQQ__ProductCode__c =='CyEss-QMS' || qli.SBQQ__ProductCode__c =='CyEssPlus-QMS' || qli.SBQQ__ProductCode__c =='CyEssSup-QMS'){
					  wQLI.totalCCSARegularpayment = qli.QMS_CPQ_Regular_Payment__c;  
					}
					wQLI.Product = qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c != NULL ? qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c :qli.SBQQ__ProductName__c;
					string idService;
					Boolean productCon ;
					if(qli.Service__c == NULL){
						if(qli.SBQQ__ProductCode__c =='eLearning-CPQ-E'){
							idService = qli.SBQQ__Product__c +'-'+ 'Variable'+'-'+'Premium';
							
						}
						else{   
					   idService =(qli.SBQQ__ProductCode__c != null && qli.SBQQ__RequiredBy__r.SBQQ__Product__c != NULL && !qli.SBQQ__ProductCode__c.contains('GDPR-')? qli.SBQQ__RequiredBy__r.SBQQ__Product__c :qli.SBQQ__Product__c)+'-'+ qli.Billing_Frequency__c;
					}
					}
					else{
						productCon =uniqueServiceType.contains(qli.Service__c);
						if(productCon){
						   idService = qli.Service__c;
							if(qli.Service__c =='Upgrade'){
								idService = idService +'_'+ (qli.SBQQ__ProductName__c.contains('Upgrade – QMS Management System')? 'Upgrade – QMS Management System' :'Upgrade – Client Management System');
							} else if (qli.Service__c =='Additional Site Compliance audit – Existing Client'){
							   idService = idService +'_'+ (qli.SBQQ__ProductName__c.contains('Additional Site NBS Compliance Audit – Existing Client')? 'Additional Site NBS Compliance Audit – Existing Client' :'Additional Site Compliance Audit – Existing Client');
							}
						} else {
							idService =( qli.SBQQ__RequiredBy__r.SBQQ__Product__c != NULL &&  qli.Service__c !='Internal Audit Training'  ? qli.SBQQ__RequiredBy__r.SBQQ__Product__c :qli.SBQQ__Product__c)+'-'+  bfreq 
							+'-'+ qli.Service__c  ;
						}
					}

					if(productSTypeServiceDetailsMap.get(idService)!=NULL){
						wQLI.serviceDetails = productSTypeServiceDetailsMap.get(idService).replace('TermReplace','Contract Term:'+qli.QMS_Connect_Term__c);
					}
					wrapperQLIList.add(wQLI);
				}
			}
			if(listSize > 2 ){
			  if(qliList[1].Base_Product_Name__c == 'Consultancy & Certification')
					{
						wrapperQLIList[0].totalCCSAPrice = wrapperQLIList[0].qli.SBQQ__CustomerPrice__c + totalCC ;
						wrapperQLIList[0].totalCCSAPriceList = wrapperQLIList[0].qli.SBQQ__ListPrice__c + totalCCLis ;
						wrapperQLIList[0].totalCCSARegularpayment =  wrapperQLIList[0].qli.QMS_CPQ_Regular_Payment__c + totalCCRegPay ;
					}
					if(qliList[2].Base_Product_Name__c == 'Surveillance Audit'){
						
						wrapperQLIList[1].totalCCSAPrice =wrapperQLIList[1].qli.SBQQ__CustomerPrice__c + totalSA ;
						wrapperQLIList[1].totalCCSAPriceList =wrapperQLIList[1].qli.SBQQ__ListPrice__c + totalSALis ;
						wrapperQLIList[1].totalCCSARegularpayment =  wrapperQLIList[1].qli.QMS_CPQ_Regular_Payment__c + totalSARegPay ;
					}
			}
			if(wrapperQLIList.size()>0){
			 wrapperQLIList[0].totalRegularPayment = totalRegPayment;
			}
			
				parentWQLICntrlMap.put(qliId,wrapperQLIList);
		}
		parentWQLIList = parentWQLICntrlMap.values();
	}
	
	public class WrapQLI {
		public SBQQ__QuoteLine__c qli {get; set;}
		public String serviceDetails {get; set;} 
		public String product {get; set;}
		public Decimal totalRegularPayment {get; set;}
		public Decimal totalCCSAPrice {get; set;}
		public Decimal totalCCSAPriceList {get; set;}
		public Decimal totalCCSARegularpayment{get; set;}
		public Integer qliSIize {get; set;}
	}   
	
	
}