@isTest
public class TestEmailServiceParser {
    private static List<Matcher> matchers = new List <Matcher>();
    private static String attributes;
    @isTest static void handleInboundEmailTest() {
        Messaging.InboundEmail email = createEmail('1', '2', 'test@test.test',new List <String>{'sample@sample.test'}, null, 'A');
        Test.startTest();
        new EmailServiceParser().handleInboundEmail(email, null);
        System.assertEquals(matchers[0].group(0), 'A');
        System.assertEquals(matchers[1].group(0), '1');
        System.assertEquals(matchers[2].group(0), '2');
        System.assertEquals(attributes, 'sample attributes');
        Test.stopTest();
    }

    public class TestEmailService implements IEmailServiceParser {
        public void processEmail(Messaging.InboundEmail email, List <Matcher> matcherList, String params) {
            matchers = matcherList;
            attributes = params;
        }
    }

    private static Messaging.InboundEmail createEmail(String plaintextBody, String htmlBody, String fromAddress, List <String> toAddresses, String messageId, String subject) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plaintextBody = plaintextBody;
        email.htmlBody = htmlBody;
        email.fromAddress = fromAddress;
        email.toAddresses = toAddresses;
        email.messageId = messageId;
        email.subject = subject;
        return email;
    }
}