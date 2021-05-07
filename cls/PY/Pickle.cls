/// Python object serializer
Class PY.Pickle Extends %SerialObject
{

Property SerializedData As %Stream.GlobalCharacter;

Property Classname As %String(MAXLEN = "");

Property Members As list Of %String(MAXLEN = "");

Method Pickle(pythonObject) As %Status
{
	Set status = $$$OK
	Try {
		$$$ThrowOnError($this.SerializedData.Clear())
		
		// Deeply nested objects will throw an error
		Set dumpsstatus = $$$OK
		Try {
			$$$ThrowOnError($this.SerializedData.Write(..DumpsWrapper(pythonObject)))
		}
		Catch innerexception {
			Set dumpsstatus = innerexception.AsStatus()
		}
		
		// Try again as a string
		If $$$ISERR(dumpsstatus) {
			Try {
				$$$ThrowOnError($this.SerializedData.Write(..DumpsWrapper(..str(pythonObject))))
			}
			Catch {
				// give up 
			}
		}
		
		$$$ThrowOnError($this.SerializedData.Write(..DumpsWrapper(pythonObject)))
		Set $this.Classname = ..GetClassname(pythonObject)
		
		While $this.Members.Count() > 0 {
			Do $this.Member.RemoveAt(0)
		}
		
		Set builtins = ##class(%SYS.Python).Import("builtins")
		Set members = builtins.list()
		Set members = ..GetMembers(pythonObject)
		Set i = 0
		While i < members."__len__"() {
			Set member = members."__getitem__"(i)
			$$$ThrowOnError($this.Members.Insert(member))
			Do $increment(i)
		}
	}
	Catch exception {
		Set status = exception.AsStatus()
	}
	Quit status
}

Method Unpickle(Output status As %Status) As %String
{
	Set status = $$$OK
	Set bytes = ""
	Try {
		$$$ThrowOnError($this.SerializedData.Rewind())
		Set bytes = ..LoadsWrapper(##class(%SYS.Python).Bytes($this.SerializedData.Read()))
	}
	Catch exception {
		Set status = exception.AsStatus()
		Set bytes = ""
	}
	Quit bytes
}

ClassMethod DumpsWrapper(pythonObject) [ Internal, Language = python ]
{
	import pickle
	bytes = pickle.dumps(pythonObject)
	return bytes
}

ClassMethod LoadsWrapper(bytes) [ Internal, Language = python ]
{
	import pickle
	return pickle.loads(bytes)
}

ClassMethod GetClassname(pythonObject) [ Internal, Language = python ]
{
	return type(pythonObject).__name__
}

ClassMethod GetMembers(pythonObject) [ Internal, Language = python ]
{
	import inspect
	memberNames = []
	members = inspect.getmembers(pythonObject)
	i = 0
	while i < len(members):
		memberNames.append(members[i][0])
		i=i+1
	return memberNames
}

ClassMethod str(soup) [ Language = python, Private ]
{
	return str(soup)
}

Storage Default
{
<Data name="PickleState">
<Value name="1">
<Value>SerializedData</Value>
</Value>
<Value name="2">
<Value>Classname</Value>
</Value>
<Value name="3">
<Value>Members</Value>
</Value>
</Data>
<State>PickleState</State>
<StreamLocation>^PY.PickleS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

