Class Climate.TemperatureByCity Extends %Persistent
{

Property Year As %Integer [ SqlFieldName = LogYear ];

Property Month As %Integer [ SqlFieldName = LogMonth ];

Property Average As %Integer;

Property Uncertainty As %Integer;

Property City As %String;

Property Country As %String;

Property Latitude As %String;

Property Longitude As %String;

Index YearIndex On Year;

Index MonthIndex On Month;

Index CityIndex On City;

Index CountryIndex On Country;

/// pull - https://github.com/SeanConnelly/EarthSurfaceTemperatureDataByCity
/// pass location of "data" folder to load all files
ClassMethod ImportFromGitHub(pFolder As %String = "C:\Temp\EarthSurfaceTemperatureDataByCity\data")
{
	kill ^Climate.TemperatureByCityD
	kill ^Climate.TemperatureByCityI
	set rs=##class(%Library.ResultSet).%New("%Library.File:FileSet")
	set sc=rs.Execute(pFolder,"*.csv")
	while rs.%Next() {
		write !,"Loading: ",rs.Data("Name")
		set sc=..ImportFile(rs.Data("Name"))
		if $$$ISERR(sc) write !,$SYSTEM.Status.GetErrorText(sc)
	}
}

ClassMethod ImportFile(pFile As %String = "D:\tfb\climateData\GlobalLandTemperaturesByCity.csv")
{
	set file=##class(%Stream.FileCharacter).%New()
	set sc=file.LinkToFile(pFile)
	set file.TranslateTable="UTF8"
	if $$$ISERR(sc) quit sc
	set record=file.ReadLine()
	while (file.AtEnd=0),$$$ISOK(sc) {
		set sc=..Add(record)
		set record=file.ReadLine()
	} 
	quit sc
}

ClassMethod Add(record)
{
	set tbc=..%New()
	set tbc.Year=$p($p(record,",",1),"-",1)
	set tbc.Month=$p($p(record,",",1),"-",2)	
	set tbc.Average=$p(record,",",2)
	set tbc.Uncertainty=$p(record,",",3)
	set tbc.City=$p(record,",",4)
	set tbc.Country=$p(record,",",5)
	set tbc.Latitude=$p(record,",",6)
	set tbc.Longitude=$p(record,",",7)
	quit tbc.%Save()
}

Storage Default
{
<Data name="TemperatureByCityDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Date</Value>
</Value>
<Value name="3">
<Value>Average</Value>
</Value>
<Value name="4">
<Value>Uncertainty</Value>
</Value>
<Value name="5">
<Value>City</Value>
</Value>
<Value name="6">
<Value>Country</Value>
</Value>
<Value name="7">
<Value>Latitude</Value>
</Value>
<Value name="8">
<Value>Longitude</Value>
</Value>
<Value name="9">
<Value>Year</Value>
</Value>
<Value name="10">
<Value>Month</Value>
</Value>
</Data>
<DataLocation>^Climate.TemperatureByCityD</DataLocation>
<DefaultData>TemperatureByCityDefaultData</DefaultData>
<IdLocation>^Climate.TemperatureByCityD</IdLocation>
<IndexLocation>^Climate.TemperatureByCityI</IndexLocation>
<StreamLocation>^Climate.TemperatureByCityS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

