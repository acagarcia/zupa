Class PY.URLTraverser [ Abstract ]
{

ClassMethod Traverse(rootURL As %String = "", className As %String, storeURLContent As %Boolean = 0, maxProcessCount As %Integer = 10000, targetHangms As %Integer = 0, variabilityHangms As %Integer = 0, longHangSeconds As %Integer = 0, longHangPercentChance As %Integer = 0) As %Status
{
	Set status = $$$OK
	Try {
		Set compiledClass = ""
		If ##class(%Dictionary.CompiledClass).%ExistsId(className) {
			Set compiledClass = ##class(%Dictionary.CompiledClass).%OpenId(className,,.status)
			$$$ThrowOnError(status)
			
			If compiledClass.PrimarySuper '[ "PY.AbstractURL" {
				Set compiledClass = ""
			}
		}
		If (maxProcessCount > 0) && $IsObject(compiledClass) {
			Set processCount = 0
			If (rootURL '= "") {
				Set rootURLExists = $classmethod(className,"URLExists",rootURL,.urlObjectId)
				If 'rootURLExists || '$classmethod(className,"IsProcessedGetStored",urlObjectId) {
					Do ..ProcessURL(rootURL,className,storeURLContent)
					Do $increment(processCount)
				}
			}
			If (processCount < maxProcessCount) {
				Set SQLTableName = compiledClass.SqlQualifiedNameQ
				Set rs = ##class(%SQL.Statement).%ExecDirect(,"SELECT URL From " _ SQLTableName _" Where IsProcessed = 0")
				While rs.%Next(.status) && (processCount < maxProcessCount) {
					$$$ThrowOnError(status)
					Do ..ProcessURL(rs.URL,className,storeURLContent)
					Do $increment(processCount)
					If targetHangms > 0 {
						Hang ..GenerateHangSeconds(targetHangms,variabilityHangms,longHangSeconds,longHangPercentChance)
					}
				}
				$$$ThrowOnError(status)
			}
		}
	}
	Catch exception {
		Set status = exception.AsStatus()
	}
	Quit status
}

ClassMethod GenerateHangSeconds(targetms As %Integer, variabilityms As %Integer = 0, longHangSeconds As %Integer = 0, longHangPercentChance As %Integer = 0) As %Integer [ Private ]
{
	Set longHangChanceIsValid = (longHangSeconds > 0) && (longHangPercentChance > 0) && (longHangPercentChance < 100)
	If longHangChanceIsValid && ($Random(100) < longHangPercentChance) {
		Set hangSeconds = longHangSeconds
	}
	Else {
		Set hangms = targetms
		If (variabilityms >0) && (variabilityms >= targetms) {
			Set sign = $SELECT($Random(2)=0:-1,1:1)
			Set hangms = hangms + sign*$random(variabilityms)
		}
		
		Set hangSeconds = hangms/1000
	}
	Quit hangSeconds
}

ClassMethod ProcessURL(topLink As %String, className As %String, storeURLContent As %Boolean = 0) [ Private ]
{
	If '$classmethod(className,"URLExists",topLink,.urlObjectId) || '$classmethod(className,"IsProcessedGetStored",urlObjectId) {
		Set initLevel = $TLevel
		TStart
		Try {
			If $classmethod(className,"URLExists",topLink,.urlObjectId) {
				Set urlObject = $classmethod(className,"%OpenId",urlObjectId,,.status)
				$$$ThrowOnError(status)
			}
			Else {
				Set urlObject = $classmethod(className,"%New")
				Set urlObject.URL = topLink
			}
			Set pageContent = ..GetPageContent(topLink)
			Set soup = ..GetSoup(pageContent)
			If storeURLContent {
				Set pickle = ##class(PY.Pickle).%New()
				Set status = pickle.Pickle(soup)
				If $$$ISOK(status) {
					Set urlObject.Soup = pickle
				}
				Else {
					// Ignore errors pickling
					Set status = $$$OK
				}
			}
			
			Set builtins = ##class(%SYS.Python).Import("builtins")
			Set topLevelList = builtins.list()
			Set topLevelList = $classmethod(className,"GetURLList",soup)
			
			Set i = 0
			While i < topLevelList."__len__"() {
				Set childLink = topLevelList."__getitem__"(i)
				If '$classmethod(className,"URLExists",childLink,.childDocId) {
					Set childDoc = $classmethod(className,"%New")
					Set childDoc.URL = childLink
					$$$ThrowOnError(childDoc.%Save())
				}
				Else {
					Set childDoc = $classmethod(className,"%OpenId",childDocId,,.status)
					$$$ThrowOnError(status)
				}
				$$$ThrowOnError(urlObject.SubURLs.Insert(childDoc))
				
				Do $increment(i)
			}
			Set urlObject.IsProcessed = 1
			$$$ThrowOnError(urlObject.%Save())
			TCommit
		}
		Catch exception {
			While ($TLevel > initLevel) {
				TRollback 1
			}
			$$$ThrowOnError(exception.AsStatus())
		}
	}
}

ClassMethod GetPageContent(url As %String) [ Language = python, Private ]
{
	import requests
	page = requests.get(url)
	
	max_retry_count = 10
	retry_count = 0
	while (page.status_code!=200) and (retry_count < max_retry_count):
		page = requests.get(url)
		retry_count= retry_count+1
		
	return page.content
}

ClassMethod GetSoup(pageContent As %String) [ Language = python, Private ]
{
	from bs4 import BeautifulSoup
	return BeautifulSoup(pageContent, 'html.parser')
}

}

