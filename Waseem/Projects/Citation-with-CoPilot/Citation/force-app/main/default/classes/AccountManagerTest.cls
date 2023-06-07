@isTest
Public class AccountManagerTest {
        
    @isTest static void AccountManagerUnitTest(){

        Map<Id,Account> mapAccount = new Map<Id,Account> ();
        List<Account> listAccount = new List<Account> ();
        List<Account> updatelist = new List<Account> ();

        Account acc = TestFactory.createAccount('PROFESSIONAL ACTIVITIES','WA5 3TU',6,1);
        acc.Type = 'Client';
        
        Account acc1 = TestFactory.createAccount('PROFESSIONAL ACTIVITIES','mk5 3TU',6,1);
        acc1.Type = 'Client';

        listAccount.add(acc);
        listAccount.add(acc1);
        if (!listAccount.isEmpty()) {
            Insert listAccount;
        }
        
        cluster__c cls  = TestFactory.createCluster('IRM1',  'RG, GU, PO, SL, TW, UB, HA', 'Somu' );
        insert cls;

        for(account ac : [Select Id, BillingPostalCode, Postcode_District__c,Cluster__c, Type  from Account Where Type =:'Client']){
            mapAccount.put(ac.Id, ac);
            if(ac.Postcode_District__c == 'WA'){
                ac.BillingPostalCode = 'UB5 3TU';
                ac.Cluster__c = cls.Name;
                updatelist.add(ac);
            }
        }
        Test.startTest();
            
            update updatelist;
            
            AccountManager.updateExistingAccCluster(updatelist,mapAccount );
            
            Account updatedAcc = [Select Id, BillingPostalCode, Postcode_District__c,Cluster__c, Type  from Account Where BillingPostalCode = 'UB5 3TU'];
            system.assertequals(updatedAcc.Cluster__c,'IRM1');
            

        Test.stopTest();
    }
    
    
}