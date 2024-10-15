import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> setupFirestore() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // Ensure the user is authenticated
  if (auth.currentUser == null) {
    throw Exception('User must be authenticated to perform initial setup');
  }

  // Check if setup has already been performed
  DocumentSnapshot setupDoc =
      await firestore.collection('setup').doc('status').get();
  if (setupDoc.exists && setupDoc.get('completed') == true) {
    print('Setup has already been performed');
    return;
  }
  // Define product categories
  List<String> categories = ['Grocery', 'Fruits', 'Vegetables', 'Bakery'];

  // Sample products (20 items)
  List<Map<String, dynamic>> products = [
    {
      'name': 'Organic Bananas',
      'price': 99.99,
      'quantity': 7,
      'unit': 'pcs',
      'category': 'Fruits',
      'imageUrl':
          'https://images.unsplash.com/photo-1603833665858-e61d17a86224?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Red Apple',
      'price': 149.99,
      'quantity': 1,
      'unit': 'kg',
      'category': 'Fruits',
      'imageUrl':
          'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Carrots',
      'price': 59.99,
      'quantity': 5,
      'unit': 'pcs',
      'category': 'Vegetables',
      'imageUrl':
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Whole Wheat Bread',
      'price': 79.99,
      'quantity': 1,
      'unit': 'loaf',
      'category': 'Bakery',
      'imageUrl':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Milk',
      'price': 89.99,
      'quantity': 1,
      'unit': 'liter',
      'category': 'Grocery',
      'imageUrl':
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Tomatoes',
      'price': 69.99,
      'quantity': 6,
      'unit': 'pcs',
      'category': 'Vegetables',
      'imageUrl':
          'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Croissant',
      'price': 39.99,
      'quantity': 3,
      'unit': 'pcs',
      'category': 'Bakery',
      'imageUrl':
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Eggs',
      'price': 129.99,
      'quantity': 12,
      'unit': 'pcs',
      'category': 'Grocery',
      'imageUrl':
          'https://images.unsplash.com/photo-1506976785307-8732e854ad03?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Spinach',
      'price': 49.99,
      'quantity': 1,
      'unit': 'bunch',
      'category': 'Vegetables',
      'imageUrl':
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Strawberries',
      'price': 199.99,
      'quantity': 1,
      'unit': 'box',
      'category': 'Fruits',
      'imageUrl':
          'https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Bagels',
      'price': 89.99,
      'quantity': 6,
      'unit': 'pcs',
      'category': 'Bakery',
      'imageUrl':
          'https://images.unsplash.com/photo-1585478259715-876a6a81fc08?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Pasta',
      'price': 69.99,
      'quantity': 1,
      'unit': 'pack',
      'category': 'Grocery',
      'imageUrl': 'pasta.jpg',
    },
    {
      'name': 'Bell Peppers',
      'price': 79.99,
      'quantity': 3,
      'unit': 'pcs',
      'category': 'Vegetables',
      'imageUrl':
          'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Grapes',
      'price': 159.99,
      'quantity': 1,
      'unit': 'bunch',
      'category': 'Fruits',
      'imageUrl':
          'https://images.unsplash.com/photo-1423483641154-5411ec9c0ddf?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Cupcakes',
      'price': 99.99,
      'quantity': 4,
      'unit': 'pcs',
      'category': 'Bakery',
      'imageUrl':
          'https://images.unsplash.com/photo-1486427944299-d1955d23e34d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Cereal',
      'price': 119.99,
      'quantity': 1,
      'unit': 'box',
      'category': 'Grocery',
      'imageUrl':
          'https://images.unsplash.com/photo-1521483451569-e33803c0330c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Broccoli',
      'price': 89.99,
      'quantity': 1,
      'unit': 'head',
      'category': 'Vegetables',
      'imageUrl':
          'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Oranges',
      'price': 129.99,
      'quantity': 5,
      'unit': 'pcs',
      'category': 'Fruits',
      'imageUrl':
          'https://images.unsplash.com/photo-1547514701-42782101795e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Baguette',
      'price': 69.99,
      'quantity': 1,
      'unit': 'pc',
      'category': 'Bakery',
      'imageUrl':
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Yogurt',
      'price': 59.99,
      'quantity': 1,
      'unit': 'tub',
      'category': 'Grocery',
      'imageUrl': 'assets/yogurt.png',
    },
  ];

  WriteBatch batch = firestore.batch();

  // Add categories
  for (String category in categories) {
    DocumentReference categoryRef = firestore
        .collection('setup')
        .doc('categories')
        .collection('items')
        .doc();
    batch.set(categoryRef, {'name': category});
  }

  // Add products
  for (var product in products) {
    DocumentReference productRef =
        firestore.collection('setup').doc('products').collection('items').doc();
    batch.set(productRef, product);
  }

  // Mark setup as completed
  batch.set(firestore.collection('setup').doc('status'), {'completed': true});

  // Commit the batch
  await batch.commit();

  print('Initial setup completed successfully');
}
