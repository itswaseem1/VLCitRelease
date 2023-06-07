public class AdvisorAvailabilityWrapper implements Comparable {
 
    public Id advisorId;
	public dateTime refDateTime;
 
    public AdvisorAvailabilityWrapper(Id adId, dateTime rfDateTime) {
        this.advisorId = adId;
        refDateTime = rfDateTime;
        
    }
 
    public Integer compareTo(Object objToCompare) {
        AdvisorAvailabilityWrapper aaObj = (AdvisorAvailabilityWrapper)objToCompare;
        if (refDateTime == aaObj.refDateTime){
            return 0;
        }
        else if (refDateTime > aaObj.refDateTime){
            return 1;
        }
        else{
            return -1;        
        }
    }
}