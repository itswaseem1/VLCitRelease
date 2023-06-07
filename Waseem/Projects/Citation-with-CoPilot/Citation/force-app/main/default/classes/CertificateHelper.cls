/**
 * @File Name          : CertificateHelper.cls
 * @Description        :
 * @Author             : Maanas -Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 4/6/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     7/6/2021      Initial Version
 **/

public without sharing class CertificateHelper {
    public static Map<Id, Certificate__c> suspensionMap = new Map<Id, Certificate__c>();
    public static Map<Id, Certificate__c> fullMap = new Map<Id, Certificate__c>();
    public static void suspensionLogic(
        List<Certificate__c> newList,
        Map<Id, Certificate__c> oldMap
    ) {
        for (Certificate__c certObj : newList) {
            if (
                certObj.Status__c == 'Suspension' &&
                certObj.Status__c != oldMap.get(certObj.Id).Status__c
            ) {
                suspensionMap.put(certObj.Id, certObj);
            }

            if (
                certObj.Status__c == 'Full' &&
                certObj.Status__c != oldMap.get(certObj.Id).Status__c
            ) {
                fullMap.put(certObj.Id, certObj);
            }
        }

        if (null != suspensionMap && suspensionMap.size() > 0) {
            SuspendCertifcateQueuebale queInstance = new SuspendCertifcateQueuebale(
                suspensionMap
            );
            system.enqueueJob(queInstance);
        }

        if (null != fullMap && fullMap.size() > 0) {
            FullCertifcateQueuebale queInstance = new FullCertifcateQueuebale(
                fullMap
            );
            system.enqueueJob(queInstance);
        }
    }
}