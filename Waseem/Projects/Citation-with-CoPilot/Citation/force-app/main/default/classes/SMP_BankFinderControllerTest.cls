/**
* @description Tests for BankFinderController
*/
@isTest
private class SMP_BankFinderControllerTest
{    
    /**
    * @description Sets the response from the Bank Val idation Service.
    */
    private static void setFakeResponse(integer statusCode)
    {
        String sBodyText = '';

        if(statusCode == 200){
            sBodyText = '{"Modulus_Check":{"AccountCodeOK":true,"Error":"","Telephone":"0345 7345345","account_number":"55779911","bank_address1":"","bank_address2":"","bank_address3":"","bank_address4":"","bank_addressPostCode":"LE87 2BB","bank_addressTown":"Leicester","bank_name":"BARCLAYS BANK PLC","branch_title":"1 CHURCHILL  PLACE","credits_allowed":true,"direct_debit_Instruction_ok":true,"direct_debits":true,"sort_code":"200000","sort_code_ok":true}}';
        }
        else if (statusCode == 300){
            sBodyText = '{"Modulus_Check":{"AccountCodeOK":false,"Error":"","Telephone":"0345 7345345","account_number":"55779911","bank_address1":"","bank_address2":"","bank_address3":"","bank_address4":"","bank_addressPostCode":"LE87 2BB","bank_addressTown":"Leicester","bank_name":"BARCLAYS BANK PLC","branch_title":"1 CHURCHILL  PLACE","credits_allowed":false,"direct_debit_Instruction_ok":false,"direct_debits":false,"sort_code":"200000","sort_code_ok":false}}';
        }
        else if (statusCode == 400){
            sBodyText = '{"Modulus_Check":{"AccountCodeOK":true,"Error":"","Telephone":"0345 7345345","account_number":"55779911","bank_address1":"","bank_address2":"","bank_address3":"","bank_address4":"","bank_addressPostCode":"LE87 2BB","bank_addressTown":"Leicester","bank_name":"BARCLAYS BANK PLC","branch_title":"1 CHURCHILL  PLACE","credits_allowed":false,"direct_debit_Instruction_ok":false,"direct_debits":false,"sort_code":"200000","sort_code_ok":true}}';
        }

        SMP_Test_HttpRestCallOutMock fakeResponse = new SMP_Test_HttpRestCallOutMock(200, sBodyText);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    } 
    
    @isTest static void BankFinder_TestStart_BankAccountValid()
    {
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c();   
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';  
        insert testDirectDebit;

        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
        
        Test.StartTest();
        setFakeResponse(200);
        controller.start();
        Test.StopTest();
        
        System.assertEquals('1 CHURCHILL  PLACE', testDirectDebit.DD_Branch_Name__c );
        System.assertEquals('BARCLAYS BANK PLC', testDirectDebit.DD_Bank_Name__c);
        System.assertEquals(true, testDirectDebit.DD_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Sort_Code_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Account_Number_OK__c);    
    }

    /**
    * @description Checks that the correct values are updated for a valid bank account.
    */
    @isTest static void BankFinder_GetBankDetailsAndUpdate_BankAccountValid()
    {
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c();        
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';      
  
        insert testDirectDebit;

        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
        
        Test.StartTest();
        setFakeResponse(200);
        controller.getBankDetailsAndUpdate();
        Test.StopTest();

        testDirectDebit = [SELECT Id, DD_Account_Number_OK__c, DD_Sort_Code_OK__c, DD_OK__c, DD_Bank_Name__c, DD_Branch_Name__c 
                            FROM Income_Direct_Debit__c 
                            WHERE Id = :testDirectDebit.Id];

        System.assertEquals('1 CHURCHILL  PLACE', testDirectDebit.DD_Branch_Name__c );
        System.assertEquals('BARCLAYS BANK PLC', testDirectDebit.DD_Bank_Name__c);
        System.assertEquals(true, testDirectDebit.DD_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Sort_Code_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Account_Number_OK__c);     
    } 

    /**
    * @description Checks that the correct values are updated on an invalid bank account.
    */
    @isTest static void BankFinder_GetBankDetailsAndUpdate_BankAccountNotValid()
    {
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c();
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';   
        insert testDirectDebit;

        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
        
        Test.StartTest();
        setFakeResponse(400);
        controller.getBankDetailsAndUpdate();
        Test.StopTest();

        testDirectDebit = [SELECT Id, DD_Account_Number_OK__c, DD_Sort_Code_OK__c, DD_OK__c, DD_Bank_Name__c, DD_Branch_Name__c  
                            FROM Income_Direct_Debit__c 
                            WHERE Id = :testDirectDebit.Id];

        System.assertEquals('1 CHURCHILL  PLACE', testDirectDebit.DD_Branch_Name__c );
        System.assertEquals('BARCLAYS BANK PLC', testDirectDebit.DD_Bank_Name__c);
        System.assertEquals(false, testDirectDebit.DD_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Sort_Code_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Account_Number_OK__c);       
    }

    /**
    * @description Checks that the correct values are updated for an account that is unable to use direct debits.
    */
    @isTest static void BankFinder_GetBankDetailsAndUpdate_DirectDebitsNotAllowed()
    {
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c(); 
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';   
        insert testDirectDebit;

        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));

        Test.StartTest();
        setFakeResponse(300);
        controller.getBankDetailsAndUpdate();
        Test.StopTest();

        testDirectDebit = [SELECT Id, DD_Account_Number_OK__c, DD_Sort_Code_OK__c, DD_OK__c, DD_Bank_Name__c, DD_Branch_Name__c  
                            FROM Income_Direct_Debit__c 
                            WHERE Id = :testDirectDebit.Id];

        System.assertEquals('1 CHURCHILL  PLACE', testDirectDebit.DD_Branch_Name__c );
        System.assertEquals('BARCLAYS BANK PLC', testDirectDebit.DD_Bank_Name__c);
        System.assertEquals(false, testDirectDebit.DD_OK__c);
        System.assertEquals(false, testDirectDebit.DD_Sort_Code_OK__c);
        System.assertEquals(false, testDirectDebit.DD_Account_Number_OK__c);     
    }

    @isTest static void BankFinder_SaveDirectDebit_ErroneousData()
    {     
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c(); 
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';        
        insert testDirectDebit;

        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
        
        try
        {
            controller.ddRecord.DD_Bank_Account_Number__c = null;
            controller.ddRecord.DD_Bank_Sort_Code__c = null;
            controller.getBankDetailsAndUpdate();
        }
        catch(Exception e)
        {
            System.assert(false, 'The test failed as there was an exception in the method.');
        }   
    }


    /*@isTest static void CreditBankFinder_TestStart_BankAccountValid()
    {
        Income_Direct_Credit__c testDirectCredit = new Income_Direct_Credit__c();        
        testDirectCredit.Account_Number__c = '18273645';
        testDirectCredit.Sort_Code__c = '162534';        
        insert testDirectCredit;

        SMP_CreditBankFinderController controller = new SMP_CreditBankFinderController(new ApexPages.StandardController(testDirectCredit));
        
        Test.StartTest();
        setFakeResponse(200);
        controller.start();
        Test.StopTest();

        System.assertEquals('1 CHURCHILL  PLACE', testDirectCredit.Branch_Name__c);
        System.assertEquals('BARCLAYS BANK PLC', testDirectCredit.Bank_Name__c);
        System.assertEquals(true, testDirectCredit.Credit_OK__c);
        System.assertEquals(true, testDirectCredit.Sort_Code_OK__c);
        System.assertEquals(true, testDirectCredit.Account_Number_OK__c);    
    }*/

    /**
    * @description Checks that the correct values are updated for a valid bank account.
    */
    /*@isTest static void CreditBankFinder_GetBankDetailsAndUpdate_BankAccountValid()
    {
        Income_Direct_Credit__c testDirectCredit = new Income_Direct_Credit__c();        
        testDirectCredit.Account_Number__c = '18273645';
        testDirectCredit.Sort_Code__c = '162534';        
        insert testDirectCredit;

        SMP_CreditBankFinderController controller = new SMP_CreditBankFinderController(new ApexPages.StandardController(testDirectCredit));
        
        Test.StartTest();
        setFakeResponse(200);
        controller.getBankDetailsAndUpdate();
        Test.StopTest();

        testDirectCredit = [SELECT Id, Account_Number_OK__c, Sort_Code_OK__c, Credit_OK__c, Bank_Name__c, Branch_Name__c 
                            FROM Income_Direct_Credit__c 
                            WHERE Id = :testDirectCredit.Id];

        System.assertEquals('1 CHURCHILL  PLACE', testDirectCredit.Branch_Name__c);
        System.assertEquals('BARCLAYS BANK PLC', testDirectCredit.Bank_Name__c);
        System.assertEquals(true, testDirectCredit.Credit_OK__c);
        System.assertEquals(true, testDirectCredit.Sort_Code_OK__c);
        System.assertEquals(true, testDirectCredit.Account_Number_OK__c);     
    } */

    /**
    * @description Checks that the correct values are updated on an invalid bank account.
    */
    /*@isTest static void CreditBankFinder_GetBankDetailsAndUpdate_BankAccountNotValid()
    {
        Income_Direct_Credit__c testDirectCredit = new Income_Direct_Credit__c();        
        testDirectCredit.Account_Number__c = '18273645';
        testDirectCredit.Sort_Code__c = '162534';        
        insert testDirectCredit;

        SMP_CreditBankFinderController controller = new SMP_CreditBankFinderController(new ApexPages.StandardController(testDirectCredit));
        
        Test.StartTest();
        setFakeResponse(400);
        controller.getBankDetailsAndUpdate();
        Test.StopTest();

        testDirectCredit = [SELECT Id, Account_Number_OK__c, Sort_Code_OK__c, Credit_OK__c, Bank_Name__c, Branch_Name__c 
                            FROM Income_Direct_Credit__c 
                            WHERE Id = :testDirectCredit.Id];

        System.assertEquals('1 CHURCHILL  PLACE', testDirectCredit.Branch_Name__c);
        System.assertEquals('BARCLAYS BANK PLC', testDirectCredit.Bank_Name__c);
        System.assertEquals(false, testDirectCredit.Credit_OK__c);
        System.assertEquals(true, testDirectCredit.Sort_Code_OK__c);
        System.assertEquals(true, testDirectCredit.Account_Number_OK__c);     
    }*/

    /**
    * @description Checks that the correct values are updated for an account that is unable to use direct debits.
    */
    /*@isTest static void CreditBankFinder_GetBankDetailsAndUpdate_DirectDebitsNotAllowed()
    {
        Income_Direct_Credit__c testDirectCredit = new Income_Direct_Credit__c();        
        testDirectCredit.Account_Number__c = '18273645';
        testDirectCredit.Sort_Code__c = '162534';        
        insert testDirectCredit;

        SMP_CreditBankFinderController controller = new SMP_CreditBankFinderController(new ApexPages.StandardController(testDirectCredit));

        Test.StartTest();
        setFakeResponse(300);
        controller.getBankDetailsAndUpdate();
        Test.StopTest();

        testDirectCredit = [SELECT Id, Account_Number_OK__c, Sort_Code_OK__c, Credit_OK__c, Bank_Name__c, Branch_Name__c 
                            FROM Income_Direct_Credit__c 
                            WHERE Id = :testDirectCredit.Id];

        System.assertEquals('1 CHURCHILL  PLACE', testDirectCredit.Branch_Name__c);
        System.assertEquals('BARCLAYS BANK PLC', testDirectCredit.Bank_Name__c);
        System.assertEquals(false, testDirectCredit.Credit_OK__c);
        System.assertEquals(false, testDirectCredit.Sort_Code_OK__c);
        System.assertEquals(false, testDirectCredit.Account_Number_OK__c);     
    }

    @isTest static void CreditBankFinder_SaveDirectDebit_ErroneousData()
    {     
        Income_Direct_Credit__c testDirectCredit = new Income_Direct_Credit__c();        
        testDirectCredit.Account_Number__c = '18273645';
        testDirectCredit.Sort_Code__c = '162534';        
        insert testDirectCredit;

        SMP_CreditBankFinderController controller = new SMP_CreditBankFinderController(new ApexPages.StandardController(testDirectCredit));
        
        try
        {
            controller.creditRecord.Account_Number__c = null;
            controller.creditRecord.Sort_Code__c = null;
            controller.getBankDetailsAndUpdate();
        }
        catch(Exception e)
        {
            System.assert(false, 'The test failed as there was an exception in the method.');
        }   
    }*/
}