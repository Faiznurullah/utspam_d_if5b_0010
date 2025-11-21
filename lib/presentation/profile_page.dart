import 'package:flutter/material.dart';
import 'transaction_history_page.dart';
import 'profile_edit_page.dart';
import '../data/model/user.dart';
import '../data/repository/user.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final User? currentUser;
  
  const ProfilePage({super.key, this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = UserRepository();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.currentUser != null) {
        // Refresh user data from database
        final updatedUser = await _userRepository.getUserById(widget.currentUser!.id!);
        setState(() {
          _currentUser = updatedUser ?? widget.currentUser;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentUser = widget.currentUser;
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 260,
            child: Image.asset(
              "assets/images/profile_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      GestureDetector(
                        child: Icon(Icons.arrow_back, color: Colors.white),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      const Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 24),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Avatar section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.blue[300],
                                child: _currentUser != null
                                    ? Text(
                                        _getInitials(_currentUser!.fullname),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                              ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoading ? "Loading..." : (_currentUser?.fullname ?? "User"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoading ? "Loading..." : (_currentUser?.email ?? "user@gmail.com"),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoading ? "Loading..." : (_currentUser?.phone ?? "+62-"),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (_currentUser?.address != null && _currentUser!.address!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _currentUser!.address!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: _currentUser != null
                            ? () async {
                                final updatedUser = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileEditPage(
                                      currentUser: _currentUser,
                                    ),
                                  ),
                                );
                                
                                if (updatedUser != null && updatedUser is User) {
                                  setState(() {
                                    _currentUser = updatedUser;
                                  });
                                }
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),

                  ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text('Transaction History'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionHistoryPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.door_back_door_outlined,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                       Navigator.pushAndRemoveUntil(
                         context,
                         MaterialPageRoute(builder: (context) => LoginPage()),
                         (route) => false,
                       );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
