$(function () {
    var series = new Array();
    for(var i=0; i<graphdata.length ;i++){
        series.push({
            name : (graphlables[i] || ""),
            data: graphdata[i]
        })
    }
    console.log(graphdata);
    console.log(series);
    $('#container').highcharts({
        chart: {
            type: 'spline'
        },
        title: {
            text: title
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
                text: ytext
            },
            min: 0
        },
        tooltip: {
            formatter: function() {
                    return '<b>'+ this.series.name +'</b><br/>'+ this.x + ': '+ this.y;
            }
        },
        
        series: series
    });
});
    
