Class Kozo.Page Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	set page="/kozo/Kozo.Editor.cls?doc="_..%ClassName(1)_".cls"
	set %response.Redirect=page
	quit 1
}

}

