@isTest
public with sharing class TestPlanetsService {
    @TestSetup
    static void loadData(){
        Planet__c planet = new Planet__c(Name = 'Sample', External_Id__c = Planet_Code__mdt.getAll().values()[0].External_Id__c);
        insert planet;
    }

    @isTest static void scanPlanetOKTest() {
        Test.setMock(HttpCalloutMock.class, new TestMockFactory('SCAN_OK'));
        List <Planet__c> planets = [SELECT Id FROM Planet__c];
        System.assertEquals(1, planets.size());
        Test.startTest();
        HttpResponse res = PlanetsService.scanPlanet(planets[0].Id);
        System.assertNotEquals(null, res);
        System.assertEquals(200, res.getStatusCode());
        Test.stopTest();
    }

    @isTest static void scanPlanetKOTest() {
        Test.setMock(HttpCalloutMock.class, new TestMockFactory('SCAN_KO'));
        List <Planet__c> planets = [SELECT Id FROM Planet__c];
        System.assertEquals(1, planets.size());
        Test.startTest();
        HttpResponse res = PlanetsService.scanPlanet(planets[0].Id);
        System.assertNotEquals(null, res);
        System.assertEquals(500, res.getStatusCode());
        Test.stopTest();
    }

    @isTest static void scanPlanetExcTest() {
        Test.setMock(HttpCalloutMock.class, new TestMockFactory('SCAN_EX'));
        List <Planet__c> planets = [SELECT Id FROM Planet__c];
        System.assertEquals(1, planets.size());
        Test.startTest();
        HttpResponse res = PlanetsService.scanPlanet(planets[0].Id);
        System.assertEquals(null, res);
        Test.stopTest();
    }
}