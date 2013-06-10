$(function () {
    for(var i=0; i<appdata['linechart'].length; i++){
        var series = new Array();
        for(var j=0; j<appdata['linechart'][i].graphdata.length ;j++){
            series.push({
                name : (appdata['linechart'][i].graphlables[j] || ""),
                data: appdata['linechart'][i].graphdata[j]
            })
        }
        $('#'+appdata['linechart'][i].id).highcharts({
            chart: {
                type: 'spline'
            },
            title: {
                text: appdata['linechart'][i].title
            },
            xAxis: {
                labels: {
                    formatter: function() {
                        return this.value;
                    }
                }
            },
            yAxis: {
                title: {
                    text: appdata['linechart'][i].ytext
                },
                min: 0
            },
            tooltip: {
                formatter: function() {
                        return '<b>'+ this.series.name +'</b><br/>'+ this.x + ': '+ this.y;
                }
            },
            credits: {
                enabled: false
            },
            series: series
        });

    }
});
    
