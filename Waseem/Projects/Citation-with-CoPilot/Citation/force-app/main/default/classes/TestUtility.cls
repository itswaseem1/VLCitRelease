@isTest
public class TestUtility
{
    static Integer myNumber = 1;

    public static void setIDs(List<SObject> objs)
    {
        for(SObject obj: objs)
            setID(obj);
    }

    public static void setID(SObject obj)
    {
        obj.Id = getFakeId(obj.getSObjectType());
    }

    public static Id getFakeId(Schema.SObjectType sObjectType) {
        String index = String.valueOf(myNumber++);
        return (Id) (sObjectType.getDescribe().getKeyPrefix() +'0'.repeat(12 - index.length()) +index);
    }


    public static User createUser(String roleId, String profId, String firstName, String lastName){
        User tempUser = prepareUser(roleId, profId, firstName, lastName);
        return tempUser;
    }
    
    private static User prepareUser(String roleId, String profId, String firstName, String lastName) {  
        
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = firstName,  
            LastName = lastName,  
            email = uniqueName + '@sfdc' + orgId + '.org',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profId
        );    
        if( String.isBlank(roleId) == false ){
            tempUser.UserRoleId = roleId;
        }
        return tempUser;  
    }
    public static Account createAccount(String Name){
        Account portalAccount = new Account(name = Name );
        return portalAccount;
    }
    public static Contact createContact(String firstName, String lastName, String email, String accountId){
        Contact portalContact = new contact(
            FirstName = firstName, 
            LastName = lastName, 
            Email = email, 
            AccountId = accountId
        );
        return portalContact;
    }
    public static User createCommunityUser(String contactId, String profId, String firstName, String lastName) {
        User tempUser = prepareUser('', profId, firstName, lastName);
        tempUser.ContactId = contactId;
        return tempUser;
    }
}