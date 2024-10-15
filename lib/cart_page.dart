import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carts')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading cart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance.clearPersistence();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Your cart is empty'));
          }
          final cartItems = (snapshot.data!.data()
              as Map<String, dynamic>)['items'] as List<dynamic>;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      leading: Image.network(item['imageUrl'],
                          width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item['name']),
                      subtitle:
                          Text('${item['quantity']}${item['unit']}, Price'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove,
                                color: Color.fromARGB(255, 4, 163, 65)),
                            onPressed: () => updateCartItemQuantity(
                                context, item['productId'], -1),
                          ),
                          Text('${item['quantity']}'),
                          IconButton(
                            icon: const Icon(Icons.add,
                                color: Color.fromARGB(255, 4, 163, 65)),
                            onPressed: () => updateCartItemQuantity(
                                context, item['productId'], 1),
                          ),
                          Text(
                              'PKR ${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                removeFromCart(context, item['productId']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 4, 163, 65),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    showCheckoutModal(
                        context, calculateTotal(cartItems), cartItems);
                  },
                  child: Text(
                    'Checkout PKR ${calculateTotal(cartItems).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void showCheckoutModal(
      BuildContext context, double totalCost, List<dynamic> cartItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CheckoutModal(totalCost: totalCost, cartItems: cartItems);
      },
    );
  }

  double calculateTotal(List<dynamic> cartItems) {
    return cartItems.fold(
        0, (total, item) => total + (item['price'] * item['quantity']));
  }

  void updateCartItemQuantity(
      BuildContext context, String productId, int change) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cartRef =
            FirebaseFirestore.instance.collection('carts').doc(user.uid);
        final cartDoc = await cartRef.get();
        final cartItems =
            List.from((cartDoc.data() as Map<String, dynamic>)['items']);
        final itemIndex =
            cartItems.indexWhere((item) => item['productId'] == productId);
        if (itemIndex != -1) {
          int newQuantity = cartItems[itemIndex]['quantity'] + change;
          if (newQuantity > 0) {
            cartItems[itemIndex]['quantity'] = newQuantity;
            await cartRef.update({'items': cartItems});
          } else if (newQuantity <= 0) {
            cartItems.removeAt(itemIndex);
            await cartRef.update({'items': cartItems});
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Failed to update cart. Please check your internet connection.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  void removeFromCart(BuildContext context, String productId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cartRef =
            FirebaseFirestore.instance.collection('carts').doc(user.uid);
        final cartDoc = await cartRef.get();
        final cartItems =
            List.from((cartDoc.data() as Map<String, dynamic>)['items']);
        cartItems.removeWhere((item) => item['productId'] == productId);
        await cartRef.update({'items': cartItems});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Failed to remove item. Please check your internet connection.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }
}

class CheckoutModal extends StatefulWidget {
  final double totalCost;
  final List<dynamic> cartItems;

  const CheckoutModal(
      {super.key, required this.totalCost, required this.cartItems});

  @override
  _CheckoutModalState createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal> {
  String selectedPaymentMethod = 'Cash on Delivery';
  String? selectedAddress;
  List<String> savedAddresses = [];
  bool isLoading = true;
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  void fetchAddresses() async {
    if (isFetching) return;
    isFetching = true;
    print("Fetching addresses...");
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("User is authenticated. UID: ${user.uid}");
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        print("Firestore document fetched. Exists: ${doc.exists}");

        if (doc.exists && doc.data()!.containsKey('address')) {
          var addressesData = doc.data()!['address'];
          print("Address data type: ${addressesData.runtimeType}");
          print("Address data: $addressesData");

          if (addressesData is String && addressesData.isNotEmpty) {
            savedAddresses = [addressesData];
          } else if (addressesData is List && addressesData.isNotEmpty) {
            savedAddresses = List<String>.from(addressesData);
          } else {
            savedAddresses = [];
          }

          print("Parsed saved addresses: $savedAddresses");

          if (savedAddresses.isNotEmpty) {
            selectedAddress = savedAddresses.first;
          }
        } else {
          print("No address data found in the document");
        }
      } catch (e) {
        print('Error fetching addresses: $e');
        savedAddresses = [];
      } finally {
        print("Updating state. isLoading: false");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        isFetching = false;
      }
    } else {
      print("User is not authenticated");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      isFetching = false;
    }
  }

  void addNewAddress(String newAddress) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'address': FieldValue.arrayUnion([newAddress])
        });
        fetchAddresses(); // Refresh the address list
      } catch (e) {
        print('Error adding new address: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add new address. Please try again.')),
        );
      }
    }
  }

  void placeOrder() async {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select an address before placing the order.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create order
        await FirebaseFirestore.instance.collection('orders').add({
          'userId': user.uid,
          'username': user.displayName ?? 'Anonymous',
          'products': widget.cartItems,
          'address': selectedAddress,
          'paymentMethod': selectedPaymentMethod,
          'totalCost': widget.totalCost,
          'dateTime': FieldValue.serverTimestamp(),
        });

        // Clear cart
        await FirebaseFirestore.instance
            .collection('carts')
            .doc(user.uid)
            .update({'items': []});

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const OrderConfirmationPage()),
        );
      }
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to place order. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newAddress = '';
        return AlertDialog(
          title: const Text('Add New Address'),
          content: TextField(
            onChanged: (value) {
              newAddress = value;
            },
            decoration: const InputDecoration(hintText: "Enter your address"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (newAddress.isNotEmpty) {
                  addNewAddress(newAddress);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          isLoading
              ? const CircularProgressIndicator()
              : ListTile(
                  title: const Text('Address'),
                  subtitle: Text(
                      selectedAddress ?? 'No address found. Add an address.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Select or Add Address'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...savedAddresses.map((addr) => ListTile(
                                      title: Text(addr),
                                      onTap: () {
                                        setState(() {
                                          selectedAddress = addr;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    )),
                                ListTile(
                                  leading: const Icon(Icons.add),
                                  title: const Text('Add new address'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    showAddressDialog();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          ListTile(
            title: const Text('Payment'),
            trailing: DropdownButton<String>(
              value: selectedPaymentMethod,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedPaymentMethod = newValue;
                  });
                }
              },
              items: <String>['Cash on Delivery', 'Easypaisa']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('Total Cost'),
            trailing: Text('PKR ${widget.totalCost.toStringAsFixed(2)}'),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'By placing an order you agree to our Terms and Conditions',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 4, 163, 65),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed:
                  isLoading || selectedAddress == null ? null : placeOrder,
              child: const Text(
                'Place Order',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 4, 163, 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delivery_dining,
              size: 120,
              color: Color.fromARGB(255, 4, 163, 65),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order is Placed',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 4, 163, 65),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rider is on his way',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'He will arrive soon',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 4, 163, 65),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/homepage');
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
