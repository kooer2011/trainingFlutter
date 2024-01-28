import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Jettscreen extends StatelessWidget {
  const Jettscreen({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jett'),
      ),
      
      

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      )
     
    );
  
  }
}