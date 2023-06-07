public interface  ICPQQuoteService {
    
    /*
    *  Create the CPQ Quote , Quote Lines and Group , Links them
    *  all respectively
    *  License Model is Pricing model Ex: 'Open license' Which is 
    * 	works based on Credits .
    *  term is a Subscription years
    *  noOfUnits  is a no of users or credits based on LicenseModel
	*/
    String createQuickQuote(String licenseModel, String productId, String term, String noOfUnits, String oppoId);
}