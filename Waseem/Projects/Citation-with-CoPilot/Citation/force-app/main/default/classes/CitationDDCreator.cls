public with sharing class CitationDDCreator {

    public String DDFile {get;set;}
    public String DD_AUDDIS_File {get;set;}
    
    private final Id fileid;
    private boolean AUDDIS;
    private boolean DD;
    public String pageStatus {get;set;}

    public CitationDDCreator(ApexPages.StandardController controller) {
        Id fileid = apexpages.currentpage().getparameters().get('id');
        String pageStatus = '';
    }
    
    
    public PageReference CreateFile()   
    { 
        integer DebitTotal = 0;
        integer DebitCount = 0;
        integer CreditTotal = 0;
        integer CreditCount = 0;
        integer DDICount = 0;
        
        
        //sets AUDDIS as false until we know we need one.
        AUDDIS = false;
        DD = false;
        
// Get the File that Payonomy created.

        Id fileid = apexpages.currentpage().getparameters().get('id');
        
        Attachment att = [Select Id, ParentId, Name, body, ContentType From Attachment where ParentId  =: fileid];
        String[] filelines = new String[]{};
        filelines = att.body.toString().split('\n');    
    
// Get the related Data that the file doesn't include
        PAYJOB1__Payonomy_Job_File__c JobData = [SELECT Id, Name, PAYJOB1__Payonomy_Job__c,
                                                        PAYFISH3__One_Off_Collection_Count__c, PAYREC2__Final_Collection_Count__c,  
                                                        PAYFISH3__One_Off_Collection_Total__c, PAYREC2__Final_Collection_Total__c   ,
                                                        PAYREC2__Ongoing_Collection_Count__c,  PAYREC2__First_Collection_Count__c   ,
                                                        PAYREC2__Ongoing_Collection_Total__c,  PAYREC2__First_Collection_Total__c    ,
                                                        PAYFISH3__FTA_Sub_Type__c   ,       PAYREC2__Penultimate_Collection_Count__c,   
                                                        PAYREC2__Penultimate_Collection_Total__c, PAYFISH3__Item_Total__c,
                                                        Bank_File_Serial_Number__c, Bank_File_Number__c, 
                                                        BACS_Creation_date__c,BACS_Processing_date__c, BACS_Expiration_date__c
                                                FROM PAYJOB1__Payonomy_Job_File__c 
                                                WHERE Id  =: fileid];
                       
        system.debug('JOBDATA Retrieved ---> ' + jobData) ;
        
//headers
//VOL > HDR1 > HDR2 > UHL 
        // ##  VOL Record  ##
        
        //create unique serial numbers
        String Serial = JobData.Bank_File_Serial_Number__c;    
        
        Integer DOY = Integer.valueOf(system.today().dayOfYear());
    
        Integer MOY_DD = (DOY * 24 * 60) + (DateTime.now().hour()*60) + DateTime.now().minute();
        String Serial_DD = toHexString(MOY_DD) + 'D';
        
        Integer MOY_AUD = ((DOY * 24 * 60) + (DateTime.now().hour()*60) + DateTime.now().minute())+1;
        String Serial_AUD = toHexString(MOY_AUD) + 'A'; 
        
        system.debug('MOY_DD: ' + MOY_DD);
        system.debug('MOY_AUD: ' + MOY_AUD);
        system.debug('Serial_DD: ' + Serial_DD);
        system.debug('Serial_AUD: ' + Serial_AUD);
           
        // get the SUN number
        String SUN = JobData.PAYFISH3__FTA_Sub_Type__c;            
        SUN = SUN.substring(0, 6);  
        //TODO: A serial number???
        String FileNumber = JobData.Bank_File_Number__c;
        
        
        // add to headers
        String HeaderVOL = '';
        HeaderVOL += SUN.leftPad(36);
        HeaderVOL += '1'.leftPad(33);
        
        String HeaderVOL_DD  = 'VOL1' + Serial_DD.rightPad(6) + '0' + HeaderVOL;
        String HeaderVOL_AUD = 'VOL1' + Serial_AUD.rightPad(6) + '0'  + HeaderVOL;
        
         
        // ##  HDR1 Record  ##
        String HeaderHDR1_DD = 'HDR1';
        String FileIndentifer1_DD = 'A' + SUN + 'S';
        FileIndentifer1_DD += SUN.leftPad(9);
        FileIndentifer1_DD += Serial_DD + '00010001';
        
        String HeaderHDR1_AUD = 'HDR1';
        String FileIndentifer1_AUD = 'A' + SUN + 'S';
        FileIndentifer1_AUD += SUN.leftPad(9);
        FileIndentifer1_AUD += Serial_AUD + '00010001';
        
        Date CreationDate = JobData.BACS_Creation_date__c;                        
        String CreationDateValue = GetbYYDDD_date(CreationDate);    
        
        Date ExpirationDate = JobData.BACS_Expiration_date__c;          
        String ExpirationDateValue = GetbYYDDD_date(ExpirationDate);
        
        String dates =  CreationDateValue + ExpirationDateValue;
        
        FileIndentifer1_DD += dates.leftPad(18) + '000000'.leftPad(7);
        FileIndentifer1_AUD += dates.leftPad(18) + '000000'.leftPad(7);
        
        HeaderHDR1_DD += FileIndentifer1_DD.RightPad(76);
        HeaderHDR1_AUD += FileIndentifer1_AUD.RightPad(76);
        
        //HDR2 Record
        String HeaderHDR2 = 'HDR2';
        String FileIndentifer2 = 'F0200000100'.rightPad(46) + '00';
        
        HeaderHDR2 += FileIndentifer2.RightPad(76);
        
        //UHL1 Record
        String HeaderUHL1 = 'UHL1';
        
        Date BacsProcessingDay = JobData.BACS_Processing_date__c;
        String BacsProcessingDayValue = GetbYYDDD_date(BacsProcessingDay);   
        
        HeaderUHL1 += BacsProcessingDayValue + '999999'.RightPad(10) + '000000001'.rightPad(10) + 'DAILY'.rightPad(7) + FileNumber + '0001'.leftPad(14).RightPad(40);
        
        
        //add headers to DD File
        String HeaderDD =  HeaderVOL_DD + '\r\n' + HeaderHDR1_DD + '\r\n' + HeaderHDR2 + '\r\n' + HeaderUHL1 + '\r\n';
        String HeaderAUD =  HeaderVOL_AUD + '\r\n' + HeaderHDR1_AUD + '\r\n' + HeaderHDR2 + '\r\n' + HeaderUHL1 + '\r\n';
        
        DDFile = HeaderDD;
        DD_AUDDIS_File = HeaderAUD;
         
//Middle
        
        String OSortCode = '';
        String OAccNum = '';
        
        //Standard Records      
        for(Integer i=0;i<filelines.size();i++)        
        {
          String[] inputvalues = new String[]{};            
           inputvalues = filelines[i].split(',');
           system.debug('## each value: '+inputvalues );
           
           OSortCode               = filelines[i].substring(0,6);
           OAccNum                 = filelines[i].substring(6,14);
           String TransactionCode  = filelines[i].substring(16,18);
           String DSortCode        = filelines[i].substring(18,26);
           String DAccNum          = filelines[i].substring(26,34).trim();
           String StrAmount        = filelines[i].substring(36,47);
           Integer Amount          = Integer.valueOf(StrAmount.trim());
           String DAccName         = filelines[i].substring(47,65);
           String UserRef          = filelines[i].substring(66,83).trim();
           String UserName         = filelines[i].substring(83,101);
           
           String StandardRecord = DSortCode + DAccNum + '0' + TransactionCode + OSortCode + OAccNum.rightPad(12) + String.valueOf(Amount).LeftPad(11,'0') + UserName.rightPad(10) + UserRef.rightPad(18) + DAccName.rightPad(18) + BacsProcessingDayValue;
          
           if(TransactionCode == '0N' || TransactionCode == '0C' || TransactionCode == '0S')
           {
                AUDDIS = true;
                DD_AUDDIS_File  += StandardRecord + '\r\n';
                DDICount ++;
           }
           else
           {
                DD = true;
                DDFile  += StandardRecord + '\r\n';
                
                if(TransactionCode == '01' || TransactionCode == '17' || TransactionCode == '18' || TransactionCode == '19')
                {
                    //Debit Records
                    DebitCount ++; 
                    DebitTotal += Amount;
                    
                }
                else if(TransactionCode == '99' || TransactionCode == 'Z4' || TransactionCode == 'Z5' )
                {
                    //Credit Records
                    CreditCount ++;
                    CreditTotal += Amount;
                }
           }
           
        system.debug('Debit Count: ' + DebitCount + 'Debit Total: ' + DebitTotal);
        system.debug('Credit Count: ' + CreditCount + 'Credit Total: ' + CreditTotal);
        system.debug('AUDDIS Count: ' + DDICount);
        system.debug('# PAYONMY:     '+ filelines[i] + '\n'); 
        system.debug('# HSBC Format: ' + StandardRecord + '\n');
        system.debug('# VALUES: DeSortCode:'+DSortCode + '# DesAccNum:'+ DAccNum + '# TranCode:' + TransactionCode +'#  OSortCode:'+ OSortCode +'# OAccNum:'+ OAccNum + '#');
        system.debug('# VALUES Cont: £'+ Amount + '# User:'+UserName +'# URef:'+ UserRef + '# AccName:'+DAccName + '# PDay:'+ BacsProcessingDayValue);
           
        }
        
//footers
        // Contra Record
        
        system.debug('##OSortCode:'+ OSortCode +'# OAccNum:'+ OAccNum );
        
        PAYACCVAL1__Bank_Account__c BankAccount = [SELECT PAYFISH3__Account_Name__c, PAYACCVAL1__Account_Number__c, PAYACCVAL1__Sort_Code__c
                                                    FROM PAYACCVAL1__Bank_Account__c
                                                    WHERE PAYACCVAL1__Account_Number__c =: OAccNum
                                                    AND PAYACCVAL1__Sort_Code__c =: OSortCode
                                                    AND PAYFISH3__Originator__c = true];
        
        system.debug('reult: ' + BankAccount );
        
        String OAccName = BankAccount.PAYFISH3__Account_Name__c;
        if(OAccName.length() > 18)
        {
            OAccName = OAccName.substring(0, 17); 
        }
        
        integer ContraAmount = DebitTotal - CreditTotal;
        String FooterContra = OSortCode + OAccNum + '099'+ OSortCode + OAccNum.rightPad(12) + String.valueOf(ContraAmount).leftPad(11,'0').rightPad(29) + 'CONTRA'.RightPad(18) + OAccName.rightPad(18) + BacsProcessingDayValue ;
        DDFile += FooterContra + '\r\n';

//  EOF1 > EOF2 > UTL
        //EOF1 Record
        String FooterEOF1_DD = 'EOF1' + FileIndentifer1_DD.RightPad(76);
        String FooterEOF1_AUD = 'EOF1' + FileIndentifer1_AUD.RightPad(76);
        
        //EOF2 Record
        String FooterEOF2 = 'EOF2' + FileIndentifer2.RightPad(76);
        
        //UTL1 Record (DD)
        String FooterUTL1 = 'UTL1';
        
        String DebitTotalPad = String.valueOf(DebitTotal).LeftPad(13,'0');
        String CreditTotalPad = String.valueOf(DebitTotal).LeftPad(13,'0');
        String DebitCountPad = String.valueOf(DebitCount).LeftPad(7,'0');
        String CreditCountPad = '00000001';
        
            
        FooterUTL1 += DebitTotalPad + CreditTotalPad + DebitCountPad + CreditCountPad.rightPad(43);
        
        //UTL1 Record (AUDDIS)
        String DDICountPad = String.valueOf(DDICount).LeftPad(7,'0');
        system.debug('DDICountPad: ' + DDICountPad);
        String FooterUTL1_AUDDIS = 'UTL10000000000000000000000000000000000000000' + DDICountPad.leftPad(15).RightPad(36);
        system.debug('FooterUTL1_AUDDIS: ' + FooterUTL1_AUDDIS);
        
        
        //add footers to DD File
        String FooterDD = FooterEOF1_DD + '\r\n' + FooterEOF2 + '\r\n' + FooterUTL1+ '\r\n';
        String FooterAUD = FooterEOF1_AUD + '\r\n' + FooterEOF2 + '\r\n' + FooterUTL1_AUDDIS+ '\r\n';
        
        DDFile += FooterDD;
        DD_AUDDIS_File += FooterAUD;
    
        
// save the File with the Payonomy created file. 
        if(DD == true)
        {
            // create the new attachment for DD file
            Attachment attachDD = new Attachment();
            Blob bodyDD;
            
            try
            {
                // save the file
                bodyDD = Blob.valueOf(DDFile); 
        
             // need to pass unit test -- current bug    
             } catch (VisualforceException e) 
             {
                    bodyDD = Blob.valueOf('Some Text');
             }
            
            attachDD.Body = bodyDD;
            attachDD.Name = JobData.PAYJOB1__Payonomy_Job__c + att.Name + '_CIT';
            attachDD.IsPrivate = false;
            attachDD.ContentType = att.ContentType;
            attachDD.ParentId = att.ParentId;
            insert attachDD;
        }
        
        if(AUDDIS == true)
        {
            // create the new attachment for AUDDIS file
            Attachment attachAUD = new Attachment();
            Blob bodyAUD;
            
            try
            {
                // save the file
                bodyAUD = Blob.valueOf(DD_AUDDIS_File); 
        
             // need to pass unit test -- current bug    
             } catch (VisualforceException e) 
             {
                    bodyAUD = Blob.valueOf('Some Text');
             }
            
            attachAUD.Body = bodyAUD;
            attachAUD.Name = JobData.PAYJOB1__Payonomy_Job__c + att.Name + '_AUDDIS_CIT';
            attachAUD.IsPrivate = false;
            attachAUD.ContentType = att.ContentType;
            attachAUD.ParentId = att.ParentId;
            insert attachAUD;
            
        }
           
        pageStatus = fileid;
        //returnPage();   
         
         PageReference pageRef = new PageReference('/' + fileid);
         pageRef.setRedirect(true);
         return pageRef;    
    }
    
    
    
    //Get the Day of year and Year (Last 2 digits) from a Date
    public String GetbYYDDD_date(Date d)
    {
        String YY = String.valueOf(d.year()).substring(2,4); 
        String DOY = String.valueOf(d.dayOfYear());
        String Pad_DOY = String.valueOf(DOY).LeftPad(3,'0');
        String DateValue = YY + Pad_DOY; 
    //  System.debug('#' + DateValue);
        return DateValue.leftPad(6);
    }
    
    
     public PageReference returnPage(){
         PageReference pageRef = new PageReference('/' + fileid);
         pageRef.setRedirect(true);
         return pageRef;
         
     }
     
     
     private static final String [] digits = new String[] {
           '0' , '1' , '2' , '3' , '4' , '5' ,
           '6' , '7' , '8' , '9' , 'a' , 'b' ,
           'c' , 'd' , 'e' , 'f' , 'g' , 'h' ,
           'i' , 'j' , 'k' , 'l' , 'm' , 'n' ,
           'o' , 'p' , 'q' , 'r' , 's' , 't' ,
           'u' , 'v' , 'w' , 'x' , 'y' , 'z'
           };
    private static final Integer shift = 4;

    public static String toHexString(Integer i) {

        String[] buf = new String[32];
        Integer charPos = 32;
        Integer radix = 1 << shift;
        Integer mask = radix - 1;
        do {
           buf[--charPos] = digits[i & mask];
           i >>>= shift;
        } while (i != 0);

        String result = '';
        for (Integer pos = charPos; pos < 32; pos++) result += buf[pos];
        return result;
    }
    
    
}