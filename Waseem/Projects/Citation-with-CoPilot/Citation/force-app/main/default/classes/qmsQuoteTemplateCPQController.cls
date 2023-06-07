public class qmsQuoteTemplateCPQController {
	public List<SBQQ__QuoteLine__c> quoteLineCert { get; set; }
	public List<SBQQ__QuoteLine__c> quoteLineAudit { get; set; }
	public SBQQ__Quote__c quote { get; set; }
	public Integer totalSites { get; set; }
	public String quoteGroup { get; set; }
	public String billingAddress { get; set; }
	public String multisiteAuditText { get; set; }
	public String multisiteCertText1 { get; set; }
	//The variables talks about whether the customer sites have Same Policy & Procedures
	public Boolean samepnp { get; set; }
	public Decimal serviceCostTotal { get; set; }
	public Decimal recurringServiceCostTotal { get; set; }
	private List<SBQQ__QuoteLine__c> quoteLine { get; set; }
	private Decimal totalamountAudit { get; set; }
	private Decimal additionAuditDays { get; set; }
	private Decimal auditDays { get; set; }
	private String certificationnamesAudit { get; set; }
	private Decimal totalDeposit { get; set; }
	private Integer additionalSites { get; set; }
	private Decimal primarySiteGapAnalysisdays { get; set; }
	private String certificationNames { get; set; }
	private String staffCount { get; set; }
	private String multisiteCertText2 { get; set; }
	private Decimal primaryAuditDays { get; set; }
	private Decimal primaryCertDays { get; set; }
	private Decimal multiSiteAuditDays { get; set; }
	private Decimal multiSiteCertDays { get; set; }

	public qmsQuoteTemplateCPQController() {
		TotalamountAudit = 0;
		TotalSites = 0;
		AdditionAuditDays = 0;
		TotalDeposit = 0;
		additionalSites = 0;
		primarySiteGapAnalysisdays = 0;
		Id quoteId = (Id) ApexPages.currentPage().getParameters().get('qid');
		quoteLineAudit = new List<SBQQ__QuoteLine__c>();
		quoteLineCert = new List<SBQQ__QuoteLine__c>();
		quoteGroup = '';
		BillingAddress = '';
		staffCount = '';
		multisiteCertText1 = ' ';
		multisiteCertText2 = ' ';
		multisiteAuditText = ' ';
		primaryAuditDays = 0;
		primaryCertDays = 0;
		multiSiteAuditDays = 0;
		multiSiteCertDays = 0;
		serviceCostTotal = 0;
		recurringServiceCostTotal = 0;
		samepnp = false;

		//Quote Line
		quoteLine = [
			SELECT Id, SBQQ__ListPrice__c, Service__c, SBQQ__BillingFrequency__c, Billing_Frequency__c, SBQQ__CustomerPrice__c, Custom_Discount_Amount__c, Presentation_Days__c, Audit_Days__c, Implementation_Days__c, Gap_Analysis_Days__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__Product__r.Description, SBQQ__ProductName__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Sites__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c, SBQQ__Quote__r.Primary_Site_Gap_Analysis_Days__c, Regular_Payment__c, Custom_Discount_Percentage__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Audit_Days__c, Deposit__c, SBQQ__Group__r.name, SBQQ__RequiredBy__c, SBQQ__Product__c, SBQQ__Product__r.name, SBQQ__Quote__r.SBQQ__Opportunity2__r.Same_Standard_On_All_Sites__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.QMS_Recurring_Service_Costs__c, SBQQ__Product__r.QMS_Description__c
			FROM SBQQ__QuoteLine__c
			WHERE SBQQ__Quote__c = :quoteId AND SBQQ__Group__r.SBQQ__Optional__c = FALSE
		];
		quote = [
			SELECT id, name, Account_Annual_Revenue__c, SBQQ__BillingStreet__c, SBQQ__BillingCity__c, Account_Total_Employees__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, Account_Name__c, SBQQ__Account__r.TotalNoUKoffices__c, SBQQ__Account__r.BillingStreet, SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingPostalCode, Staff__c, SBQQ__Account__r.TotalNoInternationalOffices__c, Primary_Site_Audit_Days__c, SBQQ__Account__r.name, SBQQ__Opportunity2__r.Audit_Days__c, SBQQ__Opportunity2__r.Sites__c, Created_Date__c, SBQQ__ExpirationDate__c, SBQQ__Opportunity2__r.No_Of_Staff__c, SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c, Primary_Site_Gap_Analysis_Days__c, SBQQ__Opportunity2__r.Care_Home_Sites__c
			FROM SBQQ__Quote__c
			WHERE id = :quoteId
		];

		Set<id> parentqlId = new Set<id>();
		for (SBQQ__QuoteLine__c ql : quoteLine) {
			parentqlId.add(ql.SBQQ__RequiredBy__c);
		}

		if (quote.SBQQ__Account__r.BillingStreet != null) {
			BillingAddress = quote.SBQQ__Account__r.BillingStreet + ',';
		}
		if (quote.SBQQ__Account__r.BillingCity != null) {
			BillingAddress = BillingAddress + quote.SBQQ__Account__r.BillingCity + ',';
		}
		if (quote.SBQQ__Account__r.BillingState != null) {
			BillingAddress = BillingAddress + quote.SBQQ__Account__r.BillingState + ',';
		}
		if (quote.SBQQ__Account__r.BillingPostalCode != null) {
			BillingAddress = BillingAddress + quote.SBQQ__Account__r.BillingPostalCode;
		}
		if (BillingAddress != null && BillingAddress.endsWith(',')) {
			BillingAddress = BillingAddress.removeEnd(',');
		}

		TotalSites = (Integer) quote.SBQQ__Opportunity2__r.Sites__c;
		AuditDays = quote.SBQQ__Opportunity2__r.Audit_Days__c;

		if (quote.SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c != null) {
			additionalSites = (Integer) quote.SBQQ__Opportunity2__r.Total_Additional_Sites_Visited__c;
		}
		if (quote.SBQQ__Opportunity2__r.Care_Home_Sites__c != null) {
			additionalSites = additionalSites + (Integer) quote.SBQQ__Opportunity2__r.Care_Home_Sites__c;
		}

		if (quote.Primary_Site_Audit_Days__c != null) {
			AdditionAuditDays = quote.SBQQ__Opportunity2__r.Audit_Days__c - quote.Primary_Site_Audit_Days__c;
		} else {
			AdditionAuditDays = quote.SBQQ__Opportunity2__r.Audit_Days__c;
		}

		set<id> dupProductsAudit = new Set<id>();
		set<id> dupProductsCert = new Set<id>();

		for (SBQQ__QuoteLine__c qli : quoteLine) {
			if (!parentqlId.contains(qli.id)) {
				if (quoteGroup == '') {
					quoteGroup = qli.SBQQ__Group__r.name;
				}

				samepnp = qli.SBQQ__Quote__r.SBQQ__Opportunity2__r.Same_Standard_On_All_Sites__c;
				if (qli.SBQQ__ProductName__c.Contains('Surveillance Audit') || qli.SBQQ__ProductName__c.Contains('QMS eLearning') || qli.SBQQ__ProductName__c.Contains('Annual Licence Fee') || qli.SBQQ__Product__r.QMS_Recurring_Service_Costs__c) {
					if (!dupProductsAudit.contains(qli.SBQQ__Product__C)) {
						quoteLineAudit.add(qli);
						recurringServiceCostTotal = calculatetotalCost(qli, recurringServiceCostTotal);

						dupProductsAudit.add(qli.SBQQ__Product__C);
					}
					if (qli.SBQQ__CustomerPrice__c != null && qli.SBQQ__CustomerPrice__c > 0) {
						TotalamountAudit = TotalamountAudit + qli.SBQQ__CustomerPrice__c;
					}
					if (qli.Deposit__c != null) {
						TotalDeposit = TotalDeposit + qli.Deposit__c;
					}
					if (!((CertificationnamesAudit == '') || (CertificationnamesAudit == null))) {
						CertificationnamesAudit = CertificationnamesAudit + ', ' + qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
					} else {
						CertificationnamesAudit = qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
					}
					if (qli.SBQQ__ProductName__c.contains('Multi-Site') && qli.Audit_Days__c > 0 && multiSiteAuditDays == 0) {
						multiSiteAuditDays = qli.Audit_Days__c;
					} else {
						if (primaryAuditDays == 0 && qli.Audit_Days__c > 0) {
							primaryAuditDays = qli.Audit_Days__c;
						}
					}
				}

				if (!qli.SBQQ__ProductName__c.Contains('Surveillance Audit')) {
					if (!dupProductsCert.contains(qli.SBQQ__Product__C)) {
						quoteLineCert.add(qli);
						serviceCostTotal = calculatetotalCost(qli, serviceCostTotal);
						dupProductsCert.add(qli.SBQQ__Product__C);
					}
					if (!((certificationNames == '') || (certificationNames == null))) {
						certificationNames = certificationNames + ', ' + qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
					} else {
						if (!(qli.SBQQ__RequiredBy__r == null)) {
							certificationNames = qli.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
						}
					}
					if (multiSiteCertDays == 0 && qli.SBQQ__ProductName__c.contains('Multi-Site') && qli.Implementation_Days__c > 0 && (qli.SBQQ__ProductName__c.contains('ISO') || qli.SBQQ__ProductName__c.contains('BS'))) {
						multiSiteCertDays = qli.Implementation_Days__c;
					} else {
						if (primaryCertDays == 0 && qli.Gap_Analysis_Days__c > 0 && (qli.SBQQ__ProductName__c.contains('ISO') || qli.SBQQ__ProductName__c.contains('BS'))) {
							primaryCertDays = qli.Gap_Analysis_Days__c;
						}
					}
				}
			}
		}

		if (additionalSites > 0) {
			multisiteCertText1 = 'For the ISO/BS service(s) listed, of the ' + TotalSites + ' sites being considered as part of this quotation, the head office and ' + additionalSites + ' other site(s) will need to be visited. in accordance with the ISO requirements, the Head office must complete the certification journey prior to the other site(s) being visited.';
			multisiteCertText2 = 'With respect to achieving your certification, the Head office will be required to complete the certification journey and be awarded their certification, prior to the other site(s) being visited.';
			multisiteAuditText = 'For the ISO/BS service(s) listed, each year the head office and ' + additionalSites + '  other site(s) will need to be audited. The additional site(s) being visited will change each year, to verify ongoing company-wide compliance with the requirements of the relevant Standard(s).';
		}
	}

	private decimal calculatetotalCost(SBQQ__QuoteLine__c quoteLine, decimal totalCost) {
		if (quoteLine.Regular_Payment__c != null && quoteLine.Regular_Payment__c > 0) {
			totalCost = quoteLine.Regular_Payment__c + totalCost;
		} else if (quoteLine.SBQQ__CustomerPrice__c != null && quoteLine.SBQQ__CustomerPrice__c > 0) {
			totalCost = quoteLine.SBQQ__CustomerPrice__c + totalCost;
		}
		return totalCost;
	}
}