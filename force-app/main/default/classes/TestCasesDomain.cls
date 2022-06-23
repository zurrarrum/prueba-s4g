@isTest
public with sharing class TestCasesDomain {
    private static final Integer NUMBER_OF_RECORDS = 4;
    private static final String EXT_ID_PREFIX = 'A-000';

    @TestSetup
    static void loadData(){
        TestFactory.createPlanets(NUMBER_OF_RECORDS, EXT_ID_PREFIX);
    }

    @isTest static void parseDinDjarinEmailOKTest(){
        List <Case> casesList = createCases(NUMBER_OF_RECORDS, false);
        Test.startTest();
        insert casesList;
        Test.stopTest();
        for (Case cas : [SELECT Id, Planet__c FROM Case]) {
            System.assertNotEquals(null, cas.Planet__c);
        }
    }

    @isTest static void parseDinDjarinEmailKOTest(){
        List <Case> casesList = createCases(NUMBER_OF_RECORDS, true);
        Test.startTest();
        try {
            insert casesList;
            System.assert(true, 'Insertion must fail');
        } catch (DmlException e) {
            System.assertEquals('Planet not found', e.getDmlMessage(0));
        }
        Test.stopTest();
    }

    @isTest static void parseDinDjarinEmailBadFormatTest(){
        List <Case> casesList = createCases(NUMBER_OF_RECORDS, true);
        for (Case cas : casesList) {
            cas.Description = 'Bad format';
        }
        Test.startTest();
        try {
            insert casesList;
            System.assert(true, 'Insertion must fail');
        } catch (DmlException e) {
            System.assertEquals('Email body does not match the specificied format', e.getDmlMessage(0));
        }
        Test.stopTest();
    }

    @isTest static void TriggerHandlerTest() {
        Case cas = new Case(Subject = 'Sample');
        Test.startTest();
        insert cas;
        update cas;
        delete cas;
        undelete cas;
        Test.stopTest();
    }

    private static List <Case> createCases(Integer numberOfCases, Boolean error) {
        List <Case> toReturn = new List <Case>();
        for (Integer i = 0; i < numberOfCases; i++) {
            String description = 'Código de acceso al sistema de escaneo interplanetario: ';
            Case cas = new Case();
            cas.Subject = 'Sample' + i;
            cas.Origin = 'Email';
            cas.SuppliedEmail = 'test@test.test';
            cas.Description = error ? description + EXT_ID_PREFIX + (i + numberOfCases) : description + EXT_ID_PREFIX + i;
            toReturn.add(cas);
        }
        return toReturn;
    }
}