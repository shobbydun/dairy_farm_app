import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample2 extends StatefulWidget {
  BarChartSample2({
    super.key,
  });

  final Color leftBarColor = const Color(0xff6b8e23); // color for left bars
  final Color rightBarColor = const Color(0xffd2691e); // color for right bars
  final Color avgColor = const Color(0xffffa500);

  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBarGroups(); // Load dummy data
    // Simulate data loading process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _loadBarGroups() {
    List<Map<String, dynamic>> dummyData = [
      {'label': 'Item 1', 'price': 200, 'quantity': 50},
      {'label': 'Item 2', 'price': 150, 'quantity': 60},
      {'label': 'Item 3', 'price': 300, 'quantity': 30},
      {'label': 'Item 4', 'price': 100, 'quantity': 80},
      {'label': 'Item 5', 'price': 250, 'quantity': 40},
      {'label': 'Item 6', 'price': 350, 'quantity': 20},
      {'label': 'Item 7', 'price': 200, 'quantity': 34},
    ];

    List<BarChartGroupData> items = [];
    
    for (var i = 0; i < dummyData.length; i++) {
      final salesData = dummyData[i];
      final price = salesData['price'] ?? 0.0; 
      final quantity = salesData['quantity'] ?? 0.0; 

      items.add(makeGroupData(i, price.toDouble(), quantity.toDouble()));
    }

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? _buildSkeletonChart() // Show skeleton while loading
            : BarChart(
                BarChartData(
                  maxY: _getMaxY(), // Dynamically calculate max Y
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, response) {
                      if (response == null || response.spot == null) {
                        setState(() {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                        });
                        return;
                      }

                      touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                      setState(() {
                        if (!event.isInterestedForInteractions) {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                          return;
                        }
                        showingBarGroups = List.of(rawBarGroups);
                        if (touchedGroupIndex != -1) {
                          var sum = 0.0;
                          for (final rod
                              in showingBarGroups[touchedGroupIndex].barRods) {
                            sum += rod.toY;
                          }
                          final avg = sum / showingBarGroups[touchedGroupIndex].barRods.length;

                          showingBarGroups[touchedGroupIndex] =
                              showingBarGroups[touchedGroupIndex].copyWith(
                            barRods: showingBarGroups[touchedGroupIndex]
                                .barRods
                                .map((rod) {
                              return rod.copyWith(
                                  toY: avg, color: widget.avgColor);
                            }).toList(),
                          );
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: _getLeftTitleInterval(),
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingBarGroups,
                  gridData: const FlGridData(show: false),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeletonChart() {
    return BarChart(
      BarChartData(
        barGroups: List.generate(
          6,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: 0,
                color: Colors.grey.shade300,
                width: width,
              ),
              BarChartRodData(
                toY: 0,
                color: Colors.grey.shade300,
                width: width,
              ),
            ],
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        maxY: 100,
      ),
    );
  }

  double _getMaxY() {
    return showingBarGroups
            .expand((group) => group.barRods)
            .map((rod) => rod.toY)
            .reduce((a, b) => a > b ? a : b);
  }

  double _getLeftTitleInterval() {
    final maxY = _getMaxY();
    return maxY > 0 ? (maxY / 6) : 1;
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(value.toStringAsFixed(0), style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value.toInt() < rawBarGroups.length) {
      // Replace with the actual label from dummyData
      text = 'Item ${value.toInt() + 1}';
    } else {
      text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, // margin top
      child: Text(text, style: style),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: widget.rightBarColor,
          width: width,
        ),
      ],
    );
  }
}