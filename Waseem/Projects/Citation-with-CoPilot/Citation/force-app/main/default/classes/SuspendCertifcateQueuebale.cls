/**
 * @File Name          : SuspendCertifcateQueuebale.cls
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
public without sharing class SuspendCertifcateQueuebale implements Queueable {
    public Map<Id, Certificate__c> filteredMap;

    public SuspendCertifcateQueuebale(Map<Id, Certificate__c> filteredMap) {
        //CONSTRUCTOR
        this.filteredMap = filteredMap;
    }
		
    public void execute(QueueableContext context) {
        suspendLogic(filteredMap); //MAIN METHOD FOR SUSPENSION LOGIC
    }
    public static void suspendLogic(Map<Id, Certificate__C> filteredMap) {
        List<Sobject> sobjectListToUpdate = new List<Sobject>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> workOrderIdSet = new Set<Id>();
        serviceclass.runSALogic = false;
        Id onHoldQueueId = [
            SELECT Id
            FROM GROUP
            WHERE TYpe = 'Queue' AND Name = 'On-Hold'
            LIMIT 1
        ]
        ?.Id;

        for (Asset assetObj : [
            SELECT
                Id,
                (
                    SELECT Id, Status
                    FROM Cases
                    WHERE
                        Status = 'Active'
                        AND Recordtype.Name IN (
                            'H&S Visits',
                            'HR Visits',
                            'Non Visits',
                            'Onsite-HR Visits'
                        )
                )
            FROM Asset
            WHERE Certificate__c IN :filteredMap.keyset()
        ]) {
            for (case caseObj : assetObj.Cases) {
                caseObj.previous_Status__c = caseObj.Status;
                caseObj.Status = 'On Hold';
                caseObj.OwnerId = onHoldQueueId;
                sobjectListToUpdate.add(caseObj);
                caseIdSet.add(caseObj.Id);
            }
        }

        for (WorkOrder wObj : [
            SELECT Id, Status, isStopped, OwnerId
            FROM WorkOrder
            WHERE
                CaseId IN :caseIdSet
                AND Status NOT IN ('Completed', 'Canceled')
        ]) {
            wObj.status = 'On Hold';
            wObj.ownerId = onHoldQueueId;
            wObj.isStopped = true;
            sobjectListToUpdate.add(wObj);
            workOrderIdSet.add(wObj.Id);
        }

        for (ServiceAppointment saObj : [
            SELECT Id, Status, OwnerId, Reason__c
            FROM ServiceAppointment
            WHERE
                ParentRecordId IN :workOrderIdSet
                AND Status NOT IN ('Completed', 'Canceled')
        ]) {
            saObj.Status = 'Canceled';
            saObj.Reason__c = 'Suspension';
            sobjectListToUpdate.add(saObj);
        }

        if (null != sobjectListToUpdate && sobjectListToUpdate.size() > 0) {
            try {
                update sobjectListToUpdate;
            } catch (Exception error) {
                system.debug(error.getMessage());
            }
        }
    }
}