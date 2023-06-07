/**
 * @File Name          : EmailBody.cls
 * @Description        : Fields required for email body of the Teams meeting 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 06/10/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     06/10/2021               Priyanka                 Initial Version
 **/
public without sharing class EmailBody {
    public String contentType{get; set;}
    public String content{get; set;}
    
    public EmailBody(String cntType, String cnt){
        this.contentType = cntType;
        this.content = cnt.replace('\"', '\'');
    }
}