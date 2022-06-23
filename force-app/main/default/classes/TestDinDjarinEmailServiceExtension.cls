@isTest
public with sharing class TestDinDjarinEmailServiceExtension {
    private static final Integer NUMBER_OF_RECORDS = 1;
    private static final String EXT_ID_PREFIX = 'A-000';

    @TestSetup
    static void loadData(){
        TestFactory.createPlanets(NUMBER_OF_RECORDS, EXT_ID_PREFIX);
    }

    @isTest static void processEmailOKTest() {
        ParserInfoType parser = createMail(false);
        Test.startTest();
        new DinDjarinEmailServiceExtension().processEmail(parser.email, parser.matcherList, null);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Case].size());
        System.assertEquals(1, [SELECT Id FROM EmailMessage].size());
    }

    @isTest static void processEmailKOTest() {
        ParserInfoType parser = createMail(true);
        Test.startTest();
        new DinDjarinEmailServiceExtension().processEmail(parser.email, parser.matcherList, null);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Case].size());
        System.assertEquals(0, [SELECT Id FROM EmailMessage].size());
    }

    private static ParserInfoType createMail(Boolean error) {
        ParserInfoType toReturn;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test@test.test';
        email.toAddresses = new List <String>{'test2@test.test'};
        email.subject = 'Sample';
        email.plainTextBody = 'Sample';
        email.fromName = 'Sample sample';

        String body = 'Código de acceso al sistema de escaneo interplanetario: ';
        body = error ? body + EXT_ID_PREFIX + NUMBER_OF_RECORDS : body + EXT_ID_PREFIX + 0;
        Matcher matcher = Pattern.compile('[\\w\\sÀ-ÿ]+:\\s?(\\w+-\\d+)$').matcher(body);
        if(matcher.find()) {
            toReturn = new ParserInfoType(email, new List <Matcher>{matcher});
        }
        return toReturn;
    }

    private class ParserInfoType {
        Messaging.InboundEmail email;
        List <Matcher> matcherList;
        public ParserInfoType(Messaging.InboundEmail email, List <Matcher> matcherList) {
            this.email = email;
            this.matcherList = matcherList;
        }
    }
}