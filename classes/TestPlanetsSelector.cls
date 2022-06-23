@isTest
public with sharing class TestPlanetsSelector {
    private static final Integer NUMBER_OF_RECORDS = 4;

    @TestSetup static void loadData(){
        TestFactory.createPlanets(NUMBER_OF_RECORDS, null);
    }

    @isTest static void selectByIdTest() {
        List <Planet__c> planetsList = [SELECT Id FROM Planet__c];
        System.assertEquals(NUMBER_OF_RECORDS, planetsList.size());
        Set <Id> planetIds = TestFactory.convertSobjectToSetId(planetsList);
        Test.startTest();
        planetsList = new PlanetsSelector(true).selectById(planetIds);
        System.assertEquals(NUMBER_OF_RECORDS, planetsList.size());
        planetsList = new PlanetsSelector(new List <String> {'default'}).selectById(planetIds);
        System.assertEquals(NUMBER_OF_RECORDS, planetsList.size());
    }

    @isTest static void selectByExternalIdTest() {
        List <Planet__c> planetsList = [SELECT Id, External_Id__c FROM Planet__c];
        System.assertEquals(NUMBER_OF_RECORDS, planetsList.size());
        Test.startTest();
        planetsList = new PlanetsSelector(true).selectByExternalId(new Set <String>{planetsList[0].External_Id__c});
        System.assertEquals(1, planetsList.size());
        planetsList = new PlanetsSelector(new List <String> {'default'}).selectByExternalId(new Set <String>{planetsList[0].External_Id__c});
        System.assertEquals(1, planetsList.size());
    }
}