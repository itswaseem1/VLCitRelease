/********************************************************************************
* bg_User_TestUtils :
*
* Utility methods for User tests
*
* Created By: Jamie Wooley
* Created Date: 11-01-2015 
*
* Changes:
*********************************************************************************/
public with sharing class bg_User_TestUtils {

    public static User createQMSSalesUser(String randomVal)
    {
        String alias = 'tuser' + randomVal;
        alias = alias.length() > 8 ? alias.right(8) : alias;
        return new User(Username= 'test.user' + randomVal + '@citation.co.uk', Email = 'test.user' + randomVal + '@citation.co.uk', Lastname = 'user' + randomVal, Firstname = 'test' + randomVal, Alias = alias, 
                                   CommunityNickname = 'tuser0' + randomVal, ProfileId = [select id from Profile where name = 'QMS Sales Team'].Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', 
                                   UserPermissionsMobileUser = false, isActive = true, QMS_Renewals_Owner__c = true);
    }
    public static User createiHASCOUser(String randomVal)
    {
        String alias = 'tuser' + randomVal;
        alias = alias.length() > 8 ? alias.right(8) : alias;
        return new User(Username= 'test.user' + randomVal + '@citation.co.uk', Email = 'test.user' + randomVal + '@citation.co.uk', Lastname = 'user' + randomVal, Firstname = 'test' + randomVal, Alias = alias, 
                                   CommunityNickname = 'tuser0' + randomVal, ProfileId = [select id from Profile where name = 'System Administrator'].Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', 
                                   UserPermissionsMobileUser = false, isActive = true);
    }

    public static User createBusinessSolutionsTeamUser(String randomVal)
    {
        String alias = 'tuser' + randomVal;
        alias = alias.length() > 8 ? alias.right(8) : alias;
        return new User(Username= 'test.user' + randomVal + '@citation.co.uk', Email = 'test.user' + randomVal + '@citation.co.uk', Lastname = 'user' + randomVal, Firstname = 'test' + randomVal, Alias = alias, 
                                   CommunityNickname = 'tuser0' + randomVal, ProfileId = [select id from Profile where name = 'Business Solutions Team'].Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', 
                                   UserPermissionsMobileUser = false, isActive = true);
    }

    public static User createCitationContactCentreBDCUser(String randomVal)
    {
        String alias = 'tuser' + randomVal;
        alias = alias.length() > 8 ? alias.right(8) : alias;
        return new User(Username= 'test.user' + randomVal + '@citation.co.uk', Email = 'test.user' + randomVal + '@citation.co.uk', Lastname = 'user' + randomVal, Firstname = 'test' + randomVal, Alias = alias, 
                                   CommunityNickname = 'tuser0' + randomVal, ProfileId = [select id from Profile where name = 'Citation Contact Centre BDC'].Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', 
                                   UserPermissionsMobileUser = false, isActive = true);
    }

}