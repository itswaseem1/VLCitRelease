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
public without sharing class FullCertifcateQueuebale implements Queueable, Database.AllowsCallouts {
    public Map<Id, Certificate__c> filteredMap;
    public static Map<String, Id> queueMap = new Map<String, Id>();
    public static Map<String, String> queueMapping = new Map<String, String>{
        'H_S_Field_Support' => 'H_S_Field_Support',
        'HR_Field_Support' => 'HR_Field_Support',
        'Atlas_On_boarding_Support_Line_1' => 'Atlas_On_boarding_Support_Line_1',
        'Atlas_On_boarding_Support_Line_2' => 'Atlas_On_boarding_Support_Line_2',
        'H&S Advice' => 'H_S_Advice',
        'Reception' => 'Reception_Team',
        'H&S Field Consultants' => 'H_S_Field_Support',
        'Onsite_HR_Field' => 'Onsite_HR_Field',
        'Atlas On-boarding' => 'Atlas_On_boarding_Support_Line_1',
        'Client Operations' => 'EL_and_HR_Admin',
        'Client Relations' => 'Citation_Complaints',
        'EL&HR Field Consultants' => 'EL_HR_Field_Consultants',
        'ELT&HR Advice' => 'ELT_Advice'
    };
    public static Map<String, String> queueMappingWT = new Map<String, String>{
        'H&S Field Support' => 'H_S_Field_Support',
        'HR Field Support' => 'HR_Field_Support',
        'Atlas On-boarding & Support Line 1' => 'Atlas_On_boarding_Support_Line_1',
        'Atlas On-boarding & Support Line 2' => 'Atlas_On_boarding_Support_Line_2',
        'H&S Advice' => 'H_S_Advice',
        'Reception' => 'Reception_Team',
        'H&S Field Consultants' => 'H_S_Field_Support',
        'Onsite-HR Field' => 'Onsite_HR_Field',
        'Atlas On-boarding' => 'Atlas_On_boarding_Support_Line_1',
        'Client Operations' => 'EL_and_HR_Admin',
        'Client Relations' => 'Citation_Complaints',
        'EL&HR Field Consultants' => 'EL_HR_Field_Consultants',
        'ELT&HR Advice' => 'ELT_Advice'
    };

    public FullCertifcateQueuebale(Map<Id, Certificate__c> filteredMap) {
        //CONSTRUCTOR
        this.filteredMap = filteredMap;
    }

    public void execute(QueueableContext context) {
        fullLogic(filteredMap); //NOPMD
    }
    public static void fullLogic(Map<Id, Certificate__C> filteredMap) { //NOPMD
        List<Sobject> sobjectListToUpdate = new List<Sobject>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> workOrderIdSet = new Set<Id>();
        Map<Id, String> workOrderOwningMap = new Map<Id, String>();
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        Map<Id,ServiceAppointment> woSaMap = new Map<Id, ServiceAppointment>();

        queueMap = SDP_Util.getSDPQueues(); //
		serviceclass.runSALogic = false;
        for (Asset assetObj : [
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        Status,
                        previous_Status__c,
                        Milestone_Template__c,
                        Milestone_Template__r.Owning_team__c
                    FROM Cases
                    WHERE
                        Status = 'On Hold'
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
                caseObj.Status = caseObj.previous_Status__c;
                caseObj.OwnerId = getOwnerId(
                        caseObj.Milestone_Template__r.Owning_team__c
                    ) != null
                    ? getOwnerId(caseObj.Milestone_Template__r.Owning_team__c)
                    : userinfo.getUserId();
                sobjectListToUpdate.add(caseObj);
                caseIdSet.add(caseObj.Id);
            }
        }

        for (WorkOrder wObj : [
            SELECT
                Id,
                Status,
                isStopped,
                OwnerId,
                Milestone_Work_type__r.Owning_Team__c
            FROM WorkOrder
            WHERE CaseId IN :caseIdSet AND Status = 'On Hold'
        ]) {
            wObj.status = 'New';
            wObj.ownerId = getWOOwnerId(
                wObj.Milestone_Work_type__r.Owning_Team__c
            );
            wObj.isStopped = false;
            sobjectListToUpdate.add(wObj);
            workOrderIdSet.add(wObj.Id);
            workOrderOwningMap.put(
                wObj.Id,
                wObj.Milestone_Work_type__r.Owning_Team__c
            );
        }

        for (ServiceAppointment saObj : [
            SELECT
                Id,
                ParentRecordId,
                createdDate,
                DueDate,
                subject,
                description,
                EarliestStartTime,
                status,
                Reason__c
            FROM ServiceAppointment
            WHERE
                ParentRecordId IN :workOrderIdSet
                AND Status = 'Canceled'
                AND Reason__c IN ('Suspension','Service On-Hold')
            WITH SECURITY_ENFORCED
        ]) {
            if(!woSaMap.containsKey(saObj.ParentRecordId)){
                woSaMap.put(saObj.ParentRecordId, saObj);
            }
            else if(saObj.createdDate >= woSaMap.get(saObj.ParentRecordId).createdDate){
                woSaMap.put(saObj.ParentRecordId, saObj);
            }
        }
        if(null != woSaMap && woSaMap.size() > 0 ){
            for(Id wobjId : woSaMap.keyset()){
            ServiceAppointment saObjNew = new ServiceAppointment();
            saObjNew.EarliestStartTime = woSaMap.get(wobjId).EarliestStartTime;
            saObjNew.DueDate = woSaMap.get(wobjId).DueDate;
            saObjNew.status = 'None';
            saObjNew.ParentRecordId = woSaMap.get(wobjId).ParentRecordId;
            saObjNew.OwnerId = getWOOwnerId(
                    workOrderOwningMap.get(woSaMap.get(wobjId).ParentRecordId)
                ) != null
                ? getWOOwnerId(workOrderOwningMap.get(woSaMap.get(wobjId).ParentRecordId))
                : userinfo.getUserId();
            saObjNew.Subject = woSaMap.get(wobjId).Subject;
            saObjNew.Description = woSaMap.get(wobjId).Description;
            saList.add(saObjNew);
            }
        }

        if (null != sobjectListToUpdate && sobjectListToUpdate.size() > 0) {
            try {
                update sobjectListToUpdate;
            } catch (Exception error) {
                system.debug(error.getMessage());
            }
        }

        if (null != saList && saList.size() > 0) {
            try {
                insert saList;
            } catch (Exception error) {
                system.debug(error.getMessage());
            }
        }
    }

    private static Id getOwnerId(String owningTeam) {
        Id ownerId = queueMap.get(queueMapping.get(owningTeam)) != null
            ? queueMap.get(queueMapping.get(owningTeam))
            : userinfo.getUserId();
        return ownerId;
    }

    private static Id getWOOwnerId(String owningTeam) {
        Id ownerId = queueMap.get(queueMappingWT.get(owningTeam)) != null
            ? queueMap.get(queueMappingWT.get(owningTeam))
            : userinfo.getUserId();
        return ownerId;
    }
}