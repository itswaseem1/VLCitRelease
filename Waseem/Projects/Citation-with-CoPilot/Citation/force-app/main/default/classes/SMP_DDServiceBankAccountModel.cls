@JsonAccess(serializable='always' deserializable='always')
global class SMP_DDServiceBankAccountModel {
    
    @AuraEnabled global Modulus_Check Modulus_Check;

    @JsonAccess(serializable='always' deserializable='always')
    public class Modulus_Check {
		public Boolean AccountCodeOK;
		public String Error;
		public String Telephone;
		public String account_number;
		public String bank_address1;
		public String bank_address2;
		public String bank_address3;
		public String bank_address4;
		public String bank_addressPostCode;
		public String bank_addressTown;
		public String bank_name;
		public String branch_title;
		public Boolean credits_allowed;
		public Boolean direct_debit_Instruction_ok;
		public Boolean direct_debits;
		public String sort_code;
		public Boolean sort_code_ok;
	}

    global SMP_DDServiceBankAccountModel(){
        Modulus_Check = new Modulus_Check();
    }

    global static SMP_DDServiceBankAccountModel parse(String json)
    {
        System.debug('#### Parsing SMP_DDServiceBankAccountModel');
        System.debug('#### json: '+json);

        return (SMP_DDServiceBankAccountModel) System.JSON.deserialize(json, SMP_DDServiceBankAccountModel.class);
    }

    global String compileBankAddress()
    {
        String address = '';

        if(String.isNotBlank(Modulus_Check.bank_address1)){
            address = Modulus_Check.bank_address1;            
        }

        if(String.isNotBlank(Modulus_Check.bank_address2)){            
            address += ', ' + Modulus_Check.bank_address2;
        }

        if(String.isNotBlank(Modulus_Check.bank_address3)){            
            address += ', ' + Modulus_Check.bank_address3;
        } 

        if(String.isNotBlank(Modulus_Check.bank_address4)){            
            address += ', ' + Modulus_Check.bank_address4;
        }

        System.Debug('#### address: ' + address);
        return address;
    }

    global void copyFieldsToDirectDebitRecord(Income_Direct_Debit__c directDebit)
    {
        directDebit.DD_Account_Number_OK__c = Modulus_Check.AccountCodeOK;
        directDebit.DD_Sort_Code_OK__c = Modulus_Check.sort_code_ok; 
        directDebit.DD_OK__c = Modulus_Check.direct_debits;
        directDebit.DD_Bank_Name__c = Modulus_Check.bank_name;
        directDebit.DD_Branch_Name__c = Modulus_Check.branch_title;
        directDebit.DD_Bank_Address__c =  compileBankAddress();
        directDebit.DD_Bank_City__c = Modulus_Check.bank_addressTown;
        directDebit.DD_Bank_Postcode__c = Modulus_Check.bank_addressPostCode;
        directDebit.DD_Bank_Phone__c = Modulus_Check.Telephone;         
    }
/*
    global void copyFieldsToDirectCreditRecord(Income_Direct_Credit__c directCredit)
    {
        directCredit.Account_Number_OK__c = Modulus_Check.AccountCodeOK;
        directCredit.Sort_Code_OK__c = Modulus_Check.sort_code_ok; 
        directCredit.Credit_OK__c = Modulus_Check.credits_allowed;
        directCredit.Bank_Name__c = Modulus_Check.bank_name;
        directCredit.Branch_Name__c = Modulus_Check.branch_title;
        directCredit.Branch_Address__c =  compileBankAddress();
        directCredit.Branch_City__c = Modulus_Check.bank_addressTown;
        directCredit.Branch_Postcode__c = Modulus_Check.bank_addressPostCode;
        directCredit.Branch_Phone__c = Modulus_Check.Telephone;         
    }*/
}