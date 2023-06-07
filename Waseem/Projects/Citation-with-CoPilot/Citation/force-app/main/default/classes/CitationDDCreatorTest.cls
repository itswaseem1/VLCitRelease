@isTest
private class CitationDDCreatorTest {

    static testMethod void TestConstructorAndDateMethod() { 
        
        PAYJOB1__Payonomy_Handler_Class__c phc1 = new PAYJOB1__Payonomy_Handler_Class__c(PAYJOB1__Description__c='BACS DD Extraction',PAYJOB1__Class_Name__c='PAYFISH3.BACS.BACSDDExtractionJobHandler',PAYJOB1__Active__c=true) ;
        insert phc1 ;
        
        PAYJOB1__Payonomy_Job__c pj1 = new PAYJOB1__Payonomy_Job__c(PAYJOB1__Payonomy_Handler_Class__c=phc1.id,PAYJOB1__Description__c='BACS (Fixed Width) test job') ;
        
        insert pj1 ;
        
        //PAYJOB1__Payonomy_Job__c  pj1 = [select id from payjob1__payonomy_job__c where name = 'PJ-0'] ;  
        PAYJOB1__Payonomy_Job_File__c pjf1 = new PAYJOB1__Payonomy_Job_File__c() ;  
        pjf1.payjob1__payonomy_job__c = pj1.id ;  
        pjf1.PAYJOB1__File_Name__c = 'TestFile.csv' ;
     
        pjf1.BACS_Creation_date__c = date.today() ;
        pjf1.BACS_Expiration_date__c = date.today() ;
        pjf1.BACS_Processing_date__c = date.today() ;
        
        insert pjf1 ;  
        Test.setCurrentPageReference(new PageReference('Page.CreateDDBankFile'));
        
        ApexPages.currentPage().getParameters().put('Id', pjf1.id);
        
        date d = date.today() ;
        
        String YY = String.valueOf(d.year()).substring(2,4); 
        String DOY = String.valueOf(d.dayOfYear()).LeftPad(3,'0');
        String DateValue = YY + DOY; 
        DateValue = DateValue.leftpad(6) ;
        string testvalue = '' ;
        
        test.starttest() ;
            CitationDDCreator cDDC = new CitationDDCreator(new ApexPages.StandardController(pjf1)) ;
            testvalue = cDDC.getbYYDDD_date(d)  ;
            
            
        test.stoptest() ;
        
        
        system.assertEquals(DateValue,testValue) ;
        
        

    }
    
    static testMethod void CreateFile1() { 
        
        
        
        PAYJOB1__Payonomy_Handler_Class__c phc1 = new PAYJOB1__Payonomy_Handler_Class__c(PAYJOB1__Description__c='BACS DD Extraction',PAYJOB1__Class_Name__c='PAYFISH3.BACS.BACSDDExtractionJobHandler',PAYJOB1__Active__c=true) ;
        insert phc1 ;
        
        PAYJOB1__Payonomy_Job__c pj1 = new PAYJOB1__Payonomy_Job__c(PAYJOB1__Payonomy_Handler_Class__c=phc1.id,PAYJOB1__Description__c='BACS (Fixed Width) test job') ;
        
        insert pj1 ;  
        PAYJOB1__Payonomy_Job_File__c pjf1 = new PAYJOB1__Payonomy_Job_File__c() ;  
        pjf1.payjob1__payonomy_job__c = pj1.id ;  
        pjf1.PAYJOB1__File_Name__c = 'TestFile.csv' ;
        pjf1.PAYFISH3__Item_Total__c = 3 ;
      
        pjf1.PAYFISH3__FTA_Sub_Type__c = 'TESTING' ;
        pjf1.BACS_Creation_date__c = date.today() ;
        pjf1.BACS_Expiration_date__c = date.today() ;
        pjf1.BACS_Processing_date__c = date.today() ;
        insert pjf1 ;  
        
        List<PAYACCVAL1__Bank_Account__c> BankAccounts = new List<PAYACCVAL1__Bank_Account__c>() ;

        BankAccounts.add(new PAYACCVAL1__Bank_Account__c(PAYFISH3__Account_Name__c='this is a very long account name which should hopfully get truncated and not crash the code',PAYACCVAL1__Account_Number__c='07806039',PAYACCVAL1__Sort_Code__c='938611',PAYFISH3__Originator__c=true)) ;
        BankAccounts.add(new PAYACCVAL1__Bank_Account__c(PAYFISH3__Account_Name__c='this is a very long account name which should hopfully get truncated and not crash the code',PAYACCVAL1__Account_Number__c='61487175',PAYACCVAL1__Sort_Code__c='404636',PAYFISH3__Originator__c=true)) ;

        Insert BankAccounts ;

        Test.setCurrentPageReference(new PageReference('Page.CreateDDBankFile'));
        ApexPages.currentPage().getParameters().put('Id', pjf1.id);
        string bdy = '' ;
        bdy += '93861107806039 00N23425312132132          32100abcd                        00000001Dummy accountabcde\n' ;
        bdy += '93861107906039 01913213264646464              0abbb                        00000002Dummy accountabcdg\n' ;
        bdy += '93861107706039 0Z522222224325436              0eeee                        00000003Dummy accountzzzzz\n';
        /* next line should generate an amount...?*/
        bdy += '40463661487175 01723425312132132          12300abcd                        00000001Citation Limited  \n'; 
        bdy += '40463661487175 01713213264646464          22500abbb                        00000002Citation Limited  \n';
        bdy += '40463661487175 00N93861107806039              7Dummy account               00000011Citation Limited  \n';
        bdy += '40463661487175 01705050512121212          10000TDW                         00000026Citation Limited  \n';
        bdy += '40463661487175 01702030423232323          15000TSB                         00000027Citation Limited  \n';
        bdy += '40463661487175 01703040534343434          15000TCD1                        00000028Citation Limited  \n';
        bdy += '40463661487175 00N09090945454545             14TCD3                        00000029Citation Limited  \n';
        
        
        attachment att = new attachment(parentId = pjf1.id, name='test',body=blob.valueof(bdy)) ;
        insert att ;
        
        system.debug('Bank Accounts ' + BankAccounts ) ;
        
        test.starttest() ;
            system.debug('-------------------->' + pjf1.id) ;
            
            CitationDDCreator cDDC = new CitationDDCreator(new ApexPages.StandardController(pjf1)) ;
            pagereference p = cDDC.createFile() ;
            
        test.stoptest() ;
        string attNameTest = pj1.id + att.name + '_AUDDIS_CIT' ;
        list<attachment> attList = [select id,name,body from attachment where name =  :attNameTest] ;
        list<attachment> attList1 = [select id,name,body from attachment where name =  :attNameTest] ;
        system.debug('There are ' + attList1.size() + 'Attachments') ;
        system.assertNotEquals(0,attList.size()) ;
        
        system.assertEquals('/' + pjf1.id,p.getURL() ) ;
        
        string[] FileArray = attList[0].body.tostring().split('\n') ;
        
        system.assertEquals('VOL1',FileArray[0].Substring(0,4)) ; 
            system.assertEquals('HDR1',FileArray[1].Substring(0,4)) ; 
            system.assertEquals('HDR2',FileArray[2].Substring(0,4)) ; 
            
       system.assertEquals('UHL1',FileArray[3].Substring(0,4)) ; 
     
     
      system.assertEquals('EOF1',FileArray[FileArray.size()-3].Substring(0,4)) ; 
       system.assertEquals('EOF2',FileArray[FileArray.size()-2].Substring(0,4)) ; 
        system.assertEquals('UTL1',FileArray[FileArray.size()-1].Substring(0,4)) ; 
            
            system.debug('String Length ---> ' + FileArray[0].length()) ;
            
        if(FileArray[0].substring(41,47) != '') {
            system.debug(FileArray[0].substring(41,47)) ;
            system.debug(FileArray[0]) ;
            system.AssertEquals('      ',FileArray[0].substring(31,37)) ;
        }
        else
        {
        //  system.AssertEquals()
        }
        for(integer i=0;i<FileArray.size();i++) {
            if(i==0) /* First line - must be a VOL1 */
             {
                                
            }
            
        }
        
        system.debug('||XX||' + attList[0].body.tostring()) ;

    }
    
    
  
    
}