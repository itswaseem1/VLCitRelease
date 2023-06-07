public class bg_FmIntOpportunityWrapper
{
    //Wrapper field                                         //Mapped To field in FM

    /*
    *   Mapped from Opportunity Header
    */
    public String OppId {get;set;}                          //  sf_ID_opportunity_item
    public String AccountId {get;set;}                      //  sf_ID_account
    public String ContactId {get;set;}                      //  sf_ID_contact
    public Boolean ContractSigned {get;set;}                //  CCF_Received
    public Date CustomerSignedDate {get;set;}               //  ccf_received_date
    public String CertReason {get;set;}                     //  Cert_reason
    public Date NewServiceFormReturnedDate {get;set;}       //  Client_Form
    public Boolean NewServiceFormReturned {get;set;}            //  Client_Form_Rec
    public String OfficeAdvisor {get;set;}                  //  Office_Advisor
    public String ReferenceNumber {get;set;}                //  SF_Reference

    /*
    *   Mapped from Line Level (both line types)
    */
    public String Type {get;set;}                           //  Service
    public Decimal ContractLengthYears {get;set;}           //  Contract_Duration
    public String FMEnquiryId {get;set;}                    //  k_ID_Enquiry
    public String CPQGroupId {get;set;}                     //  SF_ID_OppLineGroup
    public String LeadSource {get;set;}                     //  Enquiry_Source
    public String Field_Advisor {get;set;}                  //  salesperson
    public Boolean IsReduction {get;set;}                   //  is_Reduction__c
    public Decimal ReductionAmount {get;set;}               //  Reduction_Amount__c
    public Boolean IsDTR {get;set;}                         //  DTR__c
    public Boolean SalesVisit {get;set;}                    //  Sales_Visit__c
    public Date ContractEndDate {get;set;}                  //  Contract_End_Date__c
    public Boolean IsContractCancelled {get;set;}           //  Is_Contract_Cancelled__c
    public Decimal Deposit {get;set;}                       //  Deposit__c
    public Boolean DepositReceived {get;set;}               //  Deposit_Recived
    public Date DepositProformaDate {get;set;}              //  deposit_proforma_date
    public Date DepositReceivedDate {get;set;}              //  deposit_received_date
    public Boolean GenerateProforma {get;set;}              //  Genreate_Proforma
    public String FMFixedNotes {get;set;}                   //  Fixed_Notes__Enquiry_SFText

    public String AdditionalCompanyRegNum {get;set;}        //  AC_Comp_Reg
    public String AdditionalCompanyVATNo {get;set;}         //  AC_Comp_VAT
    public Boolean AdditionalCompany {get;set;}             //  Additional_Comp_Flag
    public String AdditionalCompanyName {get;set;}          //  Additional_Company_Name

    /*
    *   Audit Line details
    */
    public Decimal AuditDays {get;set;}                     //  Audit_Period
    public Decimal AuditFeeFM {get;set;}                    //  audit_price
    public String AuditLineId {get;set;}                    //  SF_ID_OppLineAudit

    /*
    *   Certifictation Line details
    */
    public Decimal CertificationDays {get;set;}             //  Consultation_Period
    public Decimal CertificationFee {get;set;}              //  Fee
    public Decimal PresentationDays {get;set;}              //  Presentation_Period
    public String Certification {get;set;}                  //  Product_Name
    public String CertLineId {get;set;}                     //  SF_ID_OppLineCert


    //Constructor for old world opportunities
    public bg_FmIntOpportunityWrapper(Opportunity opp) 
    {
        OppId = opp.Id;
        AccountId = opp.AccountId;
        ContactId = opp.Contact__c;
        ContractSigned = opp.Contract_Signed__c;
        CustomerSignedDate = opp.ECHO_Customer_Signed_Date__c;
        CertReason = opp.Cert_Reason__c;
        NewServiceFormReturnedDate = opp.New_Service_Form_Returned_Date__c;
        NewServiceFormReturned = opp.New_Service_Form_Returned__c;
        OfficeAdvisor = opp.Office_Advisor__c;
        ReferenceNumber = opp.Reference_Number__c;

        
        Type = opp.Type;
        ContractLengthYears = opp.Contract_Length_Years__c;
        FMEnquiryId = opp.FM_Opportunity_External_Id__c;
        //CPQGroupId = opp.
        LeadSource = opp.LeadSource;
        Field_Advisor = opp.Field_Advisor__c;
        IsReduction = opp.is_Reduction__c;
        ReductionAmount = opp.Reduction_Amount__c;
        IsDTR = opp.DTR__c;
        SalesVisit = opp.Sales_Visit__c;
        ContractEndDate = opp.Contract_End_Date__c;
        IsContractCancelled = opp.Is_Contract_Cancelled__c;
        Deposit = opp.Deposit__c;
        DepositReceived = opp.Deposit_Received__c;
        GenerateProforma = opp.Generate_Proforma__c;
        if (GenerateProforma)
        {
            //DepositProformaDate = opp.Deposit_Proforma_Date__c;
            DepositProformaDate = Date.Today();
        }
        DepositReceivedDate = opp.Deposit_Received_Date__c;
        FMFixedNotes = opp.FM_Fixed_Notes__c;

        AdditionalCompanyRegNum = opp.Additional_Company_Reg_No__c;
        AdditionalCompanyVATNo = opp.Additional_Company_VAT_No__c;
        AdditionalCompany = opp.Additional_Company__c;
        AdditionalCompanyName = opp.Additional_Company_Name__c;

        AuditDays = opp.Audit_Days__c;
        AuditFeeFM = opp.Audit_Fee_FM__c;

        CertificationDays = opp.Certification_Days__c;
        CertificationFee = opp.Certification_Fee__c;
        PresentationDays = opp.Presentation_Days__c;
        Certification = opp.Certification__c;
    }

    //Contstructor for new CPQ style opportunities
    public bg_FmIntOpportunityWrapper(Opportunity opp, List<OpportunityLineItem> oppLines)
    {
        OppId = opp.Id;
        
        FMEnquiryId = opp.FM_Opportunity_External_Id__c;
        
        AccountId = opp.AccountId;
        ContactId = opp.Contact__c;
        ContractSigned = opp.Contract_Signed__c;
        CustomerSignedDate = opp.ECHO_Customer_Signed_Date__c;
        CertReason = opp.Cert_Reason__c;
        NewServiceFormReturnedDate = opp.New_Service_Form_Returned_Date__c;
        NewServiceFormReturned = opp.New_Service_Form_Returned__c;
        OfficeAdvisor = opp.Office_Advisor__c;
        ReferenceNumber = opp.Reference_Number__c;

        LeadSource = opp.LeadSource; //KH
        Field_Advisor = opp.Field_Advisor__c; //KH

        String qmsCombinedFMFixedNotes = '';
        Decimal tempDeposit = 0.0;  Decimal tempTotalPresentationDays = 0.0;
        Decimal tempTotalAuditDays = 0.0; Decimal tempTotalCertDays = 0.0;
        Decimal tempTotalAuditFee = 0.0; Decimal tempTotalCertFee = 0.0;
        Decimal tempConnectFee = 0.0;
        for(OpportunityLineItem oppLine : oppLines)
        {
            if(oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.Family == 'Audit' || 
                oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.Family == 'Certification' || oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'One-Off')
            {
                //Type = oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c; //KH
                Type = oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Service_Type__c;
                
          //      ContractLengthYears = oppLine.SBQQ__QuoteLine__r.Term__c != null ? decimal.valueOf(oppLine.SBQQ__QuoteLine__r.Term__c)/12 : 0;  //SMc
                
          
               ContractLengthYears = oppLine.SBQQ__QuoteLine__r.Group_Term__c != null ? oppLine.SBQQ__QuoteLine__r.Group_Term__c/12 : 0;  
               
               
                FMEnquiryId = oppLine.FM_Enquiry_Id__c;
                CPQGroupId = oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c;
                //LeadSource = oppLine.Lead_Source__c;
                Field_Advisor = oppLine.FM_Field_Advisor__c;
                IsReduction = oppLine.is_Reduction__c;
                ReductionAmount = oppLine.Reduction_Amount__c;
                IsDTR = oppLine.DTR__c;
                SalesVisit = oppLine.Sales_Visit__c;
                ContractEndDate = oppLine.Contract_End_Date__c;
                IsContractCancelled = oppLine.Is_Contract_Cancelled__c;
                Deposit = oppLine.Deposit__c;
                DepositReceived = oppLine.Deposit_Received__c;
                
                DepositProformaDate = oppLine.Deposit_Proforma_Date__c;             
                //DepositProformaDate = Date.Today();KH
                DepositReceivedDate = oppLine.Deposit_Received_Date__c;

                if (opp.Generate_Proforma__c == true)
                {
                    GenerateProforma = true;
                }
                else 
                {
                    GenerateProforma = false;
                }
                //GenerateProforma = oppLine.Generate_Proforma__c;  KH
                FMFixedNotes = oppLine.FM_Fixed_Notes__c;
                
                /*
                AdditionalCompanyRegNum = oppLine.Additional_Company_Reg_No__c;
                AdditionalCompanyVATNo = oppLine.Additional_Company_VAT_No__c;
                AdditionalCompany = oppLine.Additional_Company__c;
                AdditionalCompanyName = oppLine.Additional_Company_Name__c;
                */
                //Certification = oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c;
                Certification = oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.FM_Product_Name__c;
                
                if(oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.Family == 'Audit')
                {
                    /*
                    *   Audit Line details
                    */
                    AuditDays = oppLine.Audit_Days__c;
                    AuditFeeFM = oppLine.Audit_Fee__c;
                    AuditLineId = oppLine.Id;
                    
                }

                if(oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.Family == 'Certification')
                {
                    /*
                    *   Certifictation Line details
                    */
                    CertificationDays = oppLine.Cert_Days__c;
                    CertificationFee = oppLine.Cert_Fee__c;
                    PresentationDays = oppLine.Presentation_Days__c;
                    CertLineId = oppLine.Id;
                }
                
                //CPQ QMS Integration Mapping updates
                if(oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == 'QMS' || oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'One-Off' ) {
                    
                    if(oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__BillingFrequency__c == 'One-Off' && oppLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c == null) {
                        AuditLineId = oppLine.Id;
                    }
                    
                    if(oppLine.Gap_Analysis_Days__c != NULL) {
                        tempTotalCertDays = oppLine.Gap_Analysis_Days__c + tempTotalCertDays;
                    }

                    CertificationDays = tempTotalCertDays;
                    
                    if(oppLine.Cert_Fee__c != NULL)
                        CertificationFee = oppLine.Cert_Fee__c;
                    
                    if(oppLine.Presentation_Days__c  != NULL) {
                        tempTotalPresentationDays = oppLine.Presentation_Days__c + tempTotalPresentationDays;
                    }
                    
                    PresentationDays = tempTotalPresentationDays;
                        
                    if(oppLine.Audit_Days__c  != NULL) {
                        tempTotalAuditDays = oppLine.Audit_Days__c + tempTotalAuditDays;
                    }

                    AuditDays = tempTotalAuditDays;
                                        
                    Type = oppLine.SBQQ__QuoteLine__r.SBQQ__Product__r.Service_Type__c;
                    
                    if(oppLine.SBQQ__QuoteLine__r.Deposit__c != null) {
                        tempDeposit = oppLine.SBQQ__QuoteLine__r.Deposit__c + tempDeposit;
                    }
                    
                    Deposit = tempDeposit;
                    
                    if(oppLine.FM_Fixed_Notes__c != null) {
                        qmsCombinedFMFixedNotes = oppLine.FM_Fixed_Notes__c + '\n' + qmsCombinedFMFixedNotes;
                    }
                    
                    Certification = oppLine.Certification__c;
                    FMFixedNotes = qmsCombinedFMFixedNotes;
                    ContractLengthYears = oppLine.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c/12;
                    
                    if(oppLine.Product2.QMS_Base_Product_Name__c == 'Surveillance Audit' || oppLine.Product2.QMS_Base_Product_Name__c == 'Multi-site Surveillance') {
                        tempTotalAuditFee = oppLine.SBQQ__QuoteLine__r.SBQQ__CustomerPrice__c + tempTotalAuditFee;
                        AuditFeeFM = tempTotalAuditFee;
                    }
                    else if(oppLine.Product2.ProductCode.contains('CECT-AL')) {
                        AuditFeeFM = oppLine.Audit_Fee__c;
                    }
                    
                    if(oppLine.Product2.QMS_Base_Product_Name__c == 'Consultancy & Certification' || oppLine.Product2.QMS_Base_Product_Name__c == 'Multi-site Compliance') {
                        tempTotalCertFee = oppLine.SBQQ__QuoteLine__r.SBQQ__CustomerPrice__c + tempTotalCertFee;
                        CertificationFee = tempTotalCertFee;
                    }
                    else if(oppLine.Product2.ProductCode.contains('CECT-CPQ-D')) {
                        tempConnectFee = oppLine.Consultancy_Fee__c + tempConnectFee;
                        CertificationFee = tempConnectFee;
                    }                    
                }
            }
        }
    }
}