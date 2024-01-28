import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firstrun/jettscreen.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  int current = 0;

  var status = '';

  var images1 =
      'https://www.dailynews.co.th/wp-content/uploads/2022/05/w644-3.jpg';

  var defaultImage =
      'https://www.dailynews.co.th/wp-content/uploads/2022/05/w644-3.jpg';

  var images2 =
      'https://www.khaosod.co.th/wpapp/uploads/2018/08/39408866_474041449748516_5009054150680379392_n-1.jpg';

  // ignore: unused_element

  void _resetCounter() {
    setState(() {
      current = 0;
      status = '';
      defaultImage =
          'https://www.dailynews.co.th/wp-content/uploads/2022/05/w644-3.jpg';
    });
  }

  Future<void> fetchData() async {
    final url =
        Uri.parse('https://aurora-api.netforce.co.th/api/v1/get_gold_price/');
    final headers = {
      'X-Aurora-Authorization': 'tzWugBo7hpbkf3SA7DME8XVkBJdWSPzh8wHahUyWZ1E=',
      // เพิ่ม Header ต่าง ๆ ตามต้องการ
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      current = data.entries.first.value['261'];

      if (current % 2 == 0) {
        status = 'Normal';
      } else {
        status = 'False';
      }

      // ignore: avoid_print
      print(data);
    } else {
      // ignore: avoid_print
      print('Failed to load data, status code: ${response.statusCode}');
    }

    // ignore: avoid_print
    print(current);
    // ignore: avoid_print
    print(status);

    if (status == 'Normal') {
      defaultImage =
          'https://www.khaosod.co.th/wpapp/uploads/2023/08/num-kanchai.jpg';
    } else {
      defaultImage =
          'https://s.isanook.com/ns/0/ud/311/1555419/news07-1.jpg?ip/crop/w670h402/q80/jpg';
    }
  }

  void _incrementCounter() {
    setState(() {
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),

      // ignore: avoid_unnecessary_containers
      body: Container(
        // ignore: avoid_unnecessary_containers
        child: Container(
          child: Column(
            children: [
              Text(
                'GOLD PRICE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // ignore: avoid_unnecessary_containers
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(
                      defaultImage,
                      width: 500,
                      height: 500,
                    ),
                  ),
                ],
              )),
              // ignore: avoid_unnecessary_containers
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: _incrementCounter,
                    child: Text('Get Gold Price'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: _resetCounter,
                    child: Text('Reset'),
                  ),
                ],
              )),
              Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ' $current!',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' $status!',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Jettscreen()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add)),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

@immutable
class CustomNetworkImage extends ImageProvider<Uri> {
  const CustomNetworkImage(this.url);

  final String url;

  @override
  Future<Uri> obtainKey(ImageConfiguration configuration) {
    final Uri result = Uri.parse(url).replace(
      queryParameters: <String, String>{
        'dpr': '${configuration.devicePixelRatio}',
        'locale': '${configuration.locale?.toLanguageTag()}',
        'platform': '${configuration.platform?.name}',
        'width': '${configuration.size?.width}',
        'height': '${configuration.size?.height}',
        'bidi': '${configuration.textDirection?.name}',
      },
    );
    return SynchronousFuture<Uri>(result);
  }

  static HttpClient get _httpClient {
    HttpClient? client;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) {
        client = debugNetworkImageHttpClientProvider!();
      }
      return true;
    }());
    return client ?? HttpClient()
      ..autoUncompress = false;
  }

  @override
  ImageStreamCompleter loadImage(Uri key, ImageDecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();
    debugPrint('Fetching "$key"...');
    return MultiFrameImageStreamCompleter(
      codec: _httpClient
          .getUrl(key)
          .then<HttpClientResponse>(
              (HttpClientRequest request) => request.close())
          .then<Uint8List>((HttpClientResponse response) {
            return consolidateHttpClientResponseBytes(
              response,
              onBytesReceived: (int cumulative, int? total) {
                chunkEvents.add(ImageChunkEvent(
                  cumulativeBytesLoaded: cumulative,
                  expectedTotalBytes: total,
                ));
              },
            );
          })
          .catchError((Object e, StackTrace stack) {
            scheduleMicrotask(() {
              PaintingBinding.instance.imageCache.evict(key);
            });
            return Future<Uint8List>.error(e, stack);
          })
          .whenComplete(chunkEvents.close)
          .then<ui.ImmutableBuffer>(ui.ImmutableBuffer.fromUint8List)
          .then<ui.Codec>(decode),
      chunkEvents: chunkEvents.stream,
      scale: 1.0,
      debugLabel: '"key"',
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<Uri>('URL', key),
      ],
    );
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CustomNetworkImage')}("$url")';
}

class DataTableExample extends StatelessWidget {
  const DataTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Expanded(
            child: Text(
              'Name',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Age',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Role',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
      rows: const <DataRow>[
        DataRow(
          cells: <DataCell>[
            DataCell(Text('Sarah')),
            DataCell(Text('19')),
            DataCell(Text('Student')),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            DataCell(Text('Janine')),
            DataCell(Text('43')),
            DataCell(Text('Professor')),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            DataCell(Text('William')),
            DataCell(Text('27')),
            DataCell(Text('Associate Professor')),
          ],
        ),
      ],
    );
  }
}
