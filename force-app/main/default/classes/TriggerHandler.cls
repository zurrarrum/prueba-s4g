public virtual class TriggerHandler {

    protected Schema.SObjectType sobjType;
    protected List <SObject> records;
    protected Map <Id, SObject> existingRecords;
    private TriggerBypass__c bypass = TriggerBypass__c.getInstance(UserInfo.getUserId());

    public TriggerHandler(Schema.SObjectType sobjType) {
        this.sobjType = sobjType;
        if (bypass.DisabledSObjects__c == null || !bypass.DisabledSObjects__c.contains(sobjType.getDescribe().getName())) {
            records = Trigger.new;
            existingRecords = Trigger.oldMap;
            if (Trigger.isInsert) {
                if (Trigger.isBefore) {
                    onBeforeInsert();
                } else {
                    onAfterInsert();
                }
            } else if (Trigger.isUpdate) {
                if (Trigger.isBefore) {
                    onBeforeUpdate();
                } else {
                    onAfterUpdate();
                }
            } else if (Trigger.isDelete) {
                onBeforeDelete();
            } else if (Trigger.isUndelete) {
                onAfterUndelete();
            }
        } else {
            System.debug(sobjType.getDescribe().getName() + ' trigger was disabled');
        }
    }

    protected virtual void onBeforeInsert() {
        System.debug('BeforeInsert has not been implemented');
    }
    protected virtual void onAfterInsert() {
        System.debug('AfterInsert has not been implemented');
    }
    protected virtual void onBeforeUpdate() {
        System.debug('BeforeUpdate has not been implemented');
    }
    protected virtual void onAfterUpdate() {
        System.debug('AfterUpdate has not been implemented');
    }
    protected virtual void onBeforeDelete() {
        System.debug('BeforeDelete has not been implemented');
    }
    protected virtual void onAfterUndelete() {
        System.debug('AfterUndelete has not been implemented');
    }
    
}