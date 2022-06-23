@isTest
public class TestMockFactory implements HttpCalloutMock {

    private String method;

    public TestMockFactory(String method) {
        this.method = method;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HTTPResponse res = new HTTPResponse();

        switch on method {
            when 'SCAN_OK' {
                planetscanOK(req, res);
            }
            when 'SCAN_KO' {
                planetscanKO(req, res);
            }
            when 'SCAN_EX' {
                planetscanExc(req, res);
            }
        }
        return res;
    }

    private void planetscanOK(HTTPRequest req, HttpResponse res) {
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"found":true}');
        res.setStatusCode(200);
    }

    private void planetscanKO(HTTPRequest req, HttpResponse res) {
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"error":"sample errror"}');
        res.setStatusCode(500);
    }

    private void planetscanExc(HTTPRequest req, HttpResponse res) {
        throw new CalloutException('sample');
    }
}