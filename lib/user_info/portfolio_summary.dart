import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/server/userInfo/portfolio_server.dart';
import 'package:stockapp/server/userInfo/user_balance_server.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';  // 추가된 부분
import './stock_sort_header.dart';
import '../server/userInfo/profit_goal_server.dart';

class CombinedBalanceSummary extends StatefulWidget {
  final String userId;

  const CombinedBalanceSummary({required this.userId});

  @override
  State<CombinedBalanceSummary> createState() => _CombinedBalanceSummaryState();
}

class _CombinedBalanceSummaryState extends State<CombinedBalanceSummary> {
  double balance = 0;
  String totalPurchase = "0 원";
  String totalEvaluation = "0 원";
  String totalProfit = "0 원";
  String totalProfitRate = "0 %";
  String errorMessage = '';
  Timer? _timer;
  double profitGoal = 0; 
  bool isLoadingGoal = false;
  double? achievementRate = 0; 
  bool isLoadingAchievementRate = false;

  final NumberFormat formatter = NumberFormat('#,###');
  final TextEditingController _controller = TextEditingController();

 @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchProfitGoal();
    _loadSavedProfitGoal();  //목표 수익률 로드
    _startAchievementRateUpdater(); // 달성률 갱신
    _timer = Timer.periodic(Duration(seconds: 10), (_) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 30초마다 달성률을 불러오는 함수 (이거 30초로 고정해놨음 테스트 할 때나 발표할 때는 2-3초로 설정)
  void _startAchievementRateUpdater() {
    Timer.periodic(Duration(seconds: 30), (timer) async {
      double? newRate = await ProfitGoalService.getAchievementRate(widget.userId);
      if (newRate != null) {
        setState(() {
          achievementRate = newRate;
          isLoadingAchievementRate = false;  
        });
      }
    });
  }

  Future<void> _updateProfitGoal(double newGoal) async {
    setState(() {
      isLoadingGoal = true;
    });

    bool success = await ProfitGoalService.updateProfitGoal(widget.userId, newGoal);

    if (success) {
      setState(() {
        profitGoal = newGoal;
      });
      _saveProfitGoal(newGoal);  
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('목표 수익률 설정에 실패했습니다.')),
      );
    }

    setState(() {
      isLoadingGoal = false;
    });
  }

  Future<void> _fetchProfitGoal() async {
    setState(() {
      isLoadingAchievementRate = true;
    });

    achievementRate = await ProfitGoalService.getAchievementRate(widget.userId);

    setState(() {
      isLoadingAchievementRate = false;
    });
  }

  Future<void> _fetchData() async {
    try {
      final data = await PortfolioService.fetchPortfolioData(widget.userId);
      setState(() {
        balance = data['balance'].toDouble();
        totalPurchase = "${_formatInt(data['totalPurchase'])} 원";
        totalEvaluation = "${_formatInt(data['totalEvaluation'])} 원";
        totalProfit = "${_formatInt(data['totalProfit'])} 원";
        totalProfitRate = _formatProfitRate(data['totalProfitRate']);
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = '데이터를 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  String _formatInt(dynamic value) {
    if (value is double) {
      return formatter.format(value.toInt());
    } else if (value is int) {
      return formatter.format(value);
    }
    return "0";
  }

  String _formatProfitRate(dynamic value) {
    if (value is double) {
      return "${value.toStringAsFixed(2)} %";
    } else if (value is int) {
      return "$value %";
    }
    return "0 %";
  }

  void _updateBalance() async {
    double? newBalance = double.tryParse(_controller.text);
    if (newBalance != null) {
      bool success = await UserBalanceService().updateBalance(widget.userId, newBalance);
      if (success) {
        setState(() {
          balance = newBalance;
        });
      }
    }
  }

  void _resetBalance() async {
    bool success = await UserBalanceService().resetBalance(widget.userId);
    if (success) {
      setState(() {
        balance = 0;
      });
    }
  }

  void _showBalanceInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("금액 입력", style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "금액을 입력하세요",
              hintStyle: TextStyle(color: Colors.black45),
            ),
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _updateBalance();
                Navigator.pop(context);
              },
              child: Text("확인", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _confirmResetBalance(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("금액 초기화", style: TextStyle(color: Colors.black)),
          content: Text("설정해놓으신 금액이 초기화됩니다. 진행하시겠습니까?", style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _resetBalance();
                Navigator.pop(context);
              },
              child: Text("확인", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showProfitGoalInputDialog(BuildContext context) {
    final TextEditingController _goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("목표 수익률 입력", style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: _goalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "예) 20.0"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                final parsed = double.tryParse(_goalController.text);
                if (parsed != null) {
                  _updateProfitGoal(parsed);
                }
                Navigator.pop(context);
              },
              child: Text("확인", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // 로컬에 저장된 목표 수익률 저장함
Future<void> _loadSavedProfitGoal() async {
  final prefs = await SharedPreferences.getInstance();
  final savedGoal = prefs.getDouble('profitGoal_${widget.userId}') ?? 0;
  setState(() {
    profitGoal = savedGoal;
  });
}
  // 로컬에서 목표 수익률 가져옴
Future<void> _saveProfitGoal(double goal) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setDouble('profitGoal_${widget.userId}', goal);
}
@override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF001F3F), Color(0xFF003366)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0, 6),
          blurRadius: 12,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("보유 금액", style: TextStyle(color: Colors.white70, fontSize: 16)),
                SizedBox(height: 6),
                Text("${formatter.format(balance)} 원", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                _iconButton(FontAwesomeIcons.gear, "금액설정", Color(0xFF64C38C), () => _showBalanceInputDialog(context), true),
                SizedBox(width: 10),
                _iconButton(FontAwesomeIcons.arrowRotateLeft, "초기화", Colors.redAccent, () => _confirmResetBalance(context)),
              ],
            )
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoColumn(FontAwesomeIcons.cartShopping, "총매입", totalPurchase),
            _buildInfoColumn(FontAwesomeIcons.chartLine, "총평가", totalEvaluation),
            _buildInfoColumn(FontAwesomeIcons.coins, "총손익", totalProfit),
            _buildInfoColumn(FontAwesomeIcons.percent, "수익률", totalProfitRate),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text("📈 사용자가 설정한 목표 수익률: ",
                    style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 16)),
                Text(
                  profitGoal == 0 ? "0.00 %" : "${profitGoal.toStringAsFixed(2)} %",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            isLoadingGoal
                ? CircularProgressIndicator()
                : IconButton(
                    onPressed: () => _showProfitGoalInputDialog(context),
                    icon: Icon(
                      FontAwesomeIcons.penToSquare,
                      color: Colors.white,
                    ),
                  ),
          ],
        ),
        SizedBox(height: 10),
        achievementRate != null
            ? Row(
                children: [
                  Text("🎯 달성률: ", style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 255, 255, 255))),
                  SizedBox(width: 12),
                  Container(
                    width: 550,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (achievementRate! < 0)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: (achievementRate!.abs().clamp(0, 100)) / 200,
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (achievementRate! > 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: (achievementRate!.clamp(0, 100)) / 200,
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "${achievementRate!.toStringAsFixed(2)} %",
                    style: TextStyle(
                      color: achievementRate! < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    ),
  );
}

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(icon, color: Colors.white, size: 20),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        )
      ],
    );
  }

  Widget _iconButton(IconData icon, String label, Color color, VoidCallback onTap, [bool greenStyle = false]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: greenStyle ? Color(0xFF64C38C).withOpacity(0.15) : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: greenStyle ? Border.all(color: Color(0xFF64C38C).withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            FaIcon(icon, color: color, size: 14),
            SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}