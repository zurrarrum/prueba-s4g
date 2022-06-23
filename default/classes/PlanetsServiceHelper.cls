public with sharing class PlanetsServiceHelper {
    public HttpResponse scanPlanet(Id planetId) {
        Planet__c planet = new PlanetsSelector(true).selectById(new Set <Id> {planetId})[0];
        Planet_Code__mdt planetCode = new PlanetCodesSelector_MDT().selectByExternalId(planet.External_Id__c);
        HTTPResponse res;
        if (planetCode != null) {
            try {
                Integer retries = 3;
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:PlanetScan/scan/' + EncodingUtil.UrlEncode(planetCode.AccessCode__c,'UTF-8'));
                req.setMethod('GET');
                Http http = new Http();
                Integer cont = 0;
                Boolean success = false;
                do {
                    System.debug('entro');
                    res = http.send(req);
                    if (res.getStatusCode() == 200) {
                        success = true;
                    } else {
                        cont ++;
                    }
                } while(!success && cont < retries);
            } catch(Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getLineNumber());
            }
        }
        return res;
    }
}