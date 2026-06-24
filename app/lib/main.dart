import 'package:flutter/material.dart';

// Digital Saver - Web App
// Professional Health Monitoring Dashboard

void main() {
  runApp(const DigitalSaverApp());
}

class DigitalSaverApp extends StatelessWidget {
  const DigitalSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Saver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563eb),
          brightness: Brightness.light,
        ),
      ),
      home: const WebDashboard(),
    );
  }
}

class WebDashboard extends StatefulWidget {
  const WebDashboard({super.key});

  @override
  State<WebDashboard> createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard> {
  int _currentTab = 0;
  bool _isDarkMode = false;
  
  // Simulated health data
  int _heartRate = 72;
  int _systolic = 120;
  int _diastolic = 80;
  int _spO2 = 98;
  int _steps = 8542;
  int _calories = 420;
  double _sleepScore = 85;
  int _sleepHours = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 12),
            Text('Digital Saver'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentTab,
            onDestinationSelected: (index) => setState(() => _currentTab = index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Heart')),
              NavigationRailDestination(icon: Icon(Icons.water_drop), label: Text('BP')),
              NavigationRailDestination(icon: Icon(Icons.directions_run), label: Text('Activity')),
              NavigationRailDestination(icon: Icon(Icons.bedtime), label: Text('Sleep')),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentTab) {
      case 0: return _buildDashboard();
      case 1: return _buildHeartScreen();
      case 2: return _buildBPScreen();
      case 3: return _buildActivityScreen();
      case 4: return _buildSleepScreen();
      case 5: return _buildSettingsScreen();
      default: return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Heart Rate', '$_heartRate', 'BPM', Icons.favorite, Colors.red)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Blood Pressure', '$_systolic/$_diastolic', 'mmHg', Icons.water_drop, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Blood Oxygen', '$_spO2', '%', Icons.air, Colors.cyan)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Steps', '$_steps', 'steps', Icons.directions_walk, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 40),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency System', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('Fall detection & GPS alerts', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAlert(),
                    icon: const Icon(Icons.emergency),
                    label: const Text('Test Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: Colors.red, size: 64),
          const SizedBox(height: 20),
          Text('$_heartRate', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.red)),
          const Text('BPM - Normal', style: TextStyle(fontSize: 20, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildBPScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.water_drop, color: Colors.blue, size: 64),
          const SizedBox(height: 20),
          Text('$_systolic/$_diastolic', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blue)),
          const Text('mmHg - Normal', style: TextStyle(fontSize: 20, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildActivityScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.directions_walk, color: Colors.orange, size: 48),
                  const SizedBox(height: 16),
                  Text('$_steps', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const Text('Steps Today'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _steps / 10000,
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 8),
                  Text('${(_steps / 10000 * 100).toInt()}% of 10,000 goal'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('$_calories', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const Text('Calories Burned'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.purple.shade700]),
            ),
            child: Center(
              child: Text('${_sleepScore.toInt()}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Sleep Score: ${_sleepScore.toInt()}', style: const TextStyle(fontSize: 24)),
          Text('Duration: $_sleepHours hours', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  subtitle: const Text('Name, Age, Emergency Info'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.emergency, color: Colors.red),
                  title: const Text('Emergency Contacts'),
                  subtitle: const Text('Add up to 3 contacts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: const Text('Smartwatch'),
                  subtitle: const Text('Demo Mode'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.emergency, color: Colors.red), SizedBox(width: 8), Text('Emergency Alert')],
        ),
        content: const Text('This would send an emergency SMS with GPS location to all emergency contacts.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }
}
