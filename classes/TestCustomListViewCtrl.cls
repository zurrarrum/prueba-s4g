@isTest
public with sharing class TestCustomListViewCtrl {
    @isTest static void getColumnsTest() {
        Test.startTest();
        String columns = CustomListViewCtrl.getColumns('Case', 'CaseListView');
        List <CustomListViewCtrl.ColumnInfoType> columnsList = (List <CustomListViewCtrl.ColumnInfoType>)JSON.deserialize(columns, List <CustomListViewCtrl.ColumnInfoType>.class);
        Test.stopTest();
        System.assertNotEquals(0, columnsList.size());
    }

    @isTest static void getRecordsTest() {
        TestFactory.createCases(5);
        String columns = CustomListViewCtrl.getColumns('Case', 'CaseListView');
        Test.startTest();
        List <Map <String, String>> records = CustomListViewCtrl.getRecords('Case', columns, 'Id != null', 'CreatedDate', 4);
        System.assertEquals(4, records.size());
        Test.stopTest();
    }

    @isTest static void getFieldsetFieldsTest() {
        Test.startTest();
        List <String> fields = CustomListViewCtrl.getFieldsetFields('Case', 'CaseListView');
        Test.stopTest();
        System.assertNotEquals(0, fields.size());
    }

    @isTest static void scanPlanetTest() {
        Test.setMock(HttpCalloutMock.class, new TestMockFactory('SCAN_OK'));
        Planet__c planet = new Planet__c(Name = 'Sample', External_Id__c = Planet_Code__mdt.getAll().values()[0].External_Id__c);
        insert planet;
        Case cas = new Case(Subject = 'Sample', Origin = 'Email', Description = 'Sample', Planet__c = planet.Id);
        insert cas;
        Test.startTest();
        String response = CustomListViewCtrl.scanPlanet(cas.Id);
        Test.stopTest();
        System.assertNotEquals(null, response);
    }
}