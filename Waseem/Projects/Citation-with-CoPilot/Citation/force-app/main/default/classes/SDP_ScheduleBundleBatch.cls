/**
 * @File Name          : SDP_ScheduleBundleBatch.cls
 * @Description        :
 * @Author             :
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 5/30/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     5/30/2021       Initial Version
 **/
public with sharing class SDP_ScheduleBundleBatch implements System.Schedulable {
    public void execute(System.SchedulableContext sc) {
        SDP_BundleBatch scheduledbatch = new SDP_BundleBatch(null, null, false);
        if (!test.isRunningTest()) {
            Database.executeBatch(scheduledbatch, 1);
        } else {
            Database.executeBatch(scheduledbatch);
        }
    }
}