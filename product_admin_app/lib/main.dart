import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:image_picker/image_picker.dart'; // Image Picker
import 'dart:io'; // File handling
import 'package:firebase_core/firebase_core.dart';
import 'product_form.dart'; // Đảm bảo import file ProductForm
import 'login.dart' as login; // Sử dụng alias cho login.dart
import 'product_list.dart' as productList; // Sử dụng alias cho product_list.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Admin App',
      initialRoute: '/login', // Start with the login page
      routes: {
        '/': (context) => productList.ProductList(), // Sử dụng alias để chỉ định rõ class ProductList
        '/add-product': (context) => ProductForm(),
        '/login': (context) => login.LoginProductForm(), // Sử dụng alias cho LoginProductForm
      },
    );
  }
}

class LoginProductForm extends StatefulWidget {
  @override
  _LoginProductFormState createState() => _LoginProductFormState();
}

class _LoginProductFormState extends State<LoginProductForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/'); // Navigate to product list after login
    } catch (e) {
      print(e); // Handle error
      // Thêm thông báo lỗi cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// Phần ProductList không thay đổi
class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text(doc['category']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductForm(
                              productId: doc.id,
                              productName: doc['name'],
                              productCategory: doc['category'],
                              productPrice: doc['price'],
                              imageUrl: doc['image_url'],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(doc.id)
                            .delete();
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/add-product');
        },
      ),
    );
  }
}

// Hàm để chọn ảnh và tải lên
Future<void> _pickImageAndUpload(BuildContext context) async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    File imageFile = File(image.path);
    // Gọi hàm tải ảnh lên Firebase Storage ở đây
    await _uploadImage(imageFile, context);
  }
}

// Hàm tải ảnh lên Firebase Storage
Future<void> _uploadImage(File imageFile, BuildContext context) async {
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.png');

    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();
    print('Image URL: $url'); // Hiển thị URL của ảnh
    // Hiện thông báo cho người dùng về việc tải lên thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image uploaded successfully: $url')),
    );
  } catch (error) {
    print('Error uploading image: $error');
    // Hiện thông báo lỗi cho người dùng
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading image: $error')),
    );
  }
}
