({
    doInit: function (component, event, helper) {
        helper.FetchContents(component, event, helper);
    },
    
    Search: function(component, event, helper) {
        var sKey = component.find("searchBox").get("v.value");
        component.set("v.searchKeyword", sKey);
        helper.FetchContents(component, event, helper);
    },
    
    sortByTitle: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Title');
        if(component.get("v.arrowDirection") == 'asc'){
            component.set("v.arrowDirection", 'desc');
        } else {
            component.set("v.arrowDirection", 'asc');
        }
        helper.FetchContents(component, event, helper);
    },
    
    sortByDate: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'CreatedDate');
        if(component.get("v.arrowDirection") == 'asc'){
            component.set("v.arrowDirection", 'desc');
        } else {
            component.set("v.arrowDirection", 'asc');
        }
        
        helper.FetchContents(component, event, helper);
    },
    
    sortBySize: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'ContentSize');
        if(component.get("v.arrowDirection") == 'asc'){
            component.set("v.arrowDirection", 'desc');
        } else {
            component.set("v.arrowDirection", 'asc');
        }
        helper.FetchContents(component, event, helper);
    }, 
    
    sortByType: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'FileType');
        if(component.get("v.arrowDirection") == 'asc'){
            component.set("v.arrowDirection", 'desc');
        } else {
            component.set("v.arrowDirection", 'asc');
        }
        helper.FetchContents(component, event, helper);
    },
    
    previewFiles : function(component,event,helper){
        var documentId = event.target.getAttribute('data-Id');
        var type = event.target.getAttribute('type');
        var data = [];
        if(type == 'All'){
            data = component.get("v.allFiles");
        } else if(type == 'Images'){
            data = component.get("v.imageData");
        } else if(type == 'Files'){
            data = component.get("v.filesData");
        }else if(type == 'Attachment'){
            data = component.get("v.allAttachment");
        }
        var docIds = [];
        data.forEach(function(record) {
            docIds.push(record.Id);
        });
        $A.get('e.lightning:openFiles').fire({ recordIds : docIds, selectedRecordId : documentId});
        
    },
});