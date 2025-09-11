import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:podpal/providers/pod_data_provider.dart';
import 'package:podpal/widgets/home_status_card.dart';
import 'package:podpal/widgets/level_indicator_widget.dart';
import 'package:podpal/widgets/pod_cover_status.dart';
import 'package:provider/provider.dart';
import 'package:podpal/widgets/animated_plant.dart';

class PodPalHomeScreen extends StatefulWidget {
  const PodPalHomeScreen({Key? key}) : super(key: key);

  @override
  _PodPalHomeScreenState createState() => _PodPalHomeScreenState();
}

class _PodPalHomeScreenState extends State<PodPalHomeScreen> {
  Timer? _uiUpdateTimer;
  Timer? _aiUpdateTimer;
  Timer? _uiCountdownTimer;
  DateTime? _nextAiUpdateTime;
  String _countdownString = "--:--";
  double _panelHeight = 50.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialDataFetch();
      _uiUpdateTimer = Timer.periodic(const Duration(seconds: 4), (Timer t) {
        if (mounted) {
          Provider.of<PodDataProvider>(context, listen: false).updatePodData();
        }
      });
      _startAiUpdateTimer();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _startUiCountdownTimer() {
    _uiCountdownTimer?.cancel();
    _uiCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final provider = Provider.of<PodDataProvider>(context, listen: false);
      if (provider.isUpdatingAiPlan) {
        setState(() => _countdownString = "Updating...");
        return;
      }
      if (_nextAiUpdateTime != null) {
        final remaining = _nextAiUpdateTime!.difference(DateTime.now());
        setState(
          () =>
              _countdownString =
                  remaining.isNegative ? "00:00" : _formatDuration(remaining),
        );
      }
    });
  }

  void _startAiUpdateTimer() {
    _aiUpdateTimer?.cancel();
    _aiUpdateTimer = Timer.periodic(const Duration(minutes: 30), (Timer t) {
      if (mounted) {
        print("--- 30-minute timer fired: Requesting new AI plan. ---");
        Provider.of<PodDataProvider>(
          context,
          listen: false,
        ).requestAndUpdateAiPlan();
      }
    });
    _nextAiUpdateTime = DateTime.now().add(const Duration(minutes: 30));
    _startUiCountdownTimer();
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _aiUpdateTimer?.cancel();
    _uiCountdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialDataFetch() async {
    if (mounted) {
      Provider.of<PodDataProvider>(context, listen: false).updatePodData();
    }
  }

  Widget _buildFrostedCard({required Widget child, required Color color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PodDataProvider>(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'PodPal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0x32397144).withOpacity(0.3),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next AI: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  _countdownString,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF011001),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 10, 16.0, 14.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: BottomAppBar(
            color: Color(0x32397144).withOpacity(0.3),
            //shape: const CircularNotchedRectangle(),
            //notchMargin: 8.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                //vertical: 10.0,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.show_chart,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed:
                              () => Navigator.pushNamed(context, '/charts'),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed:
                              () => Navigator.pushNamed(context, '/settings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 60), // Space for the FAB
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed:
                              () => Navigator.pushNamed(context, '/ask_expert'),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed:
                              () => Navigator.pushNamed(context, '/profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15.0),
        child: SizedBox(
          width: 60.0,
          height: 60.0,
          child: FloatingActionButton(
            onPressed:
                provider.isUpdatingAiPlan
                    ? null
                    : () {
                      print("--- Manual trigger: Requesting new AI plan. ---");
                      provider.requestAndUpdateAiPlan().then((_) {
                        _startAiUpdateTimer();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.aiPlanError == null
                                    ? 'AI Plan updated successfully!'
                                    : 'AI plan update failed: ${provider.aiPlanError}',
                              ),
                              backgroundColor:
                                  provider.aiPlanError == null
                                      ? Colors.green
                                      : Colors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.fromLTRB(
                                16.0,
                                0,
                                16.0,
                                24.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          );
                        }
                      });
                    },
            backgroundColor: const Color(0xFF569E36),
            shape: const CircleBorder(),
            child:
                provider.isUpdatingAiPlan
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      "Update\nAI",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Consumer<PodDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.podStatus == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.hasError && provider.podStatus == null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          final status = provider.podStatus;
          final avgLdr =
              status != null
                  ? (status.ldrValue1 + status.ldrValue2 + status.ldrValue3) / 3
                  : 0;
          final lightPercent = status != null ? (100-(avgLdr / 1023) * 100 ): 0;

          return Stack(
            children: [
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.asset(
                      'assets/images/homeplantbg.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  HomeStatusCard(
                                    title: "Temp",
                                    value:
                                        status != null
                                            ? "${status.temperature.toStringAsFixed(1)}°"
                                            : '...',
                                    icon: Icons.thermostat_outlined,
                                    cardColor: const Color(0x32397144),
                                  ),
                                  const SizedBox(height: 10),
                                  HomeStatusCard(
                                    title: "Humidity",
                                    value:
                                        status != null
                                            ? "${status.humidity.toStringAsFixed(1)}%"
                                            : '...',
                                    icon: Icons.water_drop_outlined,
                                    cardColor: const Color(0x32397144),
                                  ),
                                  const SizedBox(height: 10),
                                  HomeStatusCard(
                                    title: "Soil",
                                    value:
                                        status != null
                                            ? "${((1023 - status.moisture) / 1023 * 100).toStringAsFixed(0)}%"
                                            : '...',
                                    icon: Icons.opacity_outlined,
                                    cardColor: const Color(0x32397144),
                                  ),
                                  const SizedBox(height: 10),
                                  HomeStatusCard(
                                    title: "Light",
                                    value:
                                        status != null
                                            ? "${lightPercent.toStringAsFixed(0)}%"
                                            : '...',
                                    icon: Icons.wb_sunny_outlined,
                                    cardColor: const Color(0x32397144),
                                  ),
                                ],
                              ),
                              
                              // ... inside the Row with the HomeStatusCard Column
                              Expanded(
                                child: Consumer<PodDataProvider>(
                                  builder: (context, provider, child) {
                                    // Default to healthy (1.0)
                                    double currentHealth = 1.0;

                                    if (provider.podStatus != null) {
                                      final status = provider.podStatus!;

                                      // If temp is too high OR soil is too dry, make the plant unhealthy.
                                      if (status.temperature > 35.0 ||
                                          ((1023 - status.moisture) /
                                                  1023 *
                                                  100) <
                                              30) {
                                        currentHealth = 0.0; // Unhealthy
                                      }
                                    }

                                    // Pass the health value to the new AnimatedPlant
                                    return AnimatedPlant(health: currentHealth);
                                  },
                                ),
                              ),
                            ],
                          ),
                          /*Positioned(
                            top: 0,
                            left: 125 + 16,
                            right: 0,
                            child: Text(
                              provider.plantProfile?.personality ??
                                  "He's a smooth operator who thinks every meal is a jam session waiting for his solo.",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),*/
                        ],
                      ),
                      const Spacer(),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 1,
                              child:
                                  status != null
                                      ? PodCoverStatus(
                                        leftAngle: status.coverAngle1,
                                        rightAngle: status.coverAngle2,
                                        backAngle: status.coverAngle3,
                                      )
                                      : const SizedBox(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /*_buildFrostedCard(
                                    color: const Color(
                                      0x32397144,
                                    ).withOpacity(0.12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Panel Height',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            Text(
                                              '${_panelHeight.round()}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Slider(
                                          value: _panelHeight,
                                          min: 0,
                                          max: 100,
                                          divisions: 100,
                                          activeColor: Colors.tealAccent,
                                          inactiveColor: Colors.teal
                                              .withOpacity(0.3),
                                          onChanged: (newValue) {
                                            setState(() {
                                              _panelHeight = newValue;
                                            });
                                          },
                                          onChangeEnd: (finalValue) {
                                            print(
                                              "Setting final panel height to: ${finalValue.round()}%",
                                            );
                                            provider
                                                .setPanelHeight(
                                                  finalValue.round(),
                                                )
                                                .catchError((e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Failed to set panel height: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      // MODIFIED: Corrected SnackBar for this error as well.
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                      margin:
                                                          const EdgeInsets.fromLTRB(
                                                            16.0,
                                                            0,
                                                            16.0,
                                                            24.0,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15.0,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),*/
                                  const SizedBox(height: 10),
                                  _buildFrostedCard(
                                    color: const Color(0x32397144),
                                    child: Column(
                                      children: [
                                        LevelIndicator(
                                          title: "Water Level",
                                          level: status?.waterLevel ?? "N/A",
                                        ),
                                        const SizedBox(height: 10),
                                        LevelIndicator(
                                          title: "Nutrient Level",
                                          level: status?.nutrientLevel ?? "N/A",
                                        ),
                                        const SizedBox(height: 16),
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
            ],
          );
        },
      ),
    );
  }
}
