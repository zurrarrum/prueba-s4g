@isTest
public with sharing class TestContactsSelector {
    private static final Integer NUMBER_OF_RECORDS = 4;

    @TestSetup static void loadData(){
        TestFactory.createContacts(NUMBER_OF_RECORDS);
    }

    @isTest static void selectByEmailTest() {
        List <Contact> contactsList = [SELECT Id, Email FROM Contact];
        System.assertEquals(NUMBER_OF_RECORDS, contactsList.size());
        Test.startTest();
        contactsList = new ContactsSelector(true).selectByEmail(contactsList[0].Email);
        System.assertEquals(NUMBER_OF_RECORDS, contactsList.size());
        contactsList = new ContactsSelector(new List <String> {'default'}).selectByEmail(contactsList[0].Email);
        System.assertEquals(NUMBER_OF_RECORDS, contactsList.size());
    }
}