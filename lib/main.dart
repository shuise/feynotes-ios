import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shuise\'s Notes',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ' 水色烧尾宴'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(
          children: [const Icon(Icons.photo_album), Text(widget.title)],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height - 140,
              child: FutureBuilder<List<dynamic>>(
                future: http.get(Uri.parse('https://notes.bluetech.top/api/article/published?t=1732179300991&account=shuise&topic=&current=1&size=25'))
                    .then((response) => jsonDecode(utf8.decode(response.bodyBytes))['data']['records']),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('加载失败'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final articles = snapshot.data!;
                  return ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ListTile(
                        leading: IconButton(
                          icon: Icon(article['isFavorite'] ?? false ? Icons.favorite : Icons.favorite_border),
                          onPressed: () {
                            setState(() {
                              // 切换收藏状态
                              article['isFavorite'] = !(article['isFavorite'] ?? false);
                            });
                          },
                        ),
                        title: InkWell(
                          onTap: () {
                            // 点击标题跳转到详情页面
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article)),
                            );
                          },
                          child: Text(article['title'] ?? '无标题'),
                        ),
                        subtitle: Text(article['publishedAt'] ?? ''),
                      );
                    },
                  );
                },
                
              ),
            ),
            BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '首页',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark),
                  label: '收藏',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '我的',
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key, required this.article});
  
  final Map<String, dynamic> article;

  @override
  Widget build(BuildContext context) {
    final notes = jsonDecode(article['extra'])['steps'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(article['title'] ?? '无标题'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: InkWell(
                child: Text(article['title'] ?? '', style: const TextStyle(fontSize: 20),),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: InkWell(
                onTap: () => _launchUrl(article['originUrl']),
                mouseCursor: SystemMouseCursors.click,
                child: Text(
                  article['originUrl'] ?? '', 
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: Text(
                article['publishedAt'] ?? '', 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, height: 3),
              ),
            ),
            SizedBox(
              height: 500,
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notes[index]['text'].toString() ?? ''),
                    subtitle: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(notes[index]['tip'].toString() ?? ''),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
