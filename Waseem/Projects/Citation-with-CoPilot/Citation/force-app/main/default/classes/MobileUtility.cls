public inherited sharing class MobileUtility {

    private static final String MOBILE_REGEX = '^(\\+44\\s?7\\d{3}|\\(?07\\d{3}\\)?)\\s?\\d{3}\\s?\\d{3}$';
    private static Pattern mobilePattern;

    private static Pattern getPattern(){
        if(mobilePattern == null)
            mobilePattern = Pattern.compile(MobileUtility.MOBILE_REGEX);

        return mobilePattern;
    }

    public static String formatMobileNumber(String phoneNumber) {

        phoneNumber = phoneNumber.deleteWhitespace();
        if (phoneNumber.startsWith('44')) {
            phoneNumber = '+' + phoneNumber;
        }

        Matcher mobileMatcher = getPattern().matcher(phoneNumber);
        if (mobileMatcher.matches()) {
            if (phoneNumber.startsWith('+')) {
                phoneNumber = phoneNumber.replaceFirst('\\+', '');
                return phoneNumber;
            } else if (phoneNumber.startsWith('0')) {
                phoneNumber = phoneNumber.replaceFirst('0', '44');
                return phoneNumber;
            }
        }

        return null;
    }

}