public with sharing class CreateCommentMessage {
    public String jiraTicketNumber;
    public String comment;
    public List<Id> contentVersionIds;

    public CreateCommentMessage(String jiraTicketNumber, String comment, List<Id> contentVersionIds) {
        this.jiraTicketNumber = jiraTicketNumber;
        this.comment = comment;
        this.contentVersionIds = contentVersionIds;
    }
}