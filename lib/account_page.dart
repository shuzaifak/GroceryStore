import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _username = '';
  String _email = '';
  String _address = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          _username = _safeGetString(userData, 'username');
          _email = _safeGetString(userData, 'email');
          _address = _safeGetString(userData, 'address');
          _profileImageUrl = userData.data() is Map
              ? (userData.data() as Map)['profileImageUrl'] as String?
              : null;
        });
      }
    }
  }

  String _safeGetString(DocumentSnapshot snapshot, String field) {
    if (snapshot.data() is Map) {
      var data = snapshot.data() as Map;
      if (data.containsKey(field)) {
        var value = data[field];
        if (value is String) {
          return value;
        } else if (value is List) {
          return value.join(', ');
        } else {
          return value?.toString() ?? '';
        }
      }
    }
    return '';
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      User? user = _auth.currentUser;

      if (user != null) {
        String fileName = 'profile_${user.uid}.jpg';
        Reference storageRef = _storage.ref().child('profile_images/$fileName');

        await storageRef.putFile(imageFile);
        String downloadUrl = await storageRef.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.green)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _updateProfileImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(_username),
              subtitle: const Text('Username'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(_email),
              subtitle: const Text('Email'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(_address),
              subtitle: const Text('Address'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Orders History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrderHistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: currentUser == null
          ? const Center(child: Text('No user logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: currentUser.uid)
                  .orderBy('dateTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(
                      child: Text('No data received from Firestore'));
                }

                print('Number of documents: ${snapshot.data!.docs.length}');

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No orders found'),
                        const SizedBox(height: 20),
                        const Text('Debug Info:'),
                        Text('User ID: ${currentUser.uid}'),
                        const Text('Collection: orders'),
                        Text('Query: where userId == ${currentUser.uid}'),
                        Text(
                            'Number of documents: ${snapshot.data!.docs.length}'),
                        ElevatedButton(
                          child: const Text('Print all documents'),
                          onPressed: () {
                            for (var doc in snapshot.data!.docs) {
                              print('Document ID: ${doc.id}');
                              print('Document data: ${doc.data()}');
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index];
                    return OrderCard(order: order);
                  },
                );
              },
            ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    var date = (order['dateTime'] as Timestamp).toDate();
    var formattedDate = DateFormat('MMM d, yyyy HH:mm').format(date);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${order.id.substring(0, 8)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Date: $formattedDate'),
            Text('Total Cost: \$${order['totalCost']}'),
            Text('Payment Method: ${order['paymentMethod']}'),
            Text('Address: ${order['address']}'),
            const SizedBox(height: 8),
            const Text('Products:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...buildProductList(order['products']),
          ],
        ),
      ),
    );
  }

  List<Widget> buildProductList(List<dynamic> products) {
    return products.map((product) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text('${product['name']} - Quantity: ${product['quantity']}'),
      );
    }).toList();
  }
}
