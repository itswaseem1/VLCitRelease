/**
 * @File Name          : WorkOrderSMASEmailHandler.cls
 * @Description        : To send email when workorder get created with SMAS subject line.
 * @Author             : Cognizant
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   : 08/06/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     08/06/2021      Initial Version
 **/

public with sharing class WorkOrderSMASEmailHandler {
  public static Map<Id, Id> woContractMap = new Map<Id, String>();
  public static Map<Id, String> woCaseNumberMap = new Map<Id, String>();
  public static Map<Id, String> woSubjectMap = new Map<Id, String>();
  public static Map<String, String> emailTempBodyMap = new Map<String, String>();
  public static Map<String, String> emailTempSubjMap = new Map<String, String>();
  public static Map<Id, WorkOrder> newWorkOrderMap = new Map<Id, Workorder>();
  public static Map<Id, String> woConatctNameMap = new Map<Id, String>();
  public static List<EnhancedLetterhead> letterhead = new List<EnhancedLetterhead>();
  public static List<String> docIdsList = new List<String>();
  public static List<OrgWideEmailAddress> emailDisplayName;
  public static List<Messaging.SingleEmailMessage> finalMailsList = new List<Messaging.SingleEmailMessage>();

  public static void sendSMASEmailOnWOCreation(List<WorkOrder> woList) {
      List<String> smasLabels = system.label.SMAS_Label.split(',');
    for (WorkOrder woRec : [
      SELECT
        Id,
        caseId,
        Subject,
        case.CaseNumber,
        Case.Billing_Contract__r.SF_Contract__r.CustomerSignedId,
        Case.Billing_Contract__r.SF_Contract__r.CustomerSigned.FirstName
      FROM WorkOrder
      WHERE Case.Billing_Contract__r.SF_Contract__r.CustomerSignedId != NULL AND Subject != NULL AND Id IN :woList
    ]) {
      if (woRec.Subject == 'SMAS Welcome Call') {
        woContractMap.put(woRec.Id, woRec.Case.Billing_Contract__r.SF_Contract__r.CustomerSignedId);
        woSubjectMap.put(woRec.Id, 'SMAS Welcome Call');
        newWorkOrderMap.put(woRec.Id, woRec);
        woConatctNameMap.put(woRec.Id, Worec.Case.Billing_Contract__r.SF_Contract__r.CustomerSigned.FirstName);
      }
      if (
        woRec.Subject == 'SMAS Accreditation (1st accreditation on renewal)' ||
        woRec.Subject == 'SMAS Re-Welcome Call'
      ) {
        woContractMap.put(woRec.Id, woRec.Case.Billing_Contract__r.SF_Contract__r.CustomerSignedId);
        woSubjectMap.put(woRec.Id, 'SMAS Re-Welcome Call');
        newWorkOrderMap.put(woRec.Id, woRec);
        woConatctNameMap.put(woRec.Id, Worec.Case.Billing_Contract__r.SF_Contract__r.CustomerSigned.FirstName);
      }
    }
    if (!newWorkOrderMap.isEmpty()) {
      for (EmailTemplate empTemp : [
        SELECT id, name, subject, HtmlValue, Markup, body
        FROM EmailTemplate
        WHERE name IN :woSubjectMap.values()
        WITH SECURITY_ENFORCED
      ]) {
        emailTempBodyMap.put(empTemp.name, empTemp.Markup);
        emailTempSubjMap.put(empTemp.name, empTemp.subject);
      }
      letterhead = [
        SELECT id, name, LetterheadHeader
        FROM EnhancedLetterhead
        WHERE Name = 'Citation service appointment dispatch letterhead'
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      for (Attachment att : [
        SELECT Id
        FROM Attachment
        WHERE
          ParentId IN (SELECT Id FROM EmailTemplate)
          AND Name IN :smasLabels
        LIMIT 2
      ]) {
        docIdsList.add(att.id);
      }

      makeEmailData();
    }
  }
  public static void makeEmailData() {
    for (WorkOrder woRec : newWorkOrderMap.values()) {
      Id contactId = woContractMap.get(woRec.Id);
      String woSubject = woSubjectMap.get(woRec.Id);
      String body = emailTempBodyMap.get(woSubject);
      String contName = woConatctNameMap.get(woRec.id);
      String emailSubject = emailTempSubjMap.get(woSubject);
      String replyToEmailAdd = System.Label.H_SAdviceReplyToEmail;

      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      // mail.setOrgWideEmailAddressId(emailDisplayName[0].Id);
      mail.setTargetObjectId(contactId);
      mail.setReplyTo(replyToEmailAdd);
      mail.setSenderDisplayName('handsadvice@citation.co.uk');
      mail.setSubject(emailSubject);
      mail.setBccSender(false);
      mail.setSaveAsActivity(true);
      mail.setUseSignature(false);
      mail.setWhatId(woRec.CaseId);
      mail.setEntityAttachments(docIdsList);

      mail.setHtmlBody(
        letterhead[0].LetterheadHeader +
        'Dear ' +
        contName +
        ',<br/><br/>' +
        Body +
        'Case Ref: ' +
        woRec.case.CaseNumber
      );
      finalMailsList.add(mail);
    }
    if (!finalMailsList.isEmpty()) {
      sendEmail(finalMailsList);
    }
  }
  public static void sendEmail(List<Messaging.SingleEmailMessage> finalEmailList) {
    try {
      Messaging.sendEmail(finalEmailList);
      finalEmailList.clear();
    } catch (Exception e) {
      system.debug('Send Email Exception' + e);
    }
  }
}