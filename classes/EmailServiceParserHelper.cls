public class EmailServiceParserHelper {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        List <EmailServiceParser__mdt> parsers;
        if (Test.isRunningTest()) {
            parsers = new List <EmailServiceParser__mdt> {new EmailServiceParser__mdt(ApexClass__c = 'TestEmailServiceParser.TestEmailService', Attributes__c = 'sample attributes', RegexExpression__c = '{"subject":["[A-z]"],"body":["[1-9]"],"htmlbody":["[1-9]"]}')};
        } else {
            parsers = new EmailServiceParsersSelector_MDT().selectAll();
        }
        MatcherResultInfoType regExResult;
        // try {
            for(EmailServiceParser__mdt parser : parsers) {
                List <Matcher> matcherList = new List <Matcher>();
                List <String> allowedFromAddress = parser.FromAddress__c != null ? parser.FromAddress__c.split(',') : null;
                if(isValidAddress(email.fromAddress, parser)) {
                    regExResult = processRegEx(email, parser);
                    if (regExResult.success) {
                        Type t = Type.forName(parser.ApexClass__c);
                        IEmailServiceParser serviceParser = (IEmailServiceParser)t.newInstance();
                        serviceParser.processEmail(email, regExResult.matcherList, parser.Attributes__c);
                    } else {
                        System.debug('Email does not match the specificied format');
                    }
                }
            }
        // }
        // catch (Exception e) {
        //     TODO: create exceptions handler
        //     System.debug('Error: ' + e.getMessage());
        //     System.debug('ErrorLine: ' + e.getLineNumber());
        //     return result;
        // }
        return result;
    }

    private Boolean isValidAddress(String fromAddress, EmailServiceParser__mdt config) {
        if (config.FromAddress__c != null) {
            List <String> allowedAdresses = config.FromAddress__c.split(',');
            for (String address : allowedAdresses) {
                if (address.contains('@') && address == fromAddress) {
                    return true;
                } else if (fromAddress.contains('@' + address)) {
                    return true;
                }
            }
        } else {
            return true;
        }
        return false;
    }

    private MatcherResultInfoType processRegEx(Messaging.InboundEmail email, EmailServiceParser__mdt config) {
        
        List <Matcher> matcherList = new List <Matcher>();
        if(config.RegexExpression__c == null) {return new MatcherResultInfoType(true, matcherList);}
        Map <String, List <String>> mapRegExp = (Map <String, List <String>>)JSON.deserializeStrict(config.RegexExpression__c, Map <String, List <String>>.class);
        for(String key : mapRegExp.keySet()) {
            List <Matcher> matcherListTemp;
            switch on key {
                when 'subject' {
                    matcherListTemp = executeRegEx(email.subject, mapRegExp.get(key));
                }
                when 'body' {
                    matcherListTemp = executeRegEx(email.plainTextBody, mapRegExp.get(key));
                }
                when 'htmlbody' {
                    matcherListTemp = executeRegEx(email.htmlBody, mapRegExp.get(key));
                }
            }
            if(matcherListTemp.size() == 0) {
                return new MatcherResultInfoType(false , null);
            } else {
                matcherList.addAll(matcherListTemp);
            }
        }
        return  new MatcherResultInfoType(true , matcherList); 
    }

    private List <Matcher> executeRegEx(String str, List <String> regExList) {
        List <Matcher> matcherList = new List <Matcher>();
        for(String regEx : regExList) {
            Matcher matcher = Pattern.compile(regEx).matcher(str);
            if(matcher.find()) {
                matcherList.add(matcher);
            } else {
                return new List <Matcher>();
            }
        }
        return matcherList;
    }

    private class MatcherResultInfoType {
        Boolean success;
        List <Matcher> matcherList;

        public MatcherResultInfoType(Boolean success, List <Matcher> matcherList) {
            this.success = success;
            this.matcherList = matcherList;
        }
    }
}