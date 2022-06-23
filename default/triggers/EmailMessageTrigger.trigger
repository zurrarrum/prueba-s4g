trigger EmailMessageTrigger on EmailMessage (before insert, after insert, before update, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            System.debug('Before Insert');
            System.debug(Trigger.new[0].RelatedToId);
            throw new DMLException('nooop');
        } else {
            System.debug('Before update');
            System.debug(Trigger.new[0].RelatedToId);
        }
    } else {
        if (Trigger.isInsert) {
            System.debug('After Insert');
            System.debug(Trigger.new[0].RelatedToId);
        } else {
            System.debug('After update');
            System.debug(Trigger.new[0].RelatedToId);
        }
    }
}