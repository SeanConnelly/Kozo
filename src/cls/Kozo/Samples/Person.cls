/// do ##class(Kozo.Samples.Person).Populate(10000)
Class Kozo.Samples.Person Extends (%Persistent, %Populate)
{

Property Name As %String(POPSPEC = "Name()");

Property Title As %String(POPSPEC = "Title()");

Property Street As %String(POPSPEC = "Street()");

Property City As %String(POPSPEC = "City()");

Property State As %String(POPSPEC = "USState()");

Property Zip As %String(POPSPEC = "USZip()");

Storage Default
{
<Data name="PersonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Title</Value>
</Value>
<Value name="4">
<Value>City</Value>
</Value>
<Value name="5">
<Value>State</Value>
</Value>
<Value name="6">
<Value>Zip</Value>
</Value>
<Value name="7">
<Value>Street</Value>
</Value>
</Data>
<DataLocation>^Kozo.Samples.PersonD</DataLocation>
<DefaultData>PersonDefaultData</DefaultData>
<ExtentSize>10000</ExtentSize>
<IdLocation>^Kozo.Samples.PersonD</IdLocation>
<IndexLocation>^Kozo.Samples.PersonI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3.91</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="City">
<AverageFieldSize>7.25</AverageFieldSize>
<Selectivity>3.8461%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>15.8</AverageFieldSize>
<Selectivity>0.0100%</Selectivity>
</Property>
<Property name="State">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>1.9953%</Selectivity>
</Property>
<Property name="Street">
<AverageFieldSize>16.57</AverageFieldSize>
<Selectivity>0.0100%</Selectivity>
</Property>
<Property name="Title">
<AverageFieldSize>20.51</AverageFieldSize>
<Selectivity>0.7039%</Selectivity>
</Property>
<Property name="Zip">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>0.0112%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-472</BlockCount>
</SQLMap>
<StreamLocation>^Kozo.Samples.PersonS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

