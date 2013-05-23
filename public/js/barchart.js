$(function () {
    var categories = graphdata[0];
    var series = new Array();
    for(var i=0; i< graphdata.length; i++){
        if(i == 0)continue;
        if(groupname == false) name = "Group "+i; 
        else name = groupname[i-1];
        series.push({
            name: name,
            data: graphdata[i]
        });
    }

    $('#container').highcharts({
        chart: {
            type: type
        },
        title: {
            text: title
        },
        subtitle: {
            text: sourcetext
        },
        xAxis: {
            categories: categories,
            title: {
                text: null
            }
        },
        yAxis: {
            min: 0,
            title: {
                text: ytext,
                align: 'high'
            },
            labels: {
                overflow: 'justify'
            }
        },
        tooltip: {
            valueSuffix: ''
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true
                }
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'top',
            x: -100,
            y: 100,
            floating: true,
            borderWidth: 1,
            backgroundColor: '#FFFFFF',
            shadow: true
        },
        credits: {
            enabled: false
        },
        series: series
    });
});
