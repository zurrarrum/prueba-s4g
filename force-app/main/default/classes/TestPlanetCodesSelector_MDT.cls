@isTest
public with sharing class TestPlanetCodesSelector_MDT {
    @isTest static void selectByExternalIdTest() {
        Planet_Code__mdt planetCode = Planet_Code__mdt.getAll().values()[0];
        Planet_Code__mdt planetCodesQuery = new PlanetCodesSelector_MDT().selectByExternalId(planetCode.External_id__c);
        System.assertNotEquals(null, planetCodesQuery);
    }
}