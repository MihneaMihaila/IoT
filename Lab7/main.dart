import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/product.dart';
import 'package:flutter_app/sign_in.dart';
import 'package:flutter_app/userModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My shopping list',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
        primaryColor: Colors.yellow,
      ),
      home: SignInPage(),//MyHomePage(title: 'My shopping list'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  final UserModel user;



  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  MyHomePage({Key key, this.user, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(user);
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final TextEditingController ProductNameController = TextEditingController();
  final TextEditingController ProductPriceController = TextEditingController();
  final TextEditingController ProductQuantityController = TextEditingController();
  List<Product> shoppingCart = [];
  List<Product> favorites = [];


  SearchBar searchBar;

  final UserModel user;

  bool _initialized = false;
  bool _error = false;


  Future getDocs() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection("products").getDocuments();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      print(a.id + " "+ a.get("name") + " " + a.get("price") + " " + a.get("quantity"));
      setState(() {
        shoppingCart.add(Product(name: a.get("name"),
            price: a.get("price"),
            quantity: a.get("quantity")));
        updateMainBody();
      });
    }

    querySnapshot = await Firestore.instance.collection("favorites").getDocuments();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      print(a.id + " "+ a.get("name") + " " + a.get("price") + " " + a.get("quantity"));
      setState(() {
        favorites.add(Product(name: a.get("name"),
            price: a.get("price"),
            quantity: a.get("quantity")));
        updateMainBody();
      });
    }

  }

  void initializeFlutterFire() async{
    try{
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    }catch(e){
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState(){
    initializeFlutterFire();
    getDocs();
    super.initState();
  }


  int currentIndex = 0;
  List<Widget> mainPageWidgets = [];

  Widget mainPageBody;


  _MyHomePageState(this.user){

    updateMainBody();
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        onSubmitted: onSearchBarSubmitted,
        buildDefaultAppBar: buildAppBar,


    );
  }

  void onSearchBarSubmitted(String value) {
    print(value);
    for(int i=0;i<shoppingCart.length;i++){
      if(shoppingCart[i].name==value){

        showDialog(context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Product Details", textAlign: TextAlign.center,),
                content: Container(
                  height: 300,
                  child: Column(
                    children: <Widget>[
                      Text("Id : " +i.toString()),
                      Text("Name : " +shoppingCart[i].name),
                      Text("Price : " + shoppingCart[i].price),
                      Text("Quantity : " + shoppingCart[i].quantity),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed:(){
                        Navigator.of(context).pop();
                      },
                      child: Text("Save")
                  ),
                ],
              );
            });
        return;
      }
    }

    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Product Details", textAlign: TextAlign.center,),
            content: Container(
              height: 300,
              child: Column(
                children: <Widget>[

                  Text("No items found"),

                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed:(){
                    Navigator.of(context).pop();
                  },
                  child: Text("Save")
              ),
            ],
          );
        });


  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('My Shopping List'),
        actions: [searchBar.getSearchAction(context)]
    );
  }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  @override
  Widget build(BuildContext context) {


    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: searchBar.build(context),
      body: mainPageBody,
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> displayDialog(context),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Favorites'),
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
      updateMainBody();

    });
  }

  void updateMainBody(){
    if(currentIndex==0){
      mainPageBody = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(15)),
              Row(
                children: [
                  Image.asset(
                    "assets/MEANING.png.jpg",
                    width: 150,
                    height: 150,),
                  Text("Products you have to buy")
                ],
              ),
              Expanded(
                  child: ListView.builder(itemCount: shoppingCart.length,
                      itemBuilder: (context,index){
                        return Dismissible(
                          key: Key(shoppingCart[index].name+DateFormat('yyyy-MM-dd – kk:mm::ss').format(DateTime.now())),
                          onDismissed: (DismissDirection direction) {
                            if(direction == DismissDirection.startToEnd){
                              setState(() {
                                favorites.add(shoppingCart[index]);
                                Product.saveFavorite(shoppingCart[index]);
                                shoppingCart.removeAt(index);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text("Product " + shoppingCart[index].name +" saved to favorites")));
                                updateMainBody();
                              });
                            }
                            if(direction == DismissDirection.endToStart){
                              setState(() {
                                Product.deleteProduct(shoppingCart[index]);
                                shoppingCart.removeAt(index);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text("Product " + shoppingCart[index].name +" deleted")));
                                updateMainBody();
                              });
                            }
                          },
                          // Show a red background as the item is swiped away.
                          background: Container(color: Colors.red),
                          child: ShoppingListItem(
                            product: shoppingCart[index],
                            inCart:shoppingCart.contains(shoppingCart[index]),
                            onCartChanged: onCartChanged,
                          ),
                        );
                      })
              )

            ],
          )
      );
    }else if(currentIndex==1){
      mainPageBody = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(15)),
              Row(
                children: [
                  Image.asset(
                    "assets/MEANING.png.jpg",
                    width: 150,
                    height: 150,),
                  Text("Favorites")
                ],
              ),
              Row(
                children: [

                ],
              ),
              Expanded(
                  child: ListView.builder(itemCount: favorites.length,
                      itemBuilder: (context,index){
                        return Dismissible(
                          key: Key(favorites[index].name+DateFormat('yyyy-MM-dd – kk:mm::ss').format(DateTime.now())),
                          onDismissed: (DismissDirection direction) {
                            if(direction == DismissDirection.startToEnd){
                              setState(() {
                                Product.deleteFavorite(favorites[index]);
                                favorites.removeAt(index);
                                favorites.removeAt(index);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text("Product " + favorites[index].name +" saved to favorites")));
                                updateMainBody();
                              });
                            }
                          },
                          // Show a red background as the item is swiped away.
                          background: Container(color: Colors.red),
                          child: ShoppingListItem(
                            product: favorites[index],
                            inCart:favorites.contains(favorites[index]),
                            onCartChanged: onCartChanged,
                          ),
                        );
                      })
              )

            ],
          )
      );
    }
  }

  Future <AlertDialog> displayDialog(BuildContext context){
    return showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Add a new product to your list", textAlign: TextAlign.center,),
            content: Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                        hintText: "Product Name"
                    ),
                    controller: ProductNameController,
                  ),
                  TextField(
                    decoration: InputDecoration(
                        hintText: "Product Price"
                    ),
                    controller: ProductPriceController,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Product Quantity"
                    ),
                    controller: ProductQuantityController,
                  ),
                ],
              )
            ),
            actions: [
              TextButton(
                  onPressed:(){
                    Navigator.of(context).pop();
                    if(ProductNameController.text.trim()!="" && ProductPriceController.text.trim()!="" && ProductQuantityController.text.trim()!="")
                    setState(() {
                      shoppingCart.add(Product(name: ProductNameController.text, price: ProductPriceController.text, quantity: ProductQuantityController.text));
                      Product.saveProduct(Product(name: ProductNameController.text, price: ProductPriceController.text, quantity: ProductQuantityController.text));
                      print(ProductNameController.text);
                      print(shoppingCart);
                      updateMainBody();
                    });
                  },
                  child: Text("Save")
              ),
              TextButton(
                  onPressed:(){
                    Navigator.of(context).pop();
                  },
                  child: Text("Close")
              )
            ],
          );
        });

  }

  void onCartChanged(Product product, bool inCart){
    setState(() {
      //if(!inCart)
      shoppingCart.remove(product);
      updateMainBody();
    });
  }

}
