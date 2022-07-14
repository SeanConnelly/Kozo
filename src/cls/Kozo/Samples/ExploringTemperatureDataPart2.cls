Class Kozo.Samples.ExploringTemperatureDataPart2 Extends Kozo.Page
{

Parameter DocumentName = "Exploring Climate Temperature Data - Part 2";

XData RawContent
{
<content><![CDATA[# Exploring Climate Temperature Data - Part 2

I've wired up 8,599,211 temperature readings from 3448 cities to query and compare the average monthly temperatures for the last three centuries.

After spending some time exploring the graphs the trend of constant upwards change for all cities is very obvious. So much so that I feel as if I must have made a huge mistake in the data or the queries.

If this is indeed accurate then the earth is warming up much faster than I had perceived from mainstream news. Perhaps I have taken the doomsday predictions with a little too much salt. If temperatures are rising as quickly as these graphs suggest then future generations really are going to rely on the decisions we make today.

My immediate question is are there resources like this out there that everyday people can interact with?

## Select City & Country

```JavaScript
//set defaults
data.SelectedCountry='UNITED KINGDOM'
data.SelectedCity='LONDON'
```

```SQL {"name": "Countries"}
SELECT DISTINCT Country
FROM Climate.TemperatureByCity
```

```form
<label class="form">Select Country</label>
<select name="SelectedCountry" data-options="Countries.Country" class="form">
        <option>Select</option>
</select>
```

```SQL {"name": "Cities","params":["SelectedCountry"]}
SELECT DISTINCT City
FROM Climate.TemperatureByCity
WHERE Country = ?
```

```form
<label class="form">Select City</label>
<select name="SelectedCity" data-options="Cities.City" class="form">
        <option>Select</option>
</select>
```

```SQL {"name":"MinMax19","params":["SelectedCity"]}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = ? and LogYear>1799 and LogYear<1900
GROUP BY LogMonth
```

```SQL {"name":"MinMax20","params":["SelectedCity"]}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = ? and LogYear>1899 and LogYear<2000
GROUP BY LogMonth
```

```SQL {"name":"MinMax21","params":["SelectedCity"]}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = ? and LogYear>1999 and LogYear<2100
GROUP BY LogMonth
```

```JavaScript
data.Min19 = [];
data.Max19 = [];
data.Avr19 = [];
data.MinMax19.map( mm => {
    data.Min19.push(mm.MinAverage);
    data.Max19.push(mm.MaxAverage);
    data.Avr19.push(mm.AvrAvr);    
})
```

```JavaScript
data.Min20 = [];
data.Max20 = [];
data.Avr20 = [];
data.MinMax20.map( mm => {
    data.Min20.push(mm.MinAverage);
    data.Max20.push(mm.MaxAverage);
    data.Avr20.push(mm.AvrAvr);    
})
```

```JavaScript
data.Min21 = [];
data.Max21 = [];
data.Avr21 = [];
data.MinMax21.map( mm => {
    data.Min21.push(mm.MinAverage);
    data.Max21.push(mm.MaxAverage);
    data.Avr21.push(mm.AvrAvr);    
})
```

### {{SelectedCity}} - Monthly Average Temperatures by Century

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: '19th Avr',
            data: data.Avr19,
            fill: false,
            borderColor: 'hsl(120, 90%, 50%)',
            tension: 0.3
        },{
            label: '20th Max',
            data: data.Avr20,
            fill: false,
            borderColor: 'hsl(180, 90%, 50%)',
            tension: 0.3
        },{
            label: '21st Avr',
            data: data.Avr21,
            fill: false,
            borderColor: 'hsl(350, 90%, 50%)',
            tension: 0.3
        }]
    }
}
```]]></content>
}

}

