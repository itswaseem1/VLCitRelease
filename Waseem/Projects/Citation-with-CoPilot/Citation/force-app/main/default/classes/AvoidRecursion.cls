public Class AvoidRecursion{
    private static boolean firstRun = true;
    private static boolean DM3_firstRun = true;
    private static boolean CLIH_firstRun = true;
    private static boolean contractActivation=true;
    private static boolean RunTer_isFirstRun = true;
    private static boolean qlih_updateCPQQuote_firstRun = true;
    private static boolean bg_SBQQQuote_ai_FirstRun = true;
    private static boolean qmsRPI=true;
    private static boolean cPQQuoteLineUpdateCoreProductfirstRun = true;
    private static boolean sfCPQQuotefirstRun = true;
    private static boolean opportunityLineItemAfterfirstRun = true;
    private static boolean opportunityLineItemAfterInsertfirstRun = true;
    private static boolean bgOpportunityLineItembifirstRun = true;
    public static boolean isFirstRun(){
        if(firstRun){
            firstRun = false;
            return true;
        }else{
            return firstRun;
        }
    }
    public static boolean CLIH_isFirstRun(){
        if(CLIH_firstRun){
            CLIH_firstRun = false;
            return true;
        }else{
            return CLIH_firstRun;
        }
    }
    public static boolean DM3_isFirstRun(){
        if(DM3_firstRun){
            DM3_firstRun = false;
            return true;
        }else{
            return DM3_firstRun;
        }
    }
    public static boolean contractActivate_isFirstRun(){
        if(contractActivation){
            contractActivation = false;
            return true;
        }else{
            return contractActivation;
        }
    }
    
    public static boolean RunTer_isFirstRun(){
        if(RunTer_isFirstRun){
            RunTer_isFirstRun = false;
            return true;
        }else{
            return RunTer_isFirstRun;
        }
    }
    public static boolean qlih_updateCPQQuote_isFirstRun(){
        if(qlih_updateCPQQuote_firstRun){
            qlih_updateCPQQuote_firstRun = false;
            return true;
        }else{
            return qlih_updateCPQQuote_firstRun;
        }
    }
    public static boolean bg_SBQQQuote_ai_isFirstRun(){
        if(bg_SBQQQuote_ai_FirstRun){
            bg_SBQQQuote_ai_FirstRun = false;
            return true;
        }else{
            return bg_SBQQQuote_ai_FirstRun;
        }
    }
    public static boolean QMSRPI_isFirstRun(){
        if(qmsRPI){
            qmsRPI = false;
            return true;
        }else{
            return qmsRPI;
        }
    }
    public static boolean iscPQQuoteLineUpdateCoreProductfirstRun(){
        if(cPQQuoteLineUpdateCoreProductfirstRun){
            cPQQuoteLineUpdateCoreProductfirstRun = false;
            return true;
        }else{
            return cPQQuoteLineUpdateCoreProductfirstRun;
        }
    }   
    public static boolean issfCPQQuotefirstRun(){
        if(sfCPQQuotefirstRun){
            sfCPQQuotefirstRun = false;
            return true;
        }else{
            return sfCPQQuotefirstRun;
        }
    }
    public static boolean isopportunityLineItemAfterfirstRun(){
        if(opportunityLineItemAfterfirstRun){
            opportunityLineItemAfterfirstRun = false;
            return true;
        }else{
            return opportunityLineItemAfterfirstRun;
        }
    }
    public static boolean isopportunityLineItemAfterInsertfirstRun(){
        if(opportunityLineItemAfterInsertfirstRun){
            opportunityLineItemAfterInsertfirstRun = false;
            return true;
        }else{
            return opportunityLineItemAfterInsertfirstRun;
        }
    }
    public static boolean isbgOpportunityLineItembifirstRun(){
        if(bgOpportunityLineItembifirstRun){
            bgOpportunityLineItembifirstRun = false;
            return true;
        }else{
            return bgOpportunityLineItembifirstRun;
        }
    }
}