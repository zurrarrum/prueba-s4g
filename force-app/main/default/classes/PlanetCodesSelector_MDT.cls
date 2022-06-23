public class PlanetCodesSelector_MDT {
    public Planet_Code__mdt selectByExternalId(String extId) {
        List <Planet_Code__mdt> palnetCodes = Planet_Code__mdt.getAll().values();
        for (Planet_Code__mdt planetCode : palnetCodes) {
            if (planetCode.External_id__c == extId) {
                return planetCode;
            }
        }
        return null;
    }
}