public interface IEmailServiceParser {
    void processEmail(Messaging.InboundEmail email, List <Matcher> matcherList, String attributes);
}