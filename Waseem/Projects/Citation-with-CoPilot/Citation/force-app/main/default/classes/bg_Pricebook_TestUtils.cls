/********************************************************************************
* bg_Pricebook_TestUtils :
*
* Utility methods for Pricebook tests
*
* Created By: Jamie Wooley
* Created Date: 11-01-2015 
*
* Changes: MF 19-04-2017 - 	Term added to the Pricebook creation method as a default
*                           and an override for testing with different terms.
*********************************************************************************/
public with sharing class bg_Pricebook_TestUtils {
    
	public static Pricebook2 createPricebook(String i, Decimal maximum, Decimal minimum)
    {
    	return new Pricebook2(
    		Name = 'Term ' + i,
    		Annual_Turnover_Maximum__c = maximum,
    		Annual_Turnover_Minimum__c = minimum,
    		Term__c = '5',
            isActive = true
    	);
    }

    public static Pricebook2 createPricebook(String i, Decimal maximum, Decimal minimum, String termValue)
    {
    	return new Pricebook2(
    		Name = 'Term ' + i,
    		Annual_Turnover_Maximum__c = maximum,
    		Annual_Turnover_Minimum__c = minimum,
    		Term__c = termValue,
            isActive = true
    	);
    }

}