
import 'package:flutter/material.dart';
import '../data/model/user.dart';
import '../data/repository/user.dart';

class ProfileEditPage extends StatefulWidget {
  final User? currentUser;
  
  const ProfileEditPage({super.key, this.currentUser});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();
  
  // Controllers
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPasswordChanged = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    final user = widget.currentUser!;
    _fullnameController.text = user.fullname;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _addressController.text = user.address ?? '';
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value)) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    if (widget.currentUser != null && username == widget.currentUser!.username) {
      return true; // Username yang sama dengan current user
    }
    return !(await _userRepository.isUsernameExists(username));
  }

  Future<bool> _checkEmailAvailability(String email) async {
    if (widget.currentUser != null && email == widget.currentUser!.email) {
      return true; // Email yang sama dengan current user
    }
    return !(await _userRepository.isEmailExists(email));
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isPasswordChanged && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan konfirmasi password tidak cocok'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check username availability
      if (!await _checkUsernameAvailability(_usernameController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username sudah digunakan'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check email availability
      if (!await _checkEmailAvailability(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah digunakan'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create updated user
      final updatedUser = User(
        id: widget.currentUser!.id,
        fullname: _fullnameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        password: _isPasswordChanged ? _passwordController.text : widget.currentUser!.password,
      );

      await _userRepository.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );

      // Return updated user to previous page
      Navigator.of(context).pop(updatedUser);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar section (read-only for now)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue[600]!, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/avatar.png"),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),

              // Full Name
              const Text(
                'Nama Lengkap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullnameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Username
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan username',
                  prefixIcon: const Icon(Icons.account_circle),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                    return 'Username minimal 3 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
                validator: _validateEmail,
              ),

              const SizedBox(height: 16),

              // Phone
              const Text(
                'Nomor Telepon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Masukkan nomor telepon',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
                validator: _validatePhone,
              ),

              const SizedBox(height: 16),

              // Address
              const Text(
                'Alamat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat (opsional)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Password Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Ubah Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isPasswordChanged,
                          onChanged: (value) {
                            setState(() {
                              _isPasswordChanged = value;
                              if (!value) {
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    
                    if (_isPasswordChanged) ...[
                      const SizedBox(height: 16),
                      
                      // New Password
                      const Text(
                        'Password Baru',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Masukkan password baru',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: _isPasswordChanged ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password baru tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        } : null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Confirm Password
                      const Text(
                        'Konfirmasi Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Konfirmasi password baru',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: _isPasswordChanged ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password tidak boleh kosong';
                          }
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        } : null,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}