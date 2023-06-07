public interface ILeadService  extends IDomainService {
    
    /* 
     * This method is to find the duplicate Leads and update Status as Duplicate found
     *  if any contact or account or Lead has same email or email domain
     * (exception for free domains)
     */
    void updateDuplicateLead(List<Lead> leads, Id iHASCOLeadRecordType);

}