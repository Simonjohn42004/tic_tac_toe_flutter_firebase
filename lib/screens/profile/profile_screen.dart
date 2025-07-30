import 'package:flutter/material.dart';
import 'package:tic_tac_toe/component/glowing_button.dart'; // Make sure you have this imported

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Placeholder user data variables
  String _userName = 'PlayerOne'; // TODO: Replace with data from Firebase
  int _selectedAvatarIndex = 0; // TODO: Load saved avatar index from Firebase

  // Avatar assets paths
  final List<String> _avatarPaths = List.generate(
    9,
    (index) => 'assets/avatars/avatar${index + 1}.png',
  );

  // Placeholder stats (all zeros or sample)
  int _totalMatches = 0; // TODO: Load from Firebase
  int _totalWins = 0; // TODO: Load from Firebase
  int _totalLosses = 0; // TODO: Load from Firebase
  double _overallWinRate = 0.0; // TODO: Calculate from Firebase data
  double _lastTenWinRate = 0.0; // TODO: Calculate from Firebase data
  int _rating = 0; // Future rating, stored in Firebase

  void _showAvatarPicker() {
    print("[ProfilePage] Opening avatar picker dialog");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151F2E),
          title: const Text(
            'Choose Avatar',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Adjust height to show multiple avatars and scroll
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                cacheExtent: 0.0,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _avatarPaths.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedAvatarIndex;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(_avatarPaths[index]),
                      radius: 24,
                    ),
                    title: Text(
                      'Avatar ${index + 1}',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF10CFFF)
                            : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10CFFF),
                          )
                        : null,
                    onTap: () {
                      print("[ProfilePage] Avatar selected index: $index");
                      setState(() => _selectedAvatarIndex = index);
                      Navigator.of(context).pop();

                      // TODO: Save selected avatar index to Firebase
                    },
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF10CFFF)),
              ),
              onPressed: () {
                print("[ProfilePage] Avatar picker cancelled");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editUserName() async {
    print("[ProfilePage] Opening edit username dialog");
    final controller = TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151F2E),
          title: const Text('Edit Name', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Color(0xFF232736),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("[ProfilePage] Edit username cancelled");
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF10CFFF)),
              ),
            ),
            TextButton(
              onPressed: () {
                print(
                  "[ProfilePage] Edit username save pressed: ${controller.text.trim()}",
                );
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF10CFFF)),
              ),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != _userName) {
      print("[ProfilePage] Username changed from $_userName to $newName");
      setState(() => _userName = newName);
      // TODO: Save new user name to Firebase
    }
  }

  String _formatPercentage(double value) =>
      (value * 100).toStringAsFixed(1) + '%';

  @override
  Widget build(BuildContext context) {
    print(
      "[ProfilePage] build called: username=$_userName, avatarIndex=$_selectedAvatarIndex",
    );
    return Scaffold(
      backgroundColor: const Color(0xFF10141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2E),
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _showAvatarPicker,
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: const Color(0xFF232736),
                  backgroundImage: AssetImage(
                    _avatarPaths[_selectedAvatarIndex],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF10CFFF)),
                    onPressed: _editUserName,
                    tooltip: "Edit Name",
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatRow('Total Matches Played', _totalMatches.toString()),
              _buildStatRow('Matches Won', _totalWins.toString()),
              _buildStatRow('Matches Lost', _totalLosses.toString()),
              _buildStatRow(
                'Overall Win Rate',
                _formatPercentage(_overallWinRate),
              ),
              _buildStatRow(
                'Win Rate (Last 10)',
                _formatPercentage(_lastTenWinRate),
              ),
              _buildStatRow('Rating', _rating.toString()),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlowingButton(
                  label: 'Log Out',
                  onTap: () {
                    print("[ProfilePage] Log Out button tapped");
                    // TODO: Implement logout with Firebase Auth or your auth provider
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
