@isTest
Public class ClusterManagerTest {
		
    @isTest static void ClusterManagerUnitTest(){

        Map<Id, Cluster__c> mapClusterAccount = new Map<Id,Cluster__c> ();
        List<Account> listAccount = new List<Account> ();
        
        cluster__c cls  = TestFactory.createCluster('Customer Success Manager 2',  'OX, MK, NN, CV, LE, DE, NG, S, LN', 'Somu' );
        insert cls;
        
        cluster__c cls1  = TestFactory.createCluster('Customer Success Manager 5',  'CA, LA, FY, PR, BB, OL, BL, WN, L, WA, M, SK', 'Somu' );
        insert cls1;
        
        Account acc = TestFactory.createAccount('PROFESSIONAL ACTIVITIES','WA5 3TU',6,1);
        acc.Type = 'Client';
        
        Account acc1 = TestFactory.createAccount('PROFESSIONAL ACTIVITIES','OX5 3TU',6,1);
        acc1.Type = 'Client';

        listAccount.add(acc);
        listAccount.add(acc1);
        if (!listAccount.isEmpty()) {
            Insert listAccount;
        }
        
        ClusterManager.getclusterName(listAccount);
        
      	Account updatedAcc = [Select Id, Name, BillingPostalCode, Postcode_District__c,Cluster__c, Type  from Account Where BillingPostalCode = 'OX5 3TU'];
        System.debug('updatedAcc::=='+updatedAcc);
            
     //   system.assertequals(updatedAcc.Cluster__c,'Customer Success Manager 2');

    }
    
    @isTest static void ClusterManagerByRole(){

        Map<Id, Cluster__c> mapClusterAccount = new Map<Id,Cluster__c> ();
        List<Account> listAccount = new List<Account> ();
        
        cluster__c cls  = TestFactory.createClusterWithRole('Customer Success Manager 2',  'OX, MK, NN, CV, LE, DE, NG, S, LN', 'Somu' , 'Renewal' );
        insert cls;
        
        cluster__c cls1  = TestFactory.createClusterWithRole('Customer Success Manager 5',  'CA, LA, FY, PR, BB, OL, BL, WN, L, WA, M, SK','Somu' , 'Renewal' );
        insert cls1;
        
        Account acc = TestFactory.createAccount('PROFESSIONAL ACTIVITIES','WA5 3TU',6,1);
        acc.Type = 'Client';
        
        Account acc1 = TestFactory.createAccount('PROFESSIONAL ACTIVITIES','OX5 3TU',6,1);
        acc1.Type = 'Client';

        listAccount.add(acc);
        listAccount.add(acc1);
        if (!listAccount.isEmpty()) {
            Insert listAccount;
        }
        
        ClusterManager.getclusterNameByRole(listAccount, DataConstants.ClUSTER_ROLE_RENEWAL);
        
      	Account updatedAcc = [Select Id, Name, BillingPostalCode, Postcode_District__c,Cluster__c, Type  from Account Where BillingPostalCode = 'OX5 3TU'];
        System.debug('updatedAcc::=='+updatedAcc);
            
    //    system.assertequals(updatedAcc.Cluster__c,'Customer Success Manager 2');

    }
    
    
}