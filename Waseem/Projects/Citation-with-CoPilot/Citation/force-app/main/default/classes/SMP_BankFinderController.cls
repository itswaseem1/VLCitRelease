global with sharing class SMP_BankFinderController 
{   
    global Income_Direct_Debit__c DDRecord {get;set;}

    global SMP_BankFinderController (ApexPages.StandardController sc)
    {
        ddRecord = (Income_Direct_Debit__c) sc.getRecord();
    }

    global PageReference start()
    {
        System.debug('#### get bankname first');

        String BankName = DDRecord.DD_Bank_Name__c;
        System.debug('#### BankNamee =' + BankName);

        DateTime lastmod =  DDRecord.LastModifiedDate;

        System.debug('#### lastmod =' + lastmod);

        if (BankName  == null || BankName == '' || lastmod > DateTime.Now().addDays(-1))
        {
            String newbankname = 'Error';
            DDRecord.DD_Bank_Name__c = newbankname;


            System.debug('#### about to get bank details');

            getbankdetailsandupdate();
        }

        return null;
    }

    global void getbankdetailsandupdate()
    {
        System.debug('#### getBankDetailsAndUpdate');

        String sortcode = ddRecord.DD_Bank_Sort_Code__c;
        String accountnumber = ddRecord.DD_Bank_Account_Number__c;

        System.debug('#### sortcode: ' + sortcode);
        System.debug('#### accountnumber: ' + accountnumber);

        try
        {      
            if (Schema.sObjectType.Income_Direct_Debit__c.fields.DD_Bank_Name__c.isUpdateable())
            {                 
                ddRecord.DD_Bank_Name__c = String.isBlank(ddRecord.DD_Bank_Name__c) ? 'Error' : ddRecord.DD_Bank_Name__c;
            }

            SMP_DDServiceBankAccountModel bankAccount = SMP_DDServiceHandler.getBankDetails(ddRecord.DD_Bank_Sort_Code__c, ddRecord.DD_Bank_Account_Number__c);

            if(bankAccount != null)
            {
                if(String.isNotBlank(bankAccount.Modulus_Check.Error))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, bankAccount.Modulus_Check.Error));
                }

                bankAccount.copyFieldsToDirectDebitRecord(ddRecord);
            }

            update ddRecord;                       
        }        
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 'There was a problem calling SmarterPay: ' + e.getMessage()));
        }
    }
}