/********************************************************************************
* bg_Quote_Helper :
*
* Helper class for the Quote object.
*
* Created By: Jamie Wooley
* Created Date: 03-02-2016
*
* Changes:
*
*********************************************************************************/
public class bg_Quote_Helper {

	private static Set<Id> newQuoteIds = new Set<Id>();
    
	public static Set<Id> getNewQuoteIds() {
        return newQuoteIds;
	}
    
	public static void addQuoteIds(Set<Id> ids) {
		newQuoteIds.addAll(ids);
	}
	  
    public static void removeAllNewQuoteIds() {
        newQuoteIds.clear();
    }

}