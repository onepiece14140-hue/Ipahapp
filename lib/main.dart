import 'package:flutter/material.dart';

void main() => runApp(const ProxyUtilityApp());

class ProxyUtilityApp extends StatelessWidget {
  const ProxyUtilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    return MaterialApp(
      title: 'Proxy Utility Starter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F6FA),
      ),
      home: const HomeShell(),
    );
  }
}

class Profile {
  Profile(this.name, this.endpoint, {this.latency = 0, this.enabled = true});
  String name;
  String endpoint;
  int latency;
  bool enabled;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _connected = false;
  final List<Profile> _profiles = [
    Profile('Example profile', 'example.invalid:443', latency: 42),
    Profile('Local demo', '127.0.0.1:1080', latency: 18, enabled: false),
  ];
  final List<String> _logs = [
    'Starter UI initialized (demo mode)',
    'No VPN or proxy service is connected',
    'Profile data is local mock data',
  ];

  void _addProfile() async {
    final nameController = TextEditingController();
    final endpointController = TextEditingController();
    final result = await showDialog<Profile>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add profile'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: endpointController, decoration: const InputDecoration(labelText: 'Server / endpoint')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final name = nameController.text.trim();
            final endpoint = endpointController.text.trim();
            if (name.isNotEmpty && endpoint.isNotEmpty) {
              Navigator.pop(context, Profile(name, endpoint));
            }
          }, child: const Text('Add')),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _profiles.add(result);
        _logs.insert(0, 'Added local demo profile: ${result.name}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardPage(connected: _connected, profileCount: _profiles.length,
        onToggle: () => setState(() {
          _connected = !_connected;
          _logs.insert(0, _connected ? 'Demo connect button tapped (no tunnel started)' : 'Demo disconnect button tapped');
        }),
        onProfiles: () => setState(() => _index = 1)),
      _ProfilesPage(profiles: _profiles, onAdd: _addProfile,
        onChanged: (profile, value) => setState(() {
          profile.enabled = value;
          _logs.insert(0, 'Changed local profile setting: ${profile.name}');
        })),
      const _StatisticsPage(),
      _SettingsPage(onOpenLogs: () => setState(() => _index = 2)),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(['Overview', 'Profiles', 'Statistics', 'Settings'][_index])),
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      floatingActionButton: _index == 1
          ? FloatingActionButton(onPressed: _addProfile, tooltip: 'Add profile', child: const Icon(Icons.add))
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.dns_outlined), selectedIcon: Icon(Icons.dns), label: 'Profiles'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({required this.connected, required this.profileCount, required this.onToggle, required this.onProfiles});
  final bool connected;
  final int profileCount;
  final VoidCallback onToggle;
  final VoidCallback onProfiles;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(connected ? Icons.shield : Icons.shield_outlined, size: 42, color: connected ? Colors.green : null),
      const SizedBox(height: 12),
      Text(connected ? 'Demo connected' : 'Not connected', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 6),
      const Text('This is a UI prototype. The button does not create a VPN tunnel.'),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onToggle,
        icon: Icon(connected ? Icons.stop : Icons.play_arrow), label: Text(connected ? 'Disconnect demo' : 'Connect demo'))),
    ]))),
    const SizedBox(height: 14),
    Row(children: [Expanded(child: _MetricCard(icon: Icons.dns, title: 'Profiles', value: '$profileCount', onTap: onProfiles)), const SizedBox(width: 12), const Expanded(child: _MetricCard(icon: Icons.speed, title: 'Latency', value: '—'))]),
    const SizedBox(height: 14),
    const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Starter project'), subtitle: Text('Cross-platform Flutter UI with mock data only.'))),
  ]);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.title, required this.value, this.onTap});
  final IconData icon; final String title; final String value; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 12), Text(value, style: Theme.of(context).textTheme.headlineMedium), Text(title)]))));
}

class _ProfilesPage extends StatelessWidget {
  const _ProfilesPage({required this.profiles, required this.onAdd, required this.onChanged});
  final List<Profile> profiles; final VoidCallback onAdd; final void Function(Profile, bool) onChanged;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Local demo profiles. No subscription URL is fetched and no server is contacted.'),
    const SizedBox(height: 12),
    ...profiles.map((p) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.dns_outlined)),
      title: Text(p.name), subtitle: Text('${p.endpoint}\n${p.latency == 0 ? 'Latency not tested' : '${p.latency} ms (sample)'}'), isThreeLine: true,
      trailing: Switch(value: p.enabled, onChanged: (value) => onChanged(p, value)),
    ))),
    OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add local profile')),
  ]);
}

class _StatisticsPage extends StatelessWidget {
  const _StatisticsPage();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Demo statistics'), subtitle: Text('Counters are placeholders; traffic is not measured.'))),
    const SizedBox(height: 12),
    const Row(children: [Expanded(child: _StatTile(label: 'Downloaded', value: '0 MB', icon: Icons.download)), SizedBox(width: 12), Expanded(child: _StatTile(label: 'Uploaded', value: '0 MB', icon: Icons.upload))]),
    const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Recent activity', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 18), const _BarRow(label: 'Download', value: .15), const _BarRow(label: 'Upload', value: .08)]))),
    const SizedBox(height: 12),
    const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Logs\n\nUI initialized\nNo active tunnel\nStatistics are mock values'))),
  ]);
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});
  final String label, value; final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 10), Text(value, style: Theme.of(context).textTheme.titleLarge), Text(label)])));
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.label, required this.value});
  final String label; final double value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [SizedBox(width: 92, child: Text(label)), Expanded(child: LinearProgressIndicator(value: value, minHeight: 8)), const SizedBox(width: 10), const Text('0 MB')]));
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage({required this.onOpenLogs});
  final VoidCallback onOpenLogs;
  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool _notifications = true;
  bool _autoConnect = false;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const _SectionTitle('General'),
    Card(child: Column(children: [
      SwitchListTile(title: const Text('Notifications'), subtitle: const Text('Local UI preference only'), value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
      const Divider(height: 1),
      SwitchListTile(title: const Text('Auto-connect'), subtitle: const Text('Not wired to a VPN service'), value: _autoConnect, onChanged: (v) => setState(() => _autoConnect = v)),
      const Divider(height: 1),
      ListTile(leading: const Icon(Icons.language), title: const Text('Language'), subtitle: const Text('System default'), trailing: const Icon(Icons.chevron_right), onTap: () => _message(context, 'Language picker is not implemented yet.')),
    ])),
    const SizedBox(height: 16), const _SectionTitle('Diagnostics'),
    Card(child: Column(children: [
      ListTile(leading: const Icon(Icons.article_outlined), title: const Text('Logs'), subtitle: const Text('Demo events only'), trailing: const Icon(Icons.chevron_right), onTap: widget.onOpenLogs),
      const Divider(height: 1),
      const ListTile(leading: Icon(Icons.info_outline), title: Text('About'), subtitle: Text('Proxy Utility Starter · 0.1.0')),
    ])),
    const SizedBox(height: 16),
    const Text('VPN, routing, subscriptions, background services, QR scanning, and server connectivity are not implemented in this starter.'),
  ]);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(text, style: Theme.of(context).textTheme.titleSmall));
}

void _message(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
