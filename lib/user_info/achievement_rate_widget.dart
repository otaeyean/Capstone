import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockapp/server/userInfo/profit_goal_server.dart';

class AchievementRateWidget extends StatefulWidget {
  final String userId;

  const AchievementRateWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _AchievementRateWidgetState createState() => _AchievementRateWidgetState();
}

class _AchievementRateWidgetState extends State<AchievementRateWidget> {
  double _profitGoal = 0.0;
  double _achievementRate = 0.0;
  bool isLoadingGoal = false;
  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedProfitGoal();
    _fetchAchievementRate();
  }

  Future<void> _loadSavedProfitGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGoal = prefs.getDouble('profitGoal_${widget.userId}') ?? 0.0;
    setState(() {
      _profitGoal = savedGoal;
    });
  }

  Future<void> _saveProfitGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('profitGoal_${widget.userId}', goal);
  }

  Future<void> _fetchAchievementRate() async {
    final rate = await ProfitGoalService.getAchievementRate(widget.userId);
    if (rate != null) {
      setState(() {
        _achievementRate = rate;
      });
    }
  }

  void _showProfitGoalInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () async {
              final parsed = double.tryParse(_goalController.text);
              if (parsed != null) {
                final success = await ProfitGoalService.updateProfitGoal(widget.userId, parsed);
                if (success) {
                  await _saveProfitGoal(parsed);
                  final newRate = await ProfitGoalService.getAchievementRate(widget.userId);
                  if (newRate != null) {
                    setState(() {
                      _profitGoal = parsed;
                      _achievementRate = newRate;
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('목표 수익률 설정에 실패했습니다.')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: Text("확인", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "달성률 (목표: ${_profitGoal.toStringAsFixed(1)}%)",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showProfitGoalInputDialog(context),
                ),
              ],
            ),

              SizedBox(height: 8),
              SizedBox(
                height: 20,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double fullWidth = constraints.maxWidth;
                    double rate = _achievementRate.clamp(-100, 100);
                    double coloredWidth = (rate.abs() / 100) * fullWidth;

                    return Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          height: 20,
                          width: coloredWidth,
                          decoration: BoxDecoration(
                            color: rate >= 0 ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              Text(
                "${_achievementRate.toStringAsFixed(2)} %",
                style: TextStyle(
                  color: _achievementRate >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
