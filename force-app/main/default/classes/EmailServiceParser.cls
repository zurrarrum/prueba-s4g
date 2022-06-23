global class EmailServiceParser implements Messaging.InboundEmailHandler {
    private EmailServiceParserHelper helper = new EmailServiceParserHelper();
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        helper.handleInboundEmail(email, envelope);
        return result;
    }
}