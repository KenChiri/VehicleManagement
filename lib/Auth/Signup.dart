import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hive/hive.dart';
import 'package:vehicle/Auth/login.dart';
import 'package:vehicle/models/user.dart' as local_user;  // Alias for your local User model

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();  // New Confirm Password Controller
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'Driver'; // Default role
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();  // Dispose the confirm password controller
    _nameController.dispose();
    super.dispose();
  }

  // Sign up method using Hive for local storage
  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if the passwords match
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Store user details in Hive
        var userBox = await Hive.openBox<local_user.User>('users');  // Open the box for 'User' objects
        var user = local_user.User(
          email: _emailController.text,
          name: _nameController.text,
          role: _selectedRole,
          password: _passwordController.text,  // Store the password
        );
        userBox.put(_emailController.text, user);  // Store user by email as the key

        // Show success pop-up alert after data is stored in Hive
        _showSuccessDialog();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Success Dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Signup Successful'),
          content: const Text('Your data has been successfully stored.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                const Icon(
                  Icons.person_add,
                  size: 70.0,
                  color: Color(0xFFDEAF4B),
                ),
                const SizedBox(height: 10),

                const Text(
                  'Create your account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                  ),
                  validator: RequiredValidator(errorText: 'Name is required').call,
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                  ),
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Email is required'),
                    EmailValidator(errorText: 'Enter a valid email'),
                  ]).call,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                  ),
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Password is required'),
                    MinLengthValidator(6, errorText: 'Password must be at least 6 characters long'),
                  ]).call,
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Role dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['Driver', 'Company Manager', 'Parking Attendant']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Sign Up button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF63D1F6), // Background color of the button
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 40.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _signup,  // Call _signup on tap
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black, // Text color
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                const SizedBox(height: 16),

                // Link to login page
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Center(
                    child: Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}