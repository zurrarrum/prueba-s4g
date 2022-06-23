@isTest
public with sharing class TestCasesSelector {
    private static final Integer NUMBER_OF_RECORDS = 4;

    @TestSetup static void loadData(){
        TestFactory.createCases(NUMBER_OF_RECORDS);
    }

    @isTest static void selectByIdTest() {
        List <Case> casesList = [SELECT Id FROM Case];
        System.assertEquals(NUMBER_OF_RECORDS, casesList.size());
        Set <Id> caseIds = TestFactory.convertSobjectToSetId(casesList);
        Test.startTest();
        casesList = new CasesSelector(true).selectById(caseIds);
        System.assertEquals(NUMBER_OF_RECORDS, casesList.size());
        casesList = new CasesSelector(new List <String> {'default', 'CaseListView'}).selectById(caseIds);
        System.assertEquals(NUMBER_OF_RECORDS, casesList.size());
    }
}