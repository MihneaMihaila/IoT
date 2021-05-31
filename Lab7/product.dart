import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Product{
  final String name;
  final String price;
  final String quantity;
  const Product({@required this.name, @required this.price, @required this.quantity});

  static void saveProduct(Product prod) async{

    return await FirebaseFirestore.instance.collection("products").add(
        {
          "name" : prod.name,
          "price" : prod.price,
          "quantity" : prod.quantity,
        }).then((value){
          print(value.id);
        });
  }

  static void saveFavorite(Product prod) async{

    return await FirebaseFirestore.instance.collection("favorites").add(
        {
          "name" : prod.name,
          "price" : prod.price,
          "quantity" : prod.quantity,
        }).then((value){
      print(value.id);
      deleteProduct(prod);
    });
  }

  static void deleteProduct(Product prod) async{

    FirebaseFirestore.instance
        .collection("products")
        .where("name", isEqualTo : prod.name)
        .get().then((value){
        value.docs.forEach((element) {
          FirebaseFirestore.instance.collection("products").doc(element.id).delete().then((value){
            print("Success!");
          });
      });
    });
  }

  static void deleteFavorite(Product prod) async{

    FirebaseFirestore.instance
        .collection("favorites")
        .where("name", isEqualTo : prod.name)
        .get().then((value){
      value.docs.forEach((element) {
        FirebaseFirestore.instance.collection("favorites").doc(element.id).delete().then((value){
          print("Success!");
        });
      });
    });
  }

}

typedef void CartChangedCallback(Product product, bool inCart);

class ShoppingListItem extends StatelessWidget{
  final Product product;
  final inCart;
  final CartChangedCallback onCartChanged;

  const ShoppingListItem({
    @required this.product,
    @required this.inCart,
    @required this.onCartChanged
  });

  @override
  Widget build(BuildContext context){
    return ListTile(
      title: Text(product.name),
      leading: CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text(product.name[0]),
      ),
      onTap: (){
        return showDialog(context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Product Details", textAlign: TextAlign.center,),
                content: Container(
                  height: 300,
                  child: Column(
                    children: <Widget>[
                      Text("Name : " + this.product.name),
                      Text("Price : " + this.product.price),
                      Text("Quantity : " + this.product.quantity),
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
      },
    );
  }


}