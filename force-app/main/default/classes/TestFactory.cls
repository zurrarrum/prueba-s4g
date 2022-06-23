@isTest
public with sharing class TestFactory {
    
    @testVisible private static Set <Id> createCases(Integer numberOfRecords) {
        Set <Id> idSet = new Set <Id>();
        List <Case> casesToInsert = new List <Case>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Case cas = new Case();
            cas.Subject = 'Sample Subject' + i;
            cas.Description = 'Sample description' + i;
            cas.Origin = 'Web';

            casesToInsert.add(cas);
        }
        insert casesToInsert;
        for(Integer i = 0; i < casesToInsert.size(); i++) {
            idSet.add(casesToInsert[i].Id);
        }
        return idSet;
    }

    @testVisible private static Set <Id> createContacts(Integer numberOfRecords) {
        Set <Id> idSet = new Set <Id>();
        List <Contact> contactsToInsert = new List <Contact>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Contact cont = new Contact();
            cont.FirstName = 'Sample Name' + i;
            cont.LastName = 'Sample Last Name' + i;
            cont.Email = 'test@test.test';

            contactsToInsert.add(cont);
        }
        insert contactsToInsert;
        for(Integer i = 0; i < contactsToInsert.size(); i++) {
            idSet.add(contactsToInsert[i].Id);
        }
        return idSet;
    }

    @testVisible private static Set <Id> createPlanets(Integer numberOfRecords, String extId) {
        Set <Id> idSet = new Set <Id>();
        List <Planet__c> planetsToInsert = new List <Planet__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Planet__c planet = new Planet__c();
            planet.Name = 'Sample Name' + i;
            planet.External_Id__c = extId == null ? 'SampleId' + i : extId + i;

            planetsToInsert.add(planet);
        }
        insert planetsToInsert;
        for(Integer i = 0; i < planetsToInsert.size(); i++) {
            idSet.add(planetsToInsert[i].Id);
        }
        return idSet;
    }

    @testVisible private static Set <Id> convertSobjectToSetId(List <SObject> sObjectList) {
        Set <Id> idSet = new Set <Id>();
        for(Integer i = 0; i < sObjectList.size(); i++) {
            idSet.add((Id)sObjectList[i].get('Id'));
        }
        return idSet;
    }
}