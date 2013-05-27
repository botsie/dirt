$(function () {
    for(var i=0; i<appdata['barchart'].length; i++){
        var categories = appdata['barchart'][i].graphdata[0];
        var series = new Array();
        for(var j=0; j< appdata['barchart'][i].graphdata.length; j++){
            if(j == 0)continue;
            if(appdata['barchart'][i].groupname == false) name = "Group "+j; 
            else name = appdata['barchart'][i].groupname[j-1];
            series.push({
                name: name,
                data: appdata['barchart'][i].graphdata[j]
            });
        }
        $('#'+appdata['barchart'][i].id).highcharts({
            chart: {
                type: appdata['barchart'][i].type
            },
            title: {
                text: appdata['barchart'][i].title
            },
            subtitle: {
                text: appdata['barchart'][i].sourcetext
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
                    text: appdata['barchart'][i].ytext,
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
    }
});
