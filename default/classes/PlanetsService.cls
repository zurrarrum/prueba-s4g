public with sharing class PlanetsService {
    private static PlanetsServiceHelper helper = new PlanetsServiceHelper();
    public static HttpResponse scanPlanet(Id planetId) {
        return helper.scanPlanet(planetId);
    }
}