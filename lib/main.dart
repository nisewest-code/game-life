import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Game Life'),
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
  final int _row = 30;
  late List<List<bool>> _list;
  List<List<bool>>? _prevList;
  bool _play = false;
  Timer? timer;

  @override
  void initState() {
    _list = List.generate(_row, (i) => List.filled(_row, false),
        growable: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            Table(
              border: TableBorder.all(),
              children: [
                for (var row in _list)
                  TableRow(children: [
                    for (var i = 0; i < row.length; i++)
                      SizedBox(
                          width: 20,
                          height: 20,
                          child: GestureDetector(
                            child: Container(
                              color: row[i] ? Colors.grey : Colors.white,
                            ),
                            onTap: () {
                              setState(() {
                                row[i] = !row[i];
                              });
                            },
                          ))
                  ])
              ],
            ),
            Container(
                margin: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.small(
                      onPressed: () async {
                        setState(() {
                          _play = !_play;

                          if (_play) {
                            timer = Timer.periodic(const Duration(milliseconds: 500),
                                (timer) {
                              if (run()) {
                                timer.cancel();
                                setState((){
                                  _play = false;
                                });
                              }
                            });
                          } else {
                            timer?.cancel();
                          }
                        });
                      },
                      child: Icon(_play ? Icons.stop : Icons.play_arrow),
                    ),
                    FloatingActionButton.small(onPressed: (){
                      setState((){
                        _play = false;
                        timer?.cancel();
                        _list = List.generate(_row, (index) => List.filled(_row, false));
                      });
                    },
                        child: const Icon(Icons.replay))
                  ],
                ))
          ],
        ));
  }

  bool run() {
    // rowIndex-1 and columnIndex
    // rowIndex+1 and columnIndex
    // rowIndex and columnIndex-1
    // rowIndex and columnIndex+1
    //rowIndex-1 and columnIndex-1
    //rowIndex-1 and columnIndex+1
    //rowIndex+1 and columnIndex-1
    //rowIndex+1 and columnIndex+1
    List<List<bool>> copyList = _list.map((e) => e.map((e1) => e1).toList()).toList();
    for (int i = 0; i < _list.length; i++) {
      for (int j = 0; j < _list[i].length; j++) {
        int countAliveNeight = 0;
        // Проверка соседей
        for (int neightI = -1; neightI < 2; neightI++) {
          for (int neightJ = -1; neightJ < 2; neightJ++) {
            // Отбрасываем текущую клетку
            if (neightI == 0 && neightJ == 0) {
              continue;
            }
            int newIndexI = i + neightI;
            int newIndexJ = j + neightJ;
            
            // Проверка на выход за пределы сетки
            if (newIndexI < 0 ||
                newIndexJ < 0 ||
                newIndexI > _list.length - 1 ||
                newIndexJ > _list[i].length - 1) {
              continue;
            }
            if (_list[newIndexI][newIndexJ]) {
              countAliveNeight++;
            }
          }
        }
        if (_list[i][j]) {
          setState(() {
            copyList[i][j] = countAliveNeight == 2 || countAliveNeight == 3;
          });
        } else {
          setState(() {
            copyList[i][j] = countAliveNeight == 3;
          });
        }
      }
    }

    // Проверяем содержит ли сетки живые клетки
    bool isLive = copyList.where((element){
      return element.contains(true);
    }).isNotEmpty;

    // Проверяем изменилась ли сетка
    bool isAlike = const DeepCollectionEquality().equals(_list, copyList);

    // Проверяем равна ли текушая сетка предыдущей
    bool isPrev = _prevList != null && const DeepCollectionEquality().equals(_prevList, copyList);

    _prevList = copyList.map((e) => e.map((e1) => e1).toList()).toList();
    setState((){
      _list = copyList;
    });

    return isLive || isAlike || isPrev;
  }
}
