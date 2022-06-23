public with sharing class EmailServiceParsersSelector_MDT {
    private final List <Schema.SObjectField> fields = new List <Schema.SObjectField> {
        EmailServiceParser__mdt.Id,
        EmailServiceParser__mdt.DeveloperName,
        EmailServiceParser__mdt.ApexClass__c,
        EmailServiceParser__mdt.Attributes__c,
        EmailServiceParser__mdt.FromAddress__c,
        EmailServiceParser__mdt.RegexExpression__c
    };

    private String condition;

    public List <EmailServiceParser__mdt> selectAll() {
        return (List <EmailServiceParser__mdt>)Database.query(getQuery());
    }

    private String getQuery() {
        return 'SELECT ' + getQueryFields() + ' FROM EmailServiceParser__mdt' + getCondition();
        //return EmailServiceParser__mdt.getAll().values();
    }

    private String getCondition() {
        return condition != null ? ' WHERE ' + condition : ''; 
    }

    private String getQueryFields() {
        String queryFields;
        for (Schema.SObjectField field : fields) {
            if (queryFields == null) {
                queryFields = field.getDescribe().getName();
            } else {
                queryFields += ', ' + field.getDescribe().getName();
            }
        }
        return queryFields;
    }


}