Class Kozo.Samples.ExploringTemperatureData Extends Kozo.Page
{

Parameter DocumentName = "Exploring Climate Temperature Data";

XData RawContent
{
<content><![CDATA[# Exploring Climate Temperature Data - Part 1
### Exploring climate temperature data with Kozo and IRIS

![image](./images/a-green-sunset.jpg)

## Introduction

This main goal for this document is to demonstrate Kozo as a tool for exploring and writting dynamic data rich documents.

## The Data

It looks like the following three datasets have a lot of raw data to work with.

- NOAA MLOST
- NASA GISTEMP
- Met Office HadCrut

But I soon find out that the data is not in a friendly format.

I eventually found a curated dataset from Berkeley Earth which is affiliated with 
Lawrence Berkeley National Laboratory. 

https://www.kaggle.com/datasets/berkeleyearth/climate-change-earth-surface-temperature-data

I selected the largest dataset I could find. A 520mb CSV files containing surface temperatures
by City. On inspection it contains 8.6 million records. This should be good enough for now.

I import the data into an IRIS table, making sure I have adequate indexes. I also decide to break
the dates down into seperate Year and Month fields as this will make slicing the data up by month
much faster.

```SQL {"name": "years"}
SELECT DISTINCT LogYear 
FROM Climate.TemperatureByCity
```

## Years

It's at this point I wonder how complete the range of dates in the data are. Since I can do this within my
Kozo report I add in a simple SQL query and then output the results using Moustache template syntax.

{{#years}}
{{LogYear}} {{/years}}

```SQL {"name": "yearcounts"}
SELECT LogYear, count(*) AS Total  
FROM Climate.TemperatureByCity
WHERE $EXTRACT(LogYear,4) = '0'
GROUP BY LogYear
ORDER BY LogYear desc
```

Now lets see how many temperature readings I have per year. I only need to look at the first year of each
decade so I narrow the SQL query down to unclude just these.

## Temperature Counts By Year

```HTML
<table class="compact">
    <tr>
        <th>Log Year</th>
        <th>Total</th>
    </tr>
    {{#yearcounts}}
    <tr>
        <td>{{LogYear}}</td>
        <td>{{Total}}</td>
    </tr>
    {{/yearcounts}} 
</table>
```


It looks as if there is a consistant 42,000 temperature readings per year for the past 170 years.
The number of readings then starts to tail off from the mid 1800's to the first records that started
in the mid 1700's.

At this point I have a couple of observations. The Berkley data file I am using is already three years
out of date. It was currated I think in 2019 and the data it includes only goes up until 2013, which
is a good ten years behind current readings.

```

### Time for some graphs

To begin with I think I want to just explore plain old temperature line graphs over time. Although I
realise I potentially have 270 years x 12 months of data per city, thats 3240 data points which is going 
to look really compressed and spikey considering temperatures by month will jump around. 
This needs some thinking about.

After considering this for a while, I want to start by getting a feel for the upper and lower temperature
boundaries sliced by month. I'm going to select London to start with.

```
## London Min and Max Temperatures in 18th Century
```

```SQL {"name":"LondonMinMax18"}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = 'London' and LogYear<1800
GROUP BY LogMonth 
```

```JavaScript
data.LondonMin18 = [];
data.LondonMax18 = [];
data.LondonAvr18 = [];
data.LondonMinMax18.map( mm => {
    data.LondonMin18.push(mm.MinAverage);
    data.LondonMax18.push(mm.MaxAverage);
    data.LondonAvr18.push(mm.AvrAvr);    
})
```

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: 'London Min',
            data: data.LondonMin18,
            fill: false,
            borderColor: 'hsl(200, 90%, 40%)',
            tension: 0.3
        },{
            label: 'London Avr',
            data: data.LondonAvr18,
            fill: false,
            borderColor: 'hsl(200, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London Max',
            data: data.LondonMax18,
            fill: false,
            borderColor: 'hsl(200, 90%, 60%)',
            tension: 0.3
        }]
    }
}
```

```
## London Min, Max & Avr Temperatures in 19th Century
```

```SQL {"name":"LondonMinMax19"}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = 'London' and LogYear>1799 and LogYear<1900
GROUP BY LogMonth
```

```JavaScript
data.LondonMin19 = [];
data.LondonMax19 = [];
data.LondonAvr19 = [];
data.LondonMinMax19.map( mm => {
    data.LondonMin19.push(mm.MinAverage);
    data.LondonMax19.push(mm.MaxAverage);
    data.LondonAvr19.push(mm.AvrAvr);    
})
```

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: 'London Min',
            data: data.LondonMin19,
            fill: false,
            borderColor: 'hsl(250, 90%, 40%)',
            tension: 0.3
        },{
            label: 'London Avr',
            data: data.LondonAvr19,
            fill: false,
            borderColor: 'hsl(250, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London Max',
            data: data.LondonMax19,
            fill: false,
            borderColor: 'hsl(250, 90%, 60%)',
            tension: 0.3
        }]
    }
}
```

## London Min, Max & Avr Temperatures in 20th Century

```SQL {"name":"LondonMinMax20"}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = 'London' and LogYear>1899 and LogYear<2000
GROUP BY LogMonth
```

```JavaScript
data.LondonMin20 = [];
data.LondonMax20 = [];
data.LondonAvr20 = [];
data.LondonMinMax20.map( mm => {
    data.LondonMin20.push(mm.MinAverage);
    data.LondonMax20.push(mm.MaxAverage);
    data.LondonAvr20.push(mm.AvrAvr);    
})
```

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: 'London Min',
            data: data.LondonMin20,
            fill: false,
            borderColor: 'hsl(300, 90%, 40%)',
            tension: 0.3
        },{
            label: 'London Avr',
            data: data.LondonAvr20,
            fill: false,
            borderColor: 'hsl(300, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London Max',
            data: data.LondonMax20,
            fill: false,
            borderColor: 'hsl(300, 90%, 60%)',
            tension: 0.3
        }]
    }
}
```

## London Min, Max & Avr Temperatures in 21st Century

```SQL {"name":"LondonMinMax21"}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = 'London' and LogYear>1999 and LogYear<2100
GROUP BY LogMonth
```

```JavaScript
data.LondonMin21 = [];
data.LondonMax21 = [];
data.LondonAvr21 = [];
data.LondonMinMax21.map( mm => {
    data.LondonMin21.push(mm.MinAverage);
    data.LondonMax21.push(mm.MaxAverage);
    data.LondonAvr21.push(mm.AvrAvr);    
})
```

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: 'London Min',
            data: data.LondonMin21,
            fill: false,
            borderColor: 'hsl(350, 90%, 40%)',
            tension: 0.3
        },{
            label: 'London Avr',
            data: data.LondonAvr21,
            fill: false,
            borderColor: 'hsl(350, 90%, 40%)',
            tension: 0.3
        },{
            label: 'London Max',
            data: data.LondonMax21,
            fill: false,
            borderColor: 'hsl(350, 90%, 60%)',
            tension: 0.3
        }]
    }
}
```

## London Min, Max & Avr Temperatures 19th, 20th & 21st Century

I decided to overlay the decades to see how they compare. It was getting a little noisy so I just included the last three.

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: 'London 21st Min',
            data: data.LondonMin21,
            fill: false,
            borderColor: 'hsl(350, 90%, 40%)',
            tension: 0.3
        },{
            label: 'London 21st Avr',
            data: data.LondonAvr21,
            fill: false,
            borderColor: 'hsl(350, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London 21st Max',
            data: data.LondonMax21,
            fill: false,
            borderColor: 'hsl(350, 90%, 60%)',
            tension: 0.3
        },{
            label: 'London 19th Min',
            data: data.LondonMin19,
            fill: false,
            borderColor: 'hsl(120, 90%, 40%)',
            tension: 0.3
        },{
            label: 'London 19th Avr',
            data: data.LondonAvr19,
            fill: false,
            borderColor: 'hsl(120, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London 19th Max',
            data: data.LondonMax19,
            fill: false,
            borderColor: 'hsl(120, 90%, 60%)',
            tension: 0.3
        },{
            label: 'London 20th Min',
            data: data.LondonMin20,
            fill: false,
            borderColor: 'hsl(180, 90%, 40%)',
            tension: 0.3
        },{
            label: 'London 20th Max',
            data: data.LondonAvr20,
            fill: false,
            borderColor: 'hsl(180, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London 20th Max',
            data: data.LondonMax20,
            fill: false,
            borderColor: 'hsl(180, 90%, 60%)',
            tension: 0.3
        }]
    }
}
```

## London - Monthly Average Temperatures by Century

It was still a little noisy so I just included the average temperature for each century.

One thing that immediatly stands out is that the 21st century is a step change different to the previous centuries.

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: 'London 18th Avr',
            data: data.LondonAvr18,
            fill: false,
            borderColor: 'hsl(60, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London 19th Avr',
            data: data.LondonAvr19,
            fill: false,
            borderColor: 'hsl(120, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London 20th Max',
            data: data.LondonAvr20,
            fill: false,
            borderColor: 'hsl(180, 90%, 50%)',
            tension: 0.3
        },{
            label: 'London 21st Avr',
            data: data.LondonAvr21,
            fill: false,
            borderColor: 'hsl(350, 90%, 50%)',
            tension: 0.3
        }]
    }
}
```

```SQL {"name":"ChristchurchMinMax18"}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = 'Christchurch' and LogYear>1699 and LogYear<1800
GROUP BY LogMonth 
```

```SQL {"name":"ChristchurchMinMax19"}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = 'Christchurch' and LogYear>1799 and LogYear<1900
GROUP BY LogMonth
```

```SQL {"name":"ChristchurchMinMax20"}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = 'Christchurch' and LogYear>1899 and LogYear<2000
GROUP BY LogMonth
```

```SQL {"name":"ChristchurchMinMax21"}
SELECT City, LogMonth, MIN(Average) As MinAverage, MAX(Average) As MaxAverage, AVG(Average) As AvrAvr
FROM Climate.TemperatureByCity
WHERE City = 'Christchurch' and LogYear>1999 and LogYear<2100
GROUP BY LogMonth
```

```JavaScript
data.ChristchurchMin18 = [];
data.ChristchurchMax18 = [];
data.ChristchurchAvr18 = [];
data.ChristchurchMinMax18.map( mm => {
    data.ChristchurchMin18.push(mm.MinAverage);
    data.ChristchurchMax18.push(mm.MaxAverage);
    data.ChristchurchAvr18.push(mm.AvrAvr);    
})
```

```JavaScript
data.ChristchurchMin19 = [];
data.ChristchurchMax19 = [];
data.ChristchurchAvr19 = [];
data.ChristchurchMinMax19.map( mm => {
    data.ChristchurchMin19.push(mm.MinAverage);
    data.ChristchurchMax19.push(mm.MaxAverage);
    data.ChristchurchAvr19.push(mm.AvrAvr);    
})
```

```JavaScript
data.ChristchurchMin20 = [];
data.ChristchurchMax20 = [];
data.ChristchurchAvr20 = [];
data.ChristchurchMinMax20.map( mm => {
    data.ChristchurchMin20.push(mm.MinAverage);
    data.ChristchurchMax20.push(mm.MaxAverage);
    data.ChristchurchAvr20.push(mm.AvrAvr);    
})
```

```JavaScript
data.ChristchurchMin21 = [];
data.ChristchurchMax21 = [];
data.ChristchurchAvr21 = [];
data.ChristchurchMinMax21.map( mm => {
    data.ChristchurchMin21.push(mm.MinAverage);
    data.ChristchurchMax21.push(mm.MaxAverage);
    data.ChristchurchAvr21.push(mm.AvrAvr);    
})
```

## Christchurch - Monthly Average Temperatures by Century

What happens if I select the otherside of the world, Christchurch is probably a good selection for this.

It's interesting seing the inverse profile to London. The data is lacking 18th century which makes sense. Again, there is
a distinctive step change between the centuries in terms of an increase in temperature.

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: 'Christchurch 19th Avr',
            data: data.ChristchurchAvr19,
            fill: false,
            borderColor: 'hsl(120, 90%, 50%)',
            tension: 0.3
        },{
            label: 'Christchurch 20th Max',
            data: data.ChristchurchAvr20,
            fill: false,
            borderColor: 'hsl(180, 90%, 50%)',
            tension: 0.3
        },{
            label: 'Christchurch 21st Avr',
            data: data.ChristchurchAvr21,
            fill: false,
            borderColor: 'hsl(350, 90%, 50%)',
            tension: 0.3
        }]
    }
}
```

## Christchurch Min, Max & Avr Temperatures centuries

I decided to include the min and max as well. Interestingly the 21st century is higher on average, but the 20th century had 
higher max values. 

```chartjs {"height":400,"width":600}
{
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
        datasets: [{
            label: 'Christchurch 21st Min',
            data: data.ChristchurchMin21,
            fill: false,
            borderColor: 'hsl(350, 90%, 40%)',
            tension: 0.3
        },{
            label: 'Christchurch 21st Avr',
            data: data.ChristchurchAvr21,
            fill: false,
            borderColor: 'hsl(350, 90%, 50%)',
            tension: 0.3
        },{
            label: 'Christchurch 21st Max',
            data: data.ChristchurchMax21,
            fill: false,
            borderColor: 'hsl(350, 90%, 60%)',
            tension: 0.3
        },{
            label: 'Christchurch 19th Min',
            data: data.ChristchurchMin19,
            fill: false,
            borderColor: 'hsl(120, 90%, 40%)',
            tension: 0.3
        },{
            label: 'Christchurch 19th Avr',
            data: data.ChristchurchAvr19,
            fill: false,
            borderColor: 'hsl(120, 90%, 50%)',
            tension: 0.3
        },{
            label: 'Christchurch 19th Max',
            data: data.ChristchurchMax19,
            fill: false,
            borderColor: 'hsl(120, 90%, 60%)',
            tension: 0.3
        },{
            label: 'Christchurch 20th Min',
            data: data.ChristchurchMin20,
            fill: false,
            borderColor: 'hsl(180, 90%, 40%)',
            tension: 0.3
        },{
            label: 'Christchurch 20th Max',
            data: data.ChristchurchAvr20,
            fill: false,
            borderColor: 'hsl(180, 90%, 50%)',
            tension: 0.3
        },{
            label: 'Christchurch 20th Max',
            data: data.ChristchurchMax20,
            fill: false,
            borderColor: 'hsl(180, 90%, 60%)',
            tension: 0.3
        }]
    }
} 
```

<br><br>
It seems like there is a common trend here, but I do want to see more cities first.

In the next part I will make an interactive document that will allow the reader to select country and city from
a drop down list and generate a similar set of graphs.]]></content>
}

}

