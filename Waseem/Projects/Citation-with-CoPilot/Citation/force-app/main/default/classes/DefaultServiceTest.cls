/*
*   This is testing a base class that does nothing for the most part.
*   Which means that the tests have nothing to actually test, but we
*   need to call the methods anyway for deployment purposes, as otherwise
*   the Default service will not deploy.  
*
*   Feels like a bug in Salesforce that it counts do nothing methods for
*   code coverage purposes.
*/
@isTest
public class DefaultServiceTest
{
    @isTest
    private static void testSetDefaults()
    {
        new DefaultService().setDefaults(new List<SObject>());
    }

    @isTest
    private static void testProcessChangedValues()
    {
        new DefaultService().processChangedValues(new List<SObject>(), new Map<Id, SObject>());
    }

    @isTest
    private static void testValidate()
    {
        List<ValidationError> errors = new DefaultService().validate(new List<SObject>());

        System.assertEquals(0, errors.size());
    }

    @isTest
    private static void testProcessRelatedRecordsOnNew()
    {
        new DefaultService().processRelatedRecordsOnNew(new List<SObject>());
    }

    @isTest
    private static void testProcessRelatedRecordsOnChange()
    {
        new DefaultService().processRelatedRecordsOnChange(new List<SObject>(), new Map<Id, SObject>());
    }
}