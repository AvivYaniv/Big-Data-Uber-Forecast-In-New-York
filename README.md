# Big-Data-Uber-Forecast-In-New-York

In this project, I've recieved a dataset of 4.5 million [Uber](https://en.wikipedia.org/wiki/Uber) rides orders in [New-York City](https://en.wikipedia.org/wiki/New_York_City), which connects drivers and those who are interested in a ride. <br/>
The dataset contained observations from monthes April-July 2014, and included locations and time of order. <br/>
Based on the dataset, I've been asked to predict the number of orders in a future month, September 2014, on each 15-minutes interval. <br/>
<br/>
First, I've researched the data to find patterns and connections, then based on the research insightes Iv'e cross-checked additional data. <br/>
Finally, Iv'e built a model that predicts the future trends for rides. <br/>
In the following chepters, I shall describe the research steps, the insights and the model I've choose to implement. <br/>
This documents contains images that describe the milestones in my research work, most of them contain links to higher-resolution. <br/>
<br/>
<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/Heatmap/DemandByDay.gif?raw=true" width="80%"/>
<p/>

## Data Research
First, Iv'e cleaned the data, based on project specifications; narrowed the rides in 1 kilometer radius from [New York Stock Exchange](https://en.wikipedia.org/wiki/New_York_Stock_Exchange), and during 17 PM till midnight, and made sure there are no missing data cells. <br/>
Then, orders have been divied into 15-minutes time slots windows. <br/>
Iv'e created the following [graph that describes the nubmer of times, in a 15-minutes time slots windows, there have been a given number of orders](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/PicknumDistribution/graph_distribution.png). <br/>
(i.e. The number of times there have been 20 orders [x-axis], in the 15-minutes time slots windows is on [y-axis]). <br/>

<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/PicknumDistribution/graph_distribution.png?raw=true" width="50%"/>
<p/>

As you witness, this distribution peak is close to it's mean and afterwards drops drastically. <br/>
Distribution tail's composed mostly of [anomality](https://en.wikipedia.org/wiki/Anomaly_(natural_sciences)) time slots windows, in which there have been a soaring demand for rides. <br/>
This [patterns remaines consistent among the other monthes as well](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/tree/master/Data%20Exploration/PicknumDistribution). <br/>
This phenomena, in which there has been an extraordinary amount of orders triggered my curiosity - so Iv'e orgenized in the following table [which decribes major events and weather conditions](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/Peak%20Pick%20Nums%20Versus%20Events%20and%20Climate/Peak%20Pick%20Nums%20Versus%20Events%20and%20Climate.xlsx). <br/>
The table is ordered in decending number of rides, and proposed to discover if there is a correlations between major events and rainy weather and the number of pick up numbers. <br/>
As you witness, in 52% of the time slot windows with above 40 rides and in 48% of the time slot windows with between 30-40 rides there indeed has been cold weather of major event - that may describe the soaring demand for rides. <br/>
Although this can explain some of the anomaly in time slot windows, this reasons (such as future weather or major events) cannot be predicted, and special attention has been taken to handle them when devising the model. <br/>
<br/>
Data research has been continued in creating ["heat-map" that describe the number of orders in every round hour in each day of the week](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/PeakNumHoursInDay/color_distribution.png). <br/>

<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/PeakNumHoursInDay/color_distribution.png?raw=true" width="50%"/>
<p/>

As you witness, there is a rised in demand during 17 PM - 19 PM during workdays (probably explained by commuting from work), as well as a drop in demand during late night hours of workdays. <br/>
This [patterns remaines consistent among the other monthes as well](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/tree/master/Data%20Exploration/PeakNumHoursInDay). <br/>
<br/>
Besides, the trend of [total amount of orders in diffrent monthes](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/UberGrowth/Pick%20num%20%20per%20month%20is%20rising%20through%202014.png), demonstrates [Uber growth](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/tree/master/Data%20Exploration/UberGrowth) in monthes April-July with slight incline during June. <br/>

<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/UberGrowth/Pick%20num%20%20per%20month%20is%20rising%20through%202014.png?raw=true" width="50%"/>
<p/>

In addition, Iv'e researcehd the demand-areas and their patterns. <br/>
The following [heatmap describes the areas with the highest orders counts with warmer colors](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/Heatmap/heatmap.png), during diffrent days of the week. <br/>

<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/Heatmap/DemandByDay.gif?raw=true" width="80%"/>
<p/>

As you witness, demand changes during diffrent days of the week and most significaly between workdays and the weekend. <br/>

However, the "warmer" areas remain stationary between diffrent monthes and demonstrate lower entropy in comparision ot the daily heatmaps. <br/>

<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/Heatmap/DemandByMonth.gif?raw=true" width="80%"/>
<p/>

These warm areas are correlated with [attraction points](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/tree/master/Data%20Exploration/Attractions) and [interest point mentioned in Manhatten](https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/Attractions/quora.com-As%20a%20tourist%20what%20is%20the%20best%20area%20of%20New%20York%20to%20stay%20in.pdf). <br/>
Another interesting observation is, that the warm ares are not close to train-stations, who pass during those hours very frequently. <br/>
It is reasonable to belive, that trains are a [substitute goods](https://en.wikipedia.org/wiki/Substitute_good) for Uber rides in some cases. <br/>

Lastly, a correlation matrix has been created. <br/>

<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Data%20Exploration/Correlation/CorrelationMatrix.png?raw=true" width="50%"/>
<p/>

## Building the Model
The developed model is a [clustering](https://en.wikipedia.org/wiki/Cluster_analysis) model. <br/>
Each order has been assigned to a cluster, and cluster centers were in the centers of the warmest areas. <br/>
Such division is ment to learn patterns on each area independently, as diffrent areas get warm on diffrent days and hours - yet the clusters centers AKA [centroids](https://en.wikipedia.org/wiki/Centroid) are almost stationary. <br/>
To choose the right amount of clusters, Iv'e created a [Total Within Cluster Sum of Squares graph](https://en.wikipedia.org/wiki/Total_sum_of_squares). <br/>
This graph is used to determine a reasonable amount of clusters (denoted by K), using the ["elbow method"](https://en.wikipedia.org/wiki/Elbow_method_(clustering)) heuristic; the cutoff point where diminishing returns are no longer worth the additional cost (stop adding new clusters, or raising K, when the amount of explained data is incosiderable). <br/>

<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Model/Clusteres/Total%20Within%20Cluster%20Sum%20of%20Squares.png?raw=true" width="80%"/>
<p/>

The chosen amount of clusters (configurable in code) is K=8, whose centroids matched the warmer areas mentioned above. <br/>

To build the model, after dividing orders into clusters, a designated table of tables has been build using the [dplyr library](https://dplyr.tidyverse.org/) developed by [Hadley Wickham](http://hadley.nz/) for the clusters. <br/>
Each row in the main table, matches a data for a cluster and a [linear regression](https://en.wikipedia.org/wiki/Linear_regression) has been applied to it. <br/>
In this way, model is trained to learn patterns for each cluster independently, and [regression](https://en.wikipedia.org/wiki/Linear_regression) would yield diffrent coefficients for each cluster based on unique characteristics of each cluster. <br/>
The desired prediction, for the future 15-minutes time slot windows are the total sum of prediction of all clusters. <br/>

<p align="center">
    <img src="https://github.com/AvivYaniv/Big-Data-Uber-Forecast-In-New-York/blob/master/Solution%20Design/ClusterTableDesignDiagram/ClusterTableDesignDiagram.png?raw=true"/>
<p/>

[Linear regression](https://en.wikipedia.org/wiki/Linear_regression) model is: <br/>
&emsp;&emsp;&emsp; `pick_num ~ minute + hour + day_in_week + hour*day_in_week `<br/>


The interaction between hour and day_in_week has been addded to grasp the effects of diffrent combination of them. <br/>

In addition, as described above, in every month there are anomaly time slot windows with extraordinary amount of orders; <br/>
to tackle this issue - and cancel the mal side effects of weather or unpredictable events - a threshold on orders amount has been introduced of threshol=9 for each cluster, which is configurable by code. <br/>
Cutting by treshold in a cluster based manner, is beneficial to disable anomality in one cluster without side effects on the other and more agile in comparision to setting a global threshold. <br/>

## Summary and other models
To sum up, Iv'e started with data research and recognizing patterns in diffrent days and hours, and continued in researching patterns in diffrent monthes and warm areas. <br/>
Iv'e found out that between diffrent monthes, the warm areas remain almost stationary. <br/>
However, in diffrent days of the week and especially when comparing workdays and weekend the warm areas shifted. <br/>
Then, anomaly in time slot windows has been researched, in which orders amount soared. <br/>
Correlation between cold-weather, major evets and those anomalies has been proved. <br/>
Armed with those insightes, Iv'e developed a cluster model that matched the warm areas, and learned those patterns for each of the clusteed independently. <br/>
In addition to the developed model, simple linear models (although it is clear they cannot grasp the whole picture), as well as [random forest](https://en.wikipedia.org/wiki/Random_forest) models have been tried (and combinations with the cluster model) - yet none of those exceeded the [R^2](https://en.wikipedia.org/wiki/Coefficient_of_determination) achived by the model described above. <br/>
Finally, a model that divides the city into interest areas, and learned for each of them unique coefficients, and minimizes the bad effect of anomalies has been presented. <br/>

E. \0. F.
