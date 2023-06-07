@IsTest
public class MoblieUtilityTest {

    @isTest
    public static void validMobileNumber_noCountryCode() {

        String mobileNumber = MobileUtility.formatMobileNumber('07568440436');
        System.assertEquals('447568440436', mobileNumber);

    }

    @isTest
    public static void validMobileNumber_withCountryCode() {

        String mobileNumber1 = MobileUtility.formatMobileNumber('447568440436');
        System.assertEquals('447568440436', mobileNumber1);

        String mobileNumber2 = MobileUtility.formatMobileNumber('+447568440436');
        System.assertEquals('447568440436', mobileNumber2);

    }

    @isTest
    public static void invalidMobileNumber() {

        String mobileNumber = MobileUtility.formatMobileNumber('03458441111');
        System.assertEquals(null, mobileNumber);

    }

    @isTest
    public static void validMobileNumberWithSpaces() {

        String mobileNumber = MobileUtility.formatMobileNumber(' 0756 8440436');
        System.assertEquals('447568440436', mobileNumber);

    }

}