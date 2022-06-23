//TODO: Create virtual classs with Selector methods and variables
public with sharing class ContactsSelector {
    private enum OrderingDir {ASSCENDING, DESCENDING}
    private final String DEFAULT_FIELDSET = 'default';
    private Set <String> fieldsToQuery = new Set <String>();
    private String fieldsToQueryString;
    private Set <Schema.FieldSet> fieldSets;
    private Boolean useFieldSet = false;
    private Set <Schema.SObjectField> defaultFields = new Set <Schema.SObjectField> {
        Contact.Id,
        Contact.Name,
        Contact.Email
    };
    private String condition;
    private Schema.SObjectField orderingField;
    private OrderingDir orderingDirection;
    private Integer limitQuery;

    public ContactsSelector(Boolean useFieldSet) {
        this.useFieldSet = useFieldSet;
        this.fieldSets = new Set <Schema.FieldSet>{Contact.sObjectType.getDescribe().fieldsets.getMap().get(DEFAULT_FIELDSET)};
        this.setFieldsToQuery();
    }

    public ContactsSelector(List <String> fielSetList) {
        this.useFieldSet = true;
        this.fieldSets = new Set <Schema.FieldSet>();
        for (String fieldSetName : fielSetList) {
            Schema.FieldSet fieldset = Contact.sObjectType.getDescribe().fieldsets.getMap().get(fieldSetName);
            if (fieldset != null) {
                this.fieldSets.add(fieldset);
            }
        }
        this.setFieldsToQuery();
    }

    public List <Contact> selectByEmail(String email) {
        this.condition = 'Email =: email';
        return (List <Contact>)Database.query(this.getQuery()); 
    }

    private void setFieldsToQuery() {
        for (Schema.SObjectField field : defaultFields) {
            fieldsToQuery.add(field.getDescribe().getName());
        }
        if (this.useFieldSet) {
            for (Schema.FieldSet fielset : fieldSets) {
                for (FieldSetMember member : fielset?.getFields()) {
                    fieldsToQuery.add(member.getSObjectField().getDescribe().getName());
                }
            }
        }
        this.fieldsToQueryString = String.join(new List <String>(fieldsToQuery), ',');
    }

    private String getQuery() {
        return String.escapeSingleQuotes('SELECT ' + this.fieldsToQueryString + ' FROM Contact' + this.getCondition() + getOrdering() + getLimit());
    }

    private String getCondition() {
        return this.condition != null ? ' WHERE ' + String.escapeSingleQuotes(this.condition) : ''; 
    }

    private String getOrdering() {
        String toReturn = '';
        if (orderingField != null) {
            toReturn = ' ORDER BY ' + orderingField.getDescribe().getName() + (orderingDirection == OrderingDir.DESCENDING ? ' DESC' : 'ASC');
        }
        return toReturn;
    }

    private String getLimit() {
        return this.limitQuery != null ? ' LIMIT ' + this.limitQuery : '';
    }
}