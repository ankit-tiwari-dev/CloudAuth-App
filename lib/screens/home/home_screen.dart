import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final firebaseUser = _firebaseService.currentUser;
    if (firebaseUser != null) {
      final userData =
          await _firebaseService.getUserFromFirestore(firebaseUser.uid);
      if (userData != null && mounted) {
        setState(() {
          _user = UserModel.fromJson(userData);
          _isLoading = false;
        });
      }
    } else {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await _firebaseService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_user != null) ...[
              Text('Welcome, ${_user!.displayName ?? 'User'}!',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Email: ${_user!.email}'),
              const SizedBox(height: 8),
              Text('UID: ${_user!.uid}'),
              const SizedBox(height: 32),
            ] else ...[
              const Text('No User Data loaded.'),
              const SizedBox(height: 32),
            ],
            const Text('Local Assets:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
               height: 200,
               child: ListView(
                 scrollDirection: Axis.horizontal,
                 children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset('assets/images/image1.jpg', width: 200, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 200, color: Colors.grey, child: const Center(child: Text('Placeholder Image 1'))),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset('assets/images/image2.jpg', width: 200, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 200, color: Colors.grey, child: const Center(child: Text('Placeholder Image 2'))),),
                    )
                 ]
               )
            )
          ],
        ),
      ),
    );
  }
}
