@isTest
public with sharing class TestEmailServiceParsersSelector_MDT {
    @isTest static void selectAllTest() {
        List <EmailServiceParser__mdt> parsers = new EmailServiceParsersSelector_MDT().selectAll();
        System.assert(!parsers.isEmpty());
    }
}