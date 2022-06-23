public class DinDjarinEmailServiceExtension implements IEmailServiceParser {
    public void processEmail(Messaging.InboundEmail email, List <Matcher> matcherList, String attributes) {
        String planet = matcherList[0].group(1);
        List <Planet__c> planets = new PlanetsSelector(true).selectByExternalId(new Set <String> {planet});
        if (planets.size() == 1) {
            createCase(email, planets[0]);
        } else {
            System.debug('Planet not found');
        }
    }

    private void createCase(Messaging.InboundEmail email, Planet__c planet) {
        Id relatedContact = getContactFromEmail(email.fromAddress);
        Case cas = new Case();
        cas.Subject =           email.subject;
        cas.Description =       email.plainTextBody;
        cas.Status =            'Ready to Scann';
        cas.ContactId =         relatedContact;
        cas.Planet__c =         planet.Id;
        cas.EmailService__c =   true;
        cas.Priority =          'Medium';
        cas.Origin =            'Email';
        cas.SuppliedEmail =     email.fromAddress;
        insert cas;
        createRelatedEmail(email, cas);
        firePlatformEvent();
    }

    private Id getContactFromEmail(String email) {
        List <Contact> contacts = new ContactsSelector(false).selectByEmail(email);
        return contacts.isEmpty() ? null : contacts[0].Id;
    }

    private void createRelatedEmail(Messaging.InboundEmail email, Case cas) {
        EmailMessage emailMess = new EmailMessage();
        emailMess.Incoming = true;
        emailMess.FromAddress = email.fromAddress;
        emailMess.FromName = email.fromName;
        emailMess.HtmlBody = email.htmlBody;
        emailMess.Subject  = email.subject;
        emailMess.ToAddress = String.join(email.toAddresses, ',');
        emailMess.status = '2';
        emailMess.RelatedToId = cas.Id;
        insert emailMess;
    }

    private void firePlatformEvent() {
        List <Refresh__e> refreshEvents = new List <Refresh__e> {new Refresh__e(Name__c = 'Case')};
        EventBus.publish(refreshEvents);
    }
}