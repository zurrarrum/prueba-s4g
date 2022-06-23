public with sharing class CasesDomain extends TriggerHandler {
    CasesDomainHelper helper = new CasesDomainHelper();
    public CasesDomain() {
        super(Case.SObjectType);
    }

    public override void onBeforeInsert() {
        helper.parseDinDjarinEmail(this.records);
    }

    public override void onAfterInsert() {
        //method to delete cases which has been marked on before insert
    }
}