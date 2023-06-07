@isTest
public class SecurityCheckTest
{
    @isTest
    private static void testBaseClass_insertFails()
    {
        try
        {
            new ErrorSecurity().canInsert(new List<Account>{new Account()});
            System.assert(false, 'Should have error in default method');
        }
        catch (SecurityCheck.SecurityException se)
        {
            System.assert(true);
        }
    }

    @isTest
    private static void testBaseClass_updateFails()
    {
        try
        {
            new ErrorSecurity().canUpdate(new List<Account>{new Account()});
            System.assert(false, 'Should have error in default method');
        }
        catch (SecurityCheck.SecurityException se)
        {
            System.assert(true);
        }
    }

    @isTest
    private static void testBaseClass_deleteFails()
    {
        try
        {
            new ErrorSecurity().canDelete(new List<Account>{new Account()});
            System.assert(false, 'Should have error in default method');
        }
        catch (SecurityCheck.SecurityException se)
        {
            System.assert(true);
        }
    }

    @isTest
    private static void testBaseClass_insertOk()
    {
        try
        {
            new ErrorSecurity().canInsert(new List<Account>());
        }
        catch (Exception e)
        {
            System.assert(false, 'Should have been ok as empty list in default method :' + e.getMessage());
        }
    }

    @isTest
    private static void testBaseClass_updateOk()
    {
        try
        {
            new ErrorSecurity().canUpdate(new List<Account>());
        }
        catch (Exception e)
        {
            System.assert(false, 'Should have been ok as empty list in default method :' + e.getMessage());
        }
    }

    @isTest
    private static void testBaseClass_deleteOk()
    {
        try
        {
            new ErrorSecurity().canDelete(new List<Account>());
        }
        catch (Exception e)
        {
            System.assert(false, 'Should have been ok as empty list in default method :' + e.getMessage());
        }
    }


    @isTest
    private static void testAllowAll_insertOK()
    {
        try
        {
            new SecurityCheck.AllowAllSecurity().canInsert(new List<Account>{new Account()});
        }
        catch (Exception e)
        {
            System.assert(false, 'Should have been ok as Allow All :' + e.getMessage());
        }
    }

    @isTest
    private static void testAllowAll_updateOK()
    {
        try
        {
            new SecurityCheck.AllowAllSecurity().canUpdate(new List<Account>{new Account()});
        }
        catch (Exception e)
        {
            System.assert(false, 'Should have been ok as Allow All :' + e.getMessage());
        }
    }

    @isTest
    private static void testAllowAll_deleteOK()
    {
        try
        {
            new SecurityCheck.AllowAllSecurity().canDelete(new List<Account>{new Account()});
        }
        catch (Exception e)
        {
            System.assert(false, 'Should have been ok as Allow All :' + e.getMessage());
        }
    }

    class ErrorSecurity extends SecurityCheck
    {
    }
}