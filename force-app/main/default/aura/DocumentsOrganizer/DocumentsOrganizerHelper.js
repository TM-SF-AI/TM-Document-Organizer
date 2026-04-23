({
    FetchContents : function(component, event, helper) {
        var action = component.get('c.fetchAllFiles'); 
        action.setParams({
            searchKeyWord : component.get("v.searchKeyword"),
            parentId : component.get("v.recordId"),
            sortField : component.get("v.selectedTabsoft"),
            orderType : component.get("v.arrowDirection")
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if(state == 'SUCCESS'){
                var storeResponse = response.getReturnValue();
                var wrapper = response.getReturnValue();
                component.set("v.fileList", wrapper);
                component.set("v.allAttachment", wrapper.allAttachment);
                component.set("v.allFiles", wrapper.allFiles);
                component.set("v.imageData", wrapper.allimages);
                component.set("v.filesData", wrapper.otherfiles);
                component.set("v.allEmailImages", wrapper.allEmailImages);
                component.set("v.allEmailDocuments", wrapper.allEmailDocuments);
                component.set("v.TotalFilesAndAttachment",wrapper.TotalFilesAndAttachment);

            }
        });
        $A.enqueueAction(action);
    }
});