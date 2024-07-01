import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BarChartGroupData> _barChartData = [];
  List<PieChartSectionData> _pieChartData = [];
  List<LineChartBarData> _lineChartData = [];
  List<double> summary = [];
  List<Map<String, dynamic>> yearlySummary = [];
  List<Map<String, dynamic>> monthlySummary = [];
  int? touchedIndex;
  int _selectedChartType = 0;

  // Función para obtener datos desde la API para el gráfico de barras
  Future<void> fetchSummary() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/weekly_summary/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        summary = List<double>.from(data['summary']);
        _updateBarChartData();
      });
    } else {
      throw Exception('Failed to load summary');
    }
  }

  // Función para obtener datos desde la API para el gráfico de torta
  Future<void> fetchyearlySummary() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/yearly_summary/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['yearly_summary'];
      setState(() {
        yearlySummary = List<Map<String, dynamic>>.from(data);
        _updatePieChartData();
      });
    } else {
      throw Exception('Failed to load yearly summary');
    }
  }

  Future<void> fetchMonthlySummary() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/monthly_summary/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['monthly_summary'];
      setState(() {
        monthlySummary = List<Map<String, dynamic>>.from(data);
        _updateLineChartData();
      });
    } else {
      throw Exception('Failed to load monthly summary');
    }
  }

  Future<void> fetchWeeklySummaryPrice() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/weekly_summary_price/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        summary = List<double>.from(data['summary_price']);
        _updateBarChartData();
      });
    } else {
      throw Exception('Failed to load weekly summary price');
    }
  }

  Future<void> fetchMonthlySummaryPrice() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/monthly_summary_price/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['monthly_summary_price'];
      setState(() {
        monthlySummary = List<Map<String, dynamic>>.from(data);
        _updateLineChartData();
      });
    } else {
      throw Exception('Failed to load monthly summary price');
    }
  }

  Future<void> fetchYearlySummaryPrice() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/yearly_summary_price/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['yearly_summary_price'];
      setState(() {
        yearlySummary = List<Map<String, dynamic>>.from(data);
        _updatePieChartData();
      });
    } else {
      throw Exception('Failed to load yearly summary price');
    }
  }

  void _generateData() {
    _updateBarChartData();
    _updatePieChartData();
    _updateLineChartData();
  }

  void _updateBarChartData() {
    _barChartData = List.generate(
      7,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: summary.isNotEmpty ? summary[index] : 0,
            color: Colors.blue,
            width: 15,
          ),
        ],
      ),
    );
  }

  void _updatePieChartData() {
    _pieChartData = yearlySummary.map((data) {
      final month = data['month'];
      final totalAmount = data['total_amount'] ?? 0.0;
      return PieChartSectionData(
        value: totalAmount,
        title: '$totalAmount',
        color: _getColorForIndex(month - 1),
        radius: touchedIndex == month - 1 ? 60 : 50,
        badgeWidget: touchedIndex == month - 1
            ? Badge(
                label: '$totalAmount',
              )
            : null,
      );
    }).toList();
  }

  void _updateLineChartData() {
    print('Updating line chart data');
    List<FlSpot> month1Data = [];
    List<FlSpot> month2Data = [];
    List<FlSpot> month3Data = [];

    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int previousMonth = (currentMonth - 1) > 0 ? (currentMonth - 1) : 12;
    int twoMonthsAgo = (currentMonth - 2) > 0 ? (currentMonth - 2) : 12;

    for (var entry in monthlySummary) {
      final month = entry['month'];
      final day = entry['day'];
      final totalAmount = entry['total_amount'] != null ? entry['total_amount'].toDouble() : 0.0;

      if (month == currentMonth) {
        month1Data.add(FlSpot(day.toDouble(), totalAmount));
      } else if (month == previousMonth) {
        month2Data.add(FlSpot(day.toDouble(), totalAmount));
      } else if (month == twoMonthsAgo) {
        month3Data.add(FlSpot(day.toDouble(), totalAmount));
      }
    }

    print('Month 1 data: $month1Data');
    print('Month 2 data: $month2Data');
    print('Month 3 data: $month3Data');

    setState(() {
      _lineChartData = [
        LineChartBarData(
          spots: month1Data,
          isCurved: true,
          color: Colors.red,
          barWidth: 4,
          belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.3)),
        ),
        LineChartBarData(
          spots: month2Data,
          isCurved: true,
          color: Colors.blue,
          barWidth: 4,
          belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
        ),
        LineChartBarData(
          spots: month3Data,
          isCurved: true,
          color: Colors.green,
          barWidth: 4,
          belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.3)),
        ),
      ];
    });
  }



  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xff3366cc),
      Color(0xff990099),
      Color(0xff109618),
      Color(0xfffdbe19),
      Color(0xffff9900),
      Color(0xffdc3912),
      Color(0xff990099),
      Color(0xff0099c6),
      Color(0xffdd4477),
      Color(0xff66aa00),
      Color(0xffb82e2e),
      Color(0xff316395),
    ];
    return colors[index % colors.length];
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('L', style: style);
        break;
      case 1:
        text = const Text('M', style: style);
        break;
      case 2:
        text = const Text('M', style: style);
        break;
      case 3:
        text = const Text('J', style: style);
        break;
      case 4:
        text = const Text('V', style: style);
        break;
      case 5:
        text = const Text('S', style: style);
        break;
      case 6:
        text = const Text('D', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }

  String getLeyendTitles(double value) {
    String text;
    switch (value.toInt()) {
      case 1:
        text = 'Enero';
        break;
      case 2:
        text = 'Febrero';
        break;
      case 3:
        text = 'Marzo';
        break;
      case 4:
        text = 'Abril';
        break;
      case 5:
        text = 'Mayo';
        break;
      case 6:
        text = 'Junio';
        break;
      case 7:
        text = 'Julio';
        break;
      case 8:
        text = 'Agosto';
        break;
      case 9:
        text = 'Septiembre';
        break;
      case 10:
        text = 'Octubre';
        break;
      case 11:
        text = 'Noviembre';
        break;
      case 12:
        text = 'Diciembre';
        break;
      default:
        text = '';
        break;
    }
    return text;
  }

  @override
  void initState() {
    super.initState();
    _generateData();
    if (_selectedChartType == 1) {
      fetchWeeklySummaryPrice();
      fetchMonthlySummaryPrice();
      fetchYearlySummaryPrice();
    } else {
      fetchSummary();
      fetchMonthlySummary();
      fetchyearlySummary();
    }
  }


  void _onChartTypeChanged(int? value) {
    setState(() {
      _selectedChartType = value!;
    });

    if (value == 1) { // Price
      fetchWeeklySummaryPrice();
      fetchMonthlySummaryPrice();
      fetchYearlySummaryPrice();
    } else { // Quantity
      fetchSummary();
      fetchMonthlySummary();
      fetchyearlySummary();
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff1976d2),
            bottom: TabBar(
              indicatorColor: Color(0xff9962D0),
              tabs: [
                Tab(
                  icon: Icon(Icons.bar_chart),
                ),
                Tab(icon: Icon(Icons.pie_chart)),
                Tab(icon: Icon(Icons.line_style)),
              ],
            ),
            title: Text('Flutter Charts'),
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: 0,
                    groupValue: _selectedChartType,
                    onChanged: _onChartTypeChanged,
                  ),
                  Text('KG'),
                  Radio(
                    value: 1,
                    groupValue: _selectedChartType,
                    onChanged: _onChartTypeChanged,
                  ),
                  Text('\$'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'SO₂ emissions, by world region (in million tonnes)',
                              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  minY: 0,
                                  barGroups: _barChartData,
                                  titlesData: FlTitlesData(
                                    show: true,
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: getBottomTitles,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false), // Ocultar el grid
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Sales by Month',
                              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20.0),
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: PieChart(
                                      PieChartData(
                                        sections: _pieChartData,
                                        sectionsSpace: 0,
                                        centerSpaceRadius: 50,
                                        pieTouchData: PieTouchData(
                                          touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                                            setState(() {
                                              if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                                touchedIndex = -1;
                                                return;
                                              }
                                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                              _updatePieChartData();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        for (int i = 0; i < yearlySummary.length; i++)
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getColorForIndex(yearlySummary[i]['month'] - 1), // Usar el mismo método para obtener el color
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  margin: EdgeInsets.only(right: 6),
                                                  color: _getColorForIndex(yearlySummary[i]['month'] - 1), // Usar el mismo método para obtener el color
                                                ),
                                                Text(
                                                  getLeyendTitles(yearlySummary[i]['month']),
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Sales for the first 5 years',
                              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  lineBarsData: _lineChartData,
                                  titlesData: FlTitlesData(
                                    show: true,
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          const style = TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          );
                                          Widget text;
                                          if (value.toInt() % 5 == 0) {
                                            text = Text(value.toInt().toString(), style: style);
                                          } else {
                                            text = Text('', style: style);
                                          }
                                          return SideTitleWidget(child: text, axisSide: meta.axisSide);
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                  minX: 0,
                                  maxX: 30,
                                  minY: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Sales {
  int yearval;
  int salesval;

  Sales(this.yearval, this.salesval);
}

class Badge extends StatelessWidget {
  final String label;
  const Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
