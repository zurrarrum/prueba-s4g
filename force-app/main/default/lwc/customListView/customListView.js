import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getRecords from '@salesforce/apex/CustomListViewCtrl.getRecords';
import getColumns from '@salesforce/apex/CustomListViewCtrl.getColumns';
import getFieldset from '@salesforce/apex/CustomListViewCtrl.getFieldsetFields';
import scanPlanet from '@salesforce/apex/CustomListViewCtrl.scanPlanet';
import { subscribe } from 'lightning/empApi';

export default class CustomListView extends LightningElement {
    @api sobjectName = 'Case';
    @api fieldSetListView = 'CaseListView';
    @api fieldSetDetail = 'CaseDetail';
    @api whereClausule = 'IsClosed = false AND Planet__c != null';
    @api orderClausule = 'CreatedDate DESC';
    @api limitClausule = '5';
    @api platformEventName = 'Case';
    @api hideButton = false;
    allLoaded = false;
    channelName = '/event/Refresh__e';
    subscription;
    detail = false;
    selectedId;
    detailFields;
    data;
    columns;
    columnsDataTable;
    emptyMessage;
    fieldsMap;
    hasRendered = false;
    renderedCallback() {
        this.init();
    }

    connectedCallback() {
        this.subscribeEvent();
    }

    init() {
        if (this.hasRendered) {
            return;
        }
        this.hasRendered = true;
        this.getColumnsInfo()
        .then(() => {
            return this.getDataInfo();
        })
        .then (() => {
            this.getDetailFields();
        })
    }

    getColumnsInfo() {
        return new Promise(resolve => {
            getColumns({
                sobjectName: this.sobjectName,
                fieldSetName: this.fieldSetListView
            })
            .then(value => {
                this.columns = JSON.parse(value);
                this.columnsDataTable = JSON.parse(value);
                this.columnsDataTable.push({
                    type: 'button', 
                    typeAttributes: {  
                        label: 'View',
                        name: 'View',
                        title: 'View',
                        disabled: false,
                        value: 'view',
                        variant: 'brand'
                    }
                });
               console.log(this.columns);
               resolve();
            })
        })
    }

    getDataInfo() {
        return new Promise(resolve => {
            getRecords({
                sobjectName: this.sobjectName,
                columnsJSON: JSON.stringify(this.columns),
                whereClausule: this.whereClausule,
                orderClausule: this.orderClausule,
                limitClausule: this.limitClausule
            })
            .then(value => {
                this.data = value;
                this.emptyMessage = value.length === 0;
                console.log(this.data);
                resolve()
            })
        });
    }

    callRowAction(event) {
        this.selectedId = event.detail.row.id;
        this.detail = true;
    }

    getDetailFields() {
        getFieldset({
            sobjectName: this.sobjectName,
            fieldsetName: this.fieldSetDetail
        })
        .then(value => {
            this.detailFields = value;
            this.allLoaded = true;
        })
    }

    back() {
        this.selectedId = undefined;
        this.detail = false;
    }

    scan() {
        this.allLoaded = false;
        scanPlanet({caseId: this.selectedId})
        .then(value => {
            const response = JSON.parse(value);
            if (response.error) {
                this.fireToast('Los sensores están fuera de servicio', response.errorMessage, 'error');
            } else {
                if (response.found) {
                    this.fireToast('Lo hemos encontrado!', 'El escaneo se ha realizado con exito y hemos encontrado a baby yoda en el planeta', 'success');
                } else {
                    this.fireToast('Sigue buscando!', 'El escaneo se ha realizado con exito pero no hemos encontrado a baby yoda en el planeta', 'warning');
                }
                this.getDataInfo()
                .then(() => {
                    this.back();
                });
            }
            this.allLoaded = true;
        })
    }

    subscribeEvent() {
        const messageCallback = (response) => {
            if (response.data.payload.Name__c === this.platformEventName) {
                this.getDataInfo();
            }
        }
        subscribe(this.channelName, -1, messageCallback).then(response => {
            this.isSubscribedChannels = true;
            if(response){
                this.subscription = response;
            }
        });
    }

    fireToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}