({
    ConvertSize : function(component, event, helper) 
    {
        var size =   component.get("v.originalSize");
        console.log("originalSize***:"+size);
        var result;
        if(size < 1024) //1KB
        {
            result = size +" Bytes";
        }
        else if (size < 1048576) //1MB
        {
            result = (size/ 1024).toFixed(2) + " KB";
        }
            else if(size < 1073741824) //1GB
            {
                result = (size / 1048576).toFixed(2) + " MB";
            }
                else 
                {
                    result = (size / 1073741824).toFixed(2) + " GB";
                }
        console.log("convertedSize****:"+result);
        component.set("v.convertedSize", result);
    }
})