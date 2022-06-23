public with sharing class CustomListViewCtrl {
    
    @AuraEnabled
    public static String getColumns(String sobjectName, String fieldSetName){
        List <ColumnInfoType> toReturn = new List <ColumnInfoType>();
        try {
            Schema.FieldSet fieldset = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fieldsets.getMap().get(fieldSetName);
            for (FieldSetMember member : fieldset.getFields()) {
                Schema.DescribeFieldResult field = member.getSObjectField().getDescribe();
                ColumnInfoType columnInfo = new ColumnInfoType(field.getLabel(), field.getName(), field.getType());
                toReturn.add(columnInfo);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(toReturn);
    }

    @AuraEnabled
    public static List <Map <String, String>> getRecords(String sobjectName, String columnsJSON, String whereClausule, String orderClausule, Integer limitClausule) { 
        List <Map <String, String>> toReturn = new List <Map <String, String>>();
        try {
            Set <String> fieldsToQuery = new Set <String>{'Id'};
            Map <String, String> fieldTypes = new Map <String, String>();
            List <ColumnInfoType> columns = (List <ColumnInfoType>)JSON.deserialize(columnsJSON, List <ColumnInfoType>.class);
            for (ColumnInfoType column : columns) {
                fieldTypes.put(column.fieldName, column.type);
                fieldsToQuery.add(column.fieldName);
                if (column.type == 'url') {
                    fieldsToQuery.add(getRelatedObjectName(column.fieldName));
                }
            }
            System.debug(buildQuery(fieldsToQuery, sobjectName, whereClausule, orderClausule, limitClausule));
            List <SObject> sobjlist = Database.query(buildQuery(fieldsToQuery, sobjectName, whereClausule, orderClausule, limitClausule));
            toReturn = getData(fieldTypes, sobjlist);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return toReturn;
    }

    @AuraEnabled
    public static List <String> getFieldsetFields(String sobjectName, String fieldsetName) {
        List <String> toReturn = new List <String>();
        try {
            Schema.FieldSet fieldset = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fieldsets.getMap().get(fieldSetName);
            for (FieldSetMember member : fieldset.getFields()) {
                Schema.DescribeFieldResult field = member.getSObjectField().getDescribe();
                toReturn.add(field.getName());
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return toReturn;
    }

    @AuraEnabled
    public static String scanPlanet(Id caseId){
        ResponseInfoType toReturn;
        try {
            Case cas = new CasesSelector(true).selectById(new Set <Id>{caseId})[0];
            HTTPResponse response = PlanetsService.scanPlanet(cas.Planet__c);
            if (response != null) {
                toReturn = new ResponseInfoType(response);
                if (!toReturn.error) {
                    if (toReturn.found) {
                        cas.Status = 'Baby Yoda found';
                        cas.SuccessfulScan__c = true;
                    } else {
                        cas.Status = 'Baby Yoda not found';
                    }
                    update cas;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(toReturn);
    }

    public static String getRelatedObjectName(String fieldName) {
        String toReturn = '';
        if (fieldName.endsWith('__c')) {
            toReturn = fieldName.replace('__c', '__r.Name');
        } else if (fieldName.endsWith('Id')) {
            toReturn = fieldName.replace('Id', '.Name');
        }
        return toReturn;
    }

    private static String buildQuery(Set <String> fieldsToQuery, String sobjectName, String whereClausule, String orderClausule, Integer limitClausule) {
        String query = 'SElECT ';
        query += String.join(new List <String>(fieldsToQuery), ',');
        query += ' FROM ' + sobjectName;
        query += ' WHERE ' + whereClausule;
        if (orderClausule != null) {
            query += ' ORDER BY ' +  orderClausule;
        }
        if (limitClausule != null) {
            query += ' LIMIT ' +  limitClausule;
        }
        return String.escapeSingleQuotes(query);
    }

    private static List <Map <String, String>> getData(Map <String, String> fieldTypes, List <SObject> sobjList) {
        List <Map <String, String>> toReturn = new List <Map <String, String>>();
        for (SObject sobj :  sobjList) {
            Map <String, String> value = new Map <String, String>();
            value.put('id', (String)sobj.get('Id'));
            for (String field : fieldTypes.keySet()) {
                String fieldType = fieldTypes.get(field);
                if (fieldType == 'url' && sobj.get(field) != null) {
                    value.put(field, System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String)sobj.get(field));
                    String relatedFieldName = getRelatedObjectName(field);
                    System.debug(relatedFieldName);
                    List <String> fieldSplit = relatedFieldName.split('\\.');
                    System.debug(fieldSplit);
                    String parentValue = (String)sobj.getSObject(fieldSplit[0])?.get(fieldSplit[1]);
                    value.put(relatedFieldName, parentValue);
                } else {
                    value.put(field, (String)sobj.get(field));
                }
            }
            toReturn.add(value);
        }
        return toReturn;
    }

    @testVisible private class ColumnInfoType {
        private String label;
        private String fieldName;
        private String type;
        private TypeAttributesInfoType typeAttributes;
        public ColumnInfoType(String label, String fieldName, Schema.DisplayType type) {
            this.label = label;
            this.fieldName = fieldName;
            setFieldType(type);
        }

        private void setFieldType(Schema.DisplayType type) {
            if (type != null) {
                switch on type {
                    // when BOOLEAN {
                    //     this.type = 'boolean';
                    // }
                    // when CURRENCY {
                    //     this.type = 'currency';
                    // }
                    // when DATE {
                    //     this.type = 'date-local';
                    // }
                    // when DATETIME {
                    //     this.type = 'date-local';
                    // }
                    // when DOUBLE {
                    //     this.type = 'number';
                    // }
                    when EMAIL {
                        this.type = 'email';
                    }
                    // when PERCENT {
                    //     this.type = 'percent';
                    // }
                    // when PHONE {
                    //     this.type = 'phone';
                    // }
                    when REFERENCE {
                        this.type = 'url';
                        this.typeAttributes = new TypeAttributesInfoType(CustomListViewCtrl.getRelatedObjectName(fieldName));
                    }
                    // when URL {
                    //     this.type = 'url';
                    // }
                    when else {
                        this.type = 'text';
                    }
                }
            }
        }
    }

    private class TypeAttributesInfoType {
        private ColumnInfoType label;
        public TypeAttributesInfoType(String label) {
            this.label = new ColumnInfoType(null, label, null);
        }
    }

    private class ResponseInfoType {
        private Boolean found;
        private Boolean error;
        private String errorMessage;

        public ResponseInfoType(HttpResponse res) {
            if (res.getStatusCode() == 200) {
                error = false;
                Map <String, Boolean> body = (Map <String, Boolean>)JSON.deserialize(res.getBody(), Map <String, Boolean>.class);
                found = body.get('found');
            } else {
                error = true;
                Map <String, String> body = (Map <String, String>)(JSON.deserialize(res.getBody(), Map <String, String>.class));
                errorMessage = body.get('error');
            }
        }
    }
}