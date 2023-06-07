public class iHASCOLmsAccountStatus {
    public String EventType;
    public String Status;
	public String LmsId;
    public String AccountId;
    
    public iHASCOLmsAccountStatus(Account Ac, String EvType){
        this.EventType = EvType;
        this.Status = Ac.iHASCO_Finance_Status__c;
        this.LmsId = Ac.LMS_ID__c;
        this.AccountId = Ac.id;
    }
}