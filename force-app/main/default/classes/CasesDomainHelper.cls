public with sharing class CasesDomainHelper {
    public void parseDinDjarinEmail(List <Case> news) {
        Set <String> planetsToQuery = new Set <String>();
        List <CaseInfoType> toProcess = new List <CaseInfoType>();
        for (Case cas : news) {
            if (cas.SuppliedEmail != null && !cas.EmailService__c) {
                Matcher matcher = Pattern.compile('[\\w\\sÀ-ÿ]+:\\s?(\\w+-\\d+)$').matcher(cas.Description);
                if(matcher.find()) {
                    string planetCode = matcher.group(1);
                    planetsToQuery.add(planetCode);
                    toProcess.add(new CaseInfoType(cas, planetCode));
                } else {
                    //In order to avoid email response, add a checkbox that marks current case to be deleted in after insert event
                    cas.addError('Email body does not match the specificied format');
                }
            }
        }
        if (!planetsToQuery.isEmpty()) {
            Map <String, Id> planets = getPlanetCodes(planetsToQuery);
            for (CaseInfoType casInfoType : toProcess) {
                if (planets.containsKey(casInfoType.planetCode)) {
                    casInfoType.cas.Planet__c = planets.get(casInfoType.planetCode);
                    casInfoType.cas.Status = 'Ready to Scann';
                    firePlatformEvent();
                } else {
                    //In order to avoid email response, add a checkbox that marks current case to be deleted on after insert event
                    casInfoType.cas.addError('Planet not found');
                }
            }
        }
    }

    private Map <String, Id> getPlanetCodes(Set <String> planetCodes) {
        Map <String, Id> toReturn = new Map <String, Id>();
        List <Planet__c> planets = new PlanetsSelector(true).selectByExternalId(planetCodes);
        for (Planet__c planet : planets) {
            toReturn.put(planet.External_Id__c, planet.Id);
        }
        return toReturn;
    }

    private void firePlatformEvent() {
        List <Refresh__e> refreshEvents = new List <Refresh__e> {new Refresh__e(Name__c = 'Case')};
        EventBus.publish(refreshEvents);
    }

    private class CaseInfoType {
        Case cas;
        String planetCode;
        public CaseInfoType(Case cas, String planetCode) {
            this.cas = cas;
            this.planetCode = planetCode;
        }
    }
}