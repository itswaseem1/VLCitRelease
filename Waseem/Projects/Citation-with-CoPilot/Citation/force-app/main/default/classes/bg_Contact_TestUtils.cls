/********************************************************************************
* bg_Contact_TestUtils :
*
* Utility methods for Contact tests
*
* Created By: Jamie Wooley
* Created Date: 15-03-2017 
*
* Changes:
*********************************************************************************/
public with sharing class bg_Contact_TestUtils {
	public static Contact createContact(String i, String accountId)
    {
    	return new Contact(
    		LastName = 'test ' + i,
    		AccountId = accountId,
    		Email = 'test@test.com'
    	);
    }
}