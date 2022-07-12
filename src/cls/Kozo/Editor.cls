Class Kozo.Editor Extends %CSP.Page
{

ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	set className=%request.Data("doc",1)
	set title=$parameter($e(className,1,*-4),"DocumentName")
	&html<
	
	<!DOCTYPE html>
	<html lang="en">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1">
	    <title>Kozo Page Builder</title>
	    
		<link rel="stylesheet" data-name="vs/editor/editor.main" href="./js/lib/vs/editor/editor.main.css" />
		
		<link rel="icon" href="favicon.ico?v=3">

	    <link rel="stylesheet" href="./style/utils.css">	    
	    <link rel="stylesheet" href="./style/vars.css">
	    <link rel="stylesheet" href="./style/main.css">
	    <link rel="stylesheet" href="./style/form.css">	    
	    <link rel="stylesheet" href="./style/github-markdown.css">
	    	        
	</head>
	<body>
	
	<div class="editor" id="editor">
		<div class="editor-bar" id="editor-bar">
			<div style="font-weight:bold; font-size: 110%;"><%=title%></div>
			<div style="color:grey; font-size: 90%;"><%=className%></div>
		</div>
		<div class="editor-content" id="editor-content"></div>
	</div>
	
	<div class="preview" id="preview">
		<div class="preview-content">
			<div class="preview-content" id="preview-content">
				<div class="markdown-body preview-content-inner" id="preview-content-inner">
				</div>
			</div>
		</div>
	</div>
	
	</body>


	<script language="javascript">
	var require = { paths: { vs: './js/lib/vs' } };
   </script>
   
	<script src="./js/lib/vs/loader.js"></script>
	<script src="./js/lib/vs/editor/editor.main.nls.js"></script>
	<script src="./js/lib/vs/editor/editor.main.js"></script>
	
	<script type="module" src="./main.js"></script>
    
	</html>
	
	>
	quit $$$OK
}

}

