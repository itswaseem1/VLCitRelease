public with sharing class TriggerAccountHandler {
    
    /* CONSTRUCTOR */
    private TriggerAccountHandler() {
        
    }

    private static TriggerAccountHandler instance;
    public static TriggerAccountHandler getInstance() {
        if (instance == null) {
            instance = new TriggerAccountHandler();
        }
        return instance;
    }

    /* PUBLIC METHODS */

    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    * @date 11/02/2019 Suresh Somu Added AccountManager.updateNewOrExistingAccCluster(False, newObjects); 
            to replace cluster Workflow rules to update Cluster field
    */
    public void onBeforeInsert(final List<Account> newObjects) {
        
        recordType supplierRecordType = [select id from recordtype where name = 'Supplier' and sObjectType = 'Account'] ;
        list<c2g__codaGeneralLedgerAccount__c> TradeCreditorsGLAList = [select id from c2g__codaGeneralLedgerAccount__c where c2g__ExternalId__c= :System.label.Supplier_Account_Payable_Control] ;
        list<c2g__codaTaxCode__c> InputVatCodeList = [select id from c2g__codaTaxCode__c where c2g__ExternalId__c = :System.label.Input_Vat_Code] ;
        list<c2g__codaTaxCode__c> OutputVatCodeList = [select id from c2g__codaTaxCode__c where c2g__ExternalId__c = :System.label.Output_Vat_Code] ;
       
        for(Account a : newObjects)
        {
            if(a.recordTypeId == supplierRecordType.id)
            {
                system.debug('This is a supplier record!!!') ;
                if(a.c2g__CODABillingMethod__c == null) {a.c2g__CODABillingMethod__c = System.label.Billing_Method;} 
                if(a.c2g__CODAAccountTradingCurrency__c == null) {a.c2g__CODAAccountTradingCurrency__c = System.label.Account_Currency;} 
                if(a.c2g__CODATaxCalculationMethod__c == null) {a.c2g__CODATaxCalculationMethod__c = System.label.Tax_Calculation_Method;} 
                if(a.c2g__CODAVATStatus__c == null) {a.c2g__CODAVATStatus__c = System.label.VAT_Status;} 
                if(a.c2g__CODAECCountryCode__c == null) {a.c2g__CODAECCountryCode__c =System.label.Country_Code;} 
                if(a.c2g__CODAAccountsPayableControl__c == null && TradeCreditorsGLAList.size() >0) {a.c2g__CODAAccountsPayableControl__c = TradeCreditorsGLAList[0].id ;} 
                if(a.c2g__CODAInputVATCode__c == null && InputVatCodeList.size() > 0) {a.c2g__CODAInputVATCode__c = InputVatCodeList[0].id;} 
                if(a.c2g__CODAOutputVATCode__c == null && OutputVatCodeList.size() >0) {a.c2g__CODAOutputVATCode__c = OutputVatCodeList[0].id;} 
            }
            
            if(a.Contact_Strategy_Territory__c != null)
            {
                a.Cluster__c = a.Contact_Strategy_Territory__c;
            }
        }    
    }
      
    /**
    * @author Nimil Christopher
    * @date 29 July 2013
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    * @date 11/02/2019 Suresh Somu Added AccountManager.updateNewOrExistingAccCluster(False, newObjects); 
            to replace cluster Workflow rules to update Cluster field
    */
    public void onBeforeUpdate(final Map<Id, Account> newObjectsMap, final Map<Id, Account> oldObjectsMap)
    {      
        for(Account a: newObjectsMap.values()){
            if(a.Contact_Strategy_Territory__c != oldObjectsMap.get(a.id).Contact_Strategy_Territory__c){
                a.Cluster__c = a.Contact_Strategy_Territory__c;
            }
        }               
        iHASCOAccountServices.updatePurgatoryStatus(newObjectsMap,oldObjectsMap);         
    }
}