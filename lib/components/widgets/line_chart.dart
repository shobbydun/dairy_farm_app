import 'package:dairy_harbor/components/widgets/pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample2 extends StatefulWidget {
  final List<Map<String, dynamic>> fetchedData; // Pass the fetched data here
  final String collectionName;

  const LineChartSample2({
    super.key,
    required this.fetchedData,
    required this.collectionName,
  });

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    const Color.fromARGB(127, 0, 0, 0),
    AppColors.contentColorBlue,
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate data loading process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: isLoading
            ? _buildSkeletonChart() // Show skeleton while loading
            : LineChart(mainData()),
      ),
    );
  }

  Widget _buildSkeletonChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false), // No grid lines
        titlesData: const FlTitlesData(show: false), // No titles
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [const FlSpot(0, 0), const FlSpot(1, 1)], // Simple line as placeholder
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.grey.shade200),
          ),
        ],
      ),
    );
  }

  double _parseCostOrPrice(Map<String, dynamic> data) {
    if (widget.collectionName == 'deworming' ||
        widget.collectionName == 'vaccination' ||
        widget.collectionName == 'pest_control' ||
        widget.collectionName == 'treatments' ||
        widget.collectionName == 'medicine' ||
        widget.collectionName == 'dehorning' ||
        widget.collectionName == 'machinery' ||
        widget.collectionName == 'feeds' ||
        widget.collectionName == 'artificial_insemination') {
      return double.tryParse(data['cost'].toString()) ?? 0.0;
    } else if (widget.collectionName == 'cow_sales') {
      return double.tryParse(data['sale_price'].toString()) ?? 0.0;
    } else if (widget.collectionName == 'milk_production') {
      return double.tryParse(data['quantity'].toString()) ?? 0.0;
    } else if (widget.collectionName == 'milk_sales') {
      double pricePerLitre =
          double.tryParse(data['price_per_litre'].toString()) ?? 0.0;
      double quantity = double.tryParse(data['quantity'].toString()) ?? 0.0;
      return pricePerLitre * quantity;
    }
    return 0.0; // Default value if no cost/price is found
  }

  List<FlSpot> getSpots() {
    return widget.fetchedData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> data = entry.value;
      return FlSpot(index.toDouble(), _parseCostOrPrice(data));
    }).toList();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;
    if (value.toInt() >= 0 && value.toInt() < widget.fetchedData.length) {
      String date = widget.fetchedData[value.toInt()]['date'];
      text = Text(date.substring(0, 3).toUpperCase(), style: style); // First 3 letters of the month
    } else {
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: RotatedBox(
        quarterTurns: 1,
        child: text,
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 10,
    );
    return Text(
      value.toStringAsFixed(2), // Adjusted to show precise values for the left axis
      style: style,
      textAlign: TextAlign.left,
    );
  }

  LineChartData mainData() {
    double minY = widget.fetchedData.isNotEmpty
        ? getSpots().map((spot) => spot.y).reduce((a, b) => a < b ? a : b)
        : 0;
    double maxY = widget.fetchedData.isNotEmpty
        ? getSpots().map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
        : 6;

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${widget.fetchedData[spot.x.toInt()]['date']}\n${spot.y.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true, // To enable interaction on the chart
      ),
      gridData: const FlGridData(
        show: false, // Remove grid lines
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
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (maxY - minY) / 6, // Adjust the left titles interval
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: widget.fetchedData.length.toDouble() - 1,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: getSpots(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true, // Show dots on the intersection points
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}