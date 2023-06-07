/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_SBQQ_QuoteLineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_SBQQ_QuoteLineTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new SBQQ__QuoteLine__c());
    }
}