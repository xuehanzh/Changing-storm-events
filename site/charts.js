function line(color, file, label) {

    var margin = {top: 20, right: 55, bottom: 30, left: 40},
        width  = 1200 - margin.left - margin.right,
        height = 600  - margin.top  - margin.bottom;


    //axis variables
    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .5);
    var y = d3.scale.linear()
        .rangeRound([height+10, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    var line = d3.svg.line()
        .interpolate("cardinal")
        .x(function (d) { return x(d.label) + x.rangeBand() / 2; })
        .y(function (d) { return y(d.value); });


    // var color = d3.scale.ordinal()
    //     .range(["#001c9c","#101b4d","#475003","#9c8305","#d3c47c"]);

    // var color = d3.scale.ordinal()
    //     .range(["#B30000", "#E34A33", "#FC8D59", "#FDBB84", "#FDD49E", "#FEF0D9"]);

    var svg = d3.select("#chart").append("svg")
        .attr("id", "mysvg")
        .attr("width",  width  + margin.left + margin.right)
        .attr("height", height + margin.top  + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    d3.csv(file, function (error, data) {

        console.log("initial line data: ", data);
        if(error) {
            console.log(error);
        }

        var labelVar = "Year";

        var varNames = d3.keys(data[0])
            .filter(function (key) {
                return key !== labelVar;
            });

        color.domain(varNames);

        var seriesData = varNames.map(function (name) {

            return {
                name: name,
                values: data.map(function(d) {
                    return { name: name, label: d[labelVar], value: +d[name]};
                })
            };
        });

        console.log("series data: ", seriesData);

        x.domain(data.map(function(d) {
            return d.Year;
        }));

        y.domain([
            d3.min(seriesData, function(c) {
                return d3.min(c.values, function(d) { return d.value; });
            }),
            d3.max(seriesData, function(c) {
                return d3.max(c.values, function(d) { return d.value;});
            })

        ]);

        var series = svg.selectAll(".series")
            .data(seriesData)
            .enter().append("g")
            .attr("class", "series");

        series.append("path")
            .attr("class", "line")
            .attr("d", function(d) { return line(d.values); })
            .style("stroke", function(d) { return color(d.name); })
            .style("stroke-width", "4px")
            .style("fill", "none");


        //ADDING AXES TO PLOT
        svg.append("g")
            .attr("class", "xaxis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);

        svg.append("g")
            .attr("class", "yaxis")
            .call(yAxis)
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 3)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(label);

        //adding legend
        var legend = svg.selectAll(".legend")
            .data(varNames.slice().reverse())
            .enter().append("g")
            .attr("class", "legend")
            .attr("transform", function (d, i) {
                return "translate(55," + i * 30 + ")";
            });

        legend.append("rect")
            .attr("x", width - 30)
            .attr("width", 30)
            .attr("height", 30)
            .style("fill", color)
            .style("stroke", "grey");

        legend.append("text")
            .attr("x", width - 42)
            .attr("y", 6)
            .attr("dy", ".35em")
            .style("text-anchor", "end")
            .text(function (d) {
                console.log("1");
                return (d); });

    });
}

function stacked(color, file, label) {
    var margin = {top: 20, right: 55, bottom: 30, left: 40},
        width  = 1800 - margin.left - margin.right,
        height = 700  - margin.top  - margin.bottom;


    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1);

    var y = d3.scale.linear()
        .rangeRound([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");


    var stack = d3.layout.stack()
        .offset("zero")
        .values(function (d) {
            return d.values;
        })
        .x(function (d) {
            return x(d.label);
        })
        .y(function (d) {
            return d.value;
        });

    var area = d3.svg.area()
        .interpolate("cardinal")
        .x(function (d) {
            return x(d.label);
        })
        .y0(function (d) {
            return y(d.y0);
        })
        .y1(function (d) {
            return y(d.y0 + d.y);
        });

    var tooltip = d3.select("#chart")
        .append("div")
        .attr("class", "remove")
        .attr("x", 0)
        .style("position", "absolute")
        .style("z-index", "20")
        .style("visibility", "hidden")
        .style("top", height - 150)
        .style("right", "100px");

    // var color = d3.scale.ordinal()
    //     .range(["#B30000", "#E34A33", "#FC8D59", "#FDBB84", "#FDD49E", "#FEF0D9"]);

    var svg = d3.select("#chart").append("svg")
        .attr("id", "mysvg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    d3.csv(file, function (error, data) {

        var labelVar = 'Year';
        var varNames = d3.keys(data[0])
            .filter(function (key) {
                return key !== labelVar;
            });

        color.domain(varNames);

        var seriesArr = [], series = {};
        varNames.forEach(function (name) {
            series[name] = {name: name, values: []};
            seriesArr.push(series[name]);
        });

        data.forEach(function (d) {
            varNames.map(function (name) {
                series[name].values.push({label: d[labelVar], value: +d[name]});
            });
        });

        x.domain(data.map(function (d) {
            return d.Year;
        }));

        stack(seriesArr);

        y.domain([0, d3.max(seriesArr, function (c) {
            return d3.max(c.values, function (d) {
                return d.y0 + d.y;
            });
        })]);

        var selection = svg.selectAll(".series")
            .data(seriesArr)
            .enter().append("g")
            .attr("class", "series");

        selection.append("path")
            .attr("class", "stackPath")
            .attr("d", function (d) {
                return area(d.values);
            })
            .style("fill", function (d) {
                return color(d.name);
            })
            .style("stroke", "grey");

        svg.selectAll(".stackPath")
            .attr("opacity", 1)
            .on("mouseover", function (d, i) {
                svg.selectAll(".stackPath").transition()
                    .duration(250)
                    .attr("opacity", function (d, j) {
                        return j != i ? 0.75 : 1;
                    })
            })
            .on("mousemove", function (i, d) {
                d3.select("this")
                    .classed("hover", true)
                    .attr("stroke-width", 1.5);
                tooltip.html("<p>" + varNames[d]+ "</p>").style("visibility", "visible");

            })
            .on("mouseout", function (i, d) {
                svg.selectAll(".stackPath")
                    .transition()
                    .duration(250)
                    .attr("opacity", 1),

                    tooltip.html("<p>" + d + "<br>" + "tooltip" + "</p>").style("visibility", "hidden");


            });

        //vertical tooltip
        var vertical = d3.select("#chart")
            .append("div")
            .attr("class", "remove")
            .style("position", "absolute")
            .style("z-index", "19")
            .attr("x", 0)
            .style("width", "1px")
            .style("height", height -500)
            .style("top", "50px")
            .style("bottom", "50px")
            .style("left", "5px")
            .style("background", "#fff");

        d3.select("#chart")
            .on("mousemove", function () {
                mousex = d3.mouse(this);
                mousex = mousex[0] + 5;
                vertical.style("left", mousex + "px")
            })
            .on("mouseover", function () {
                mousex = d3.mouse(this);
                mousex = mousex[0] + 5;
                vertical.style("left", mousex + "px")
            });

        //adding legend
        var legend = svg.selectAll(".legend")
            .data(varNames.slice().reverse())
            .enter().append("g")
            .attr("class", "legend")
            .attr("transform", function (d, i) {
                return "translate(55," + i * 30 + ")";
            });

        legend.append("rect")
            .attr("x", width - 30)
            .attr("width", 30)
            .attr("height", 30)
            .style("fill", color)
            .style("stroke", "grey");

        legend.append("text")
            .attr("x", width - 42)
            .attr("y", 6)
            .attr("dy", ".35em")
            .style("text-anchor", "end")
            .text(function (d) {
                console.log("1");
                return (d); });

        //ADDING AXES
        //ADDING AXES TO PLOT
        svg.append("g")
            .attr("class", "xaxis")
            .attr("transform", "translate(0," + height + ")")
            .style("color", "grey")
            .call(xAxis);
        //
        svg.append("g")
            .attr("class", "yaxis")
            .call(yAxis)
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 3)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(label);
    });
}

function stream(color, file, label) {
    var margin = {top: 20, right: 55, bottom: 30, left: 40},
        width  = 1800 - margin.left - margin.right,
        height = 700  - margin.top  - margin.bottom;

    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1);
    var y = d3.scale.linear()
        .rangeRound([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");


    var stack = d3.layout.stack()
        .offset("wiggle")
        .values(function (d) { return d.values; })
        .x(function (d) { return x(d.label) + x.rangeBand() / 2; })
        .y(function (d) { return d.value; });
    var area = d3.svg.area()
        .interpolate("cardinal")
        .x(function (d) { return x(d.label) + x.rangeBand() / 2; })
        .y0(function (d) { return y(d.y0); })
        .y1(function (d) { return y(d.y0 + d.y); });

    var tooltip = d3.select("#chart")
        .append("div")
        .attr("class", "remove")
        .style("position", "absolute")
        .style("z-index", "20")
        .style("visibility", "hidden")
        .style("top", "200px")
        .style("left", "100px")
        .style("font-size", "22px");

    var svg = d3.select("#chart").append("svg")
        .attr("id", "mysvg")
        .attr("width",  width  + margin.left + margin.right)
        .attr("height", height + margin.top  + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    d3.csv(file, function (error, data) {
        console.log("initial data", data);
        var labelVar = 'Year';
        var varNames = d3.keys(data[0])
            .filter(function (key) { return key !== labelVar;});
        color.domain(varNames);
        var seriesArr = [], series = {};
        varNames.forEach(function (name) {
            series[name] = {name: name, values:[]};
            seriesArr.push(series[name]);
        });
        data.forEach(function (d) {
            varNames.map(function (name) {
                series[name].values.push({label: d[labelVar], value: +d[name]});
            });
        });
        x.domain(data.map(function (d) { return d.Year; }));
        stack(seriesArr);
        console.log("stacked seriesArr", seriesArr);
        y.domain([0, d3.max(seriesArr, function (c) {
            return d3.max(c.values, function (d) { return d.y0 + d.y; });
        })]);
        var selection = svg.selectAll(".series")
            .data(seriesArr)
            .enter().append("g")
            .attr("class", "series");
        selection.append("path")
            .attr("class", "streamPath")
            .attr("d", function (d) { return area(d.values); })
            .style("fill", function (d) { return color(d.name); })
            .style("stroke", "grey");

        //adding interactive opacity

        svg.selectAll(".streamPath")
            .attr("opacity", 1)
            .on("mouseover", function(d, i) {
                svg.selectAll(".streamPath").transition()
                    .duration(250)
                    .attr("opacity", function(d,j) {
                        return j!=i ? 0.75 : 1;
                    })
            })
            .on("mousemove", function(i, d) {
                d3.select("this")
                    .classed("hover", true)
                    .attr("stroke-width", 1.5);
                tooltip.html("<p>" + varNames[d] + "</p>").style("visibility", "visible");

            })
            .on("mouseout", function(i, d) {
                svg.selectAll(".streamPath")
                    .transition()
                    .duration(250)
                    .attr("opacity", 1),

                    tooltip.html("<p>" + d + "<br>" +"tooltip" + "</p>").style("visibility", "hidden");


            });

        //vertical tooltip
        var vertical = d3.select("#chart")
            .append("div")
            .attr("class", "remove")
            .style("position", "absolute")
            .style("z-index", "19")
            .attr("x", 300)
            .style("width", "1px")
            .style("height", height - 30)
            .style("top", "300px")
            .style("bottom", "0px")
            .style("left", "5px")
            .style("background", "#fff");

        d3.select("#chart")
            .on("mousemove", function(){
                mousex = d3.mouse(this);
                mousex = mousex[0] + 5;
                vertical.style("left", mousex + "px" )})
            .on("mouseover", function(){
                mousex = d3.mouse(this);
                mousex = mousex[0] + 5;
                vertical.style("left", mousex + "px")})
            .on("mouseout", function(){
                // vertical.style("visibility", "hidden");
                mousex = 0;
                vertical.style("left", mousex + "px");
                console.log("mousing out");
            });

        //adding axes
        //ADDING AXES TO PLOT
        svg.append("g")
            .attr("class", "xaxis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);
        //
        svg.append("g")
            .attr("class", "yaxis")
            .call(yAxis)
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 3)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(label);

        //adding legend
        var legend = svg.selectAll(".legend")
            .data(varNames.slice().reverse())
            .enter().append("g")
            .attr("class", "legend")
            .attr("transform", function (d, i) {
                return "translate(55," + i * 30 + ")";
            });

        legend.append("rect")
            .attr("x", width - 30)
            .attr("width", 30)
            .attr("height", 30)
            .style("fill", color)
            .style("stroke", "grey");

        legend.append("text")
            .attr("x", width - 42)
            .attr("y", 6)
            .attr("dy", ".35em")
            .style("text-anchor", "end")
            .text(function (d) {
                console.log("1");
                return (d); });
    });

}
