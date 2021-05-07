Class PY.DocURL Extends PY.AbstractURL
{

Parameter ROOTURL = "https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=ALL";

Parameter STOREURLCONTENT = 0;

Parameter MAXPROCESSCOUNT = 1;

ClassMethod GetURLList(soup As %SYS.Python) [ Language = python ]
{
	import re
	from bs4 import BeautifulSoup
	
	output = []
	links = soup.find_all(href=re.compile("Doc.View.cls"))
	for link in links:
		output.append("https://docs.intersystems.com/irislatest/csp/docbook/" + link['href'])
	return output
}

Storage Default
{
<Data name="DocURLDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>URL</Value>
</Value>
<Value name="3">
<Value>Soup</Value>
</Value>
<Value name="4">
<Value>IsProcessed</Value>
</Value>
</Data>
<Data name="SubURLs">
<Attribute>SubURLs</Attribute>
<Structure>subnode</Structure>
<Subscript>"SubURLs"</Subscript>
</Data>
<DataLocation>^PY.DocURLD</DataLocation>
<DefaultData>DocURLDefaultData</DefaultData>
<IdLocation>^PY.DocURLD</IdLocation>
<IndexLocation>^PY.DocURLI</IndexLocation>
<StreamLocation>^PY.DocURLS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

