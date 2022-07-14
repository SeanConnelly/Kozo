Class Kozo.Page Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	//if %request.Data("editor",1)=1 {
		set page="/kozo/Kozo.Editor.cls?ns="_$namespace_"&doc="_..%ClassName(1)_".cls"
		set %response.Redirect=page		
	//}
	quit 1
}

ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	if %request.Method="GET" quit ..CallProxy()
	if %request.Method="POST" quit ..DrawPage()
	Quit $$$OK
}

ClassMethod DrawPage()
{
	//TODO: Render a page view
}

ClassMethod CallProxy(pBlockID As %Integer, ByRef data As %DynamicObject)
{
	try {
		set blockID=%request.Data("blockID")
		do ..Call(blockID,.data)
		//auto convert JSON.Adapter objects to Dynamic Object
		set iterator = data.%GetIterator()
		while iterator.%GetNext(.key, .value) {
			if $ISOBJECT(value),value.%Extends("%JSON.Adaptor") {
				set sc=value.%JSONExportToString(.str)
				do data.%Set(key,{}.%FromJSON(str))
			}
		}
	} catch(err) {
		
	}
}

ClassMethod Call(pBlockID As %Integer, ByRef data As %DynamicObject)
{
	set data.Customer=##class(Northwind.Customers).%OpenId("ALFKI")
}

}

