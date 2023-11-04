

import 'package:flutter/material.dart';
import 'package:flutter_frequency_list_screen_jalal/database_helper.dart';
import 'package:flutter_frequency_list_screen_jalal/drawer_navigation.dart';
import 'package:flutter_frequency_list_screen_jalal/main.dart';
import 'package:flutter_frequency_list_screen_jalal/task_model.dart';

class TaskByFrequency extends StatefulWidget {
  String frequency;
  TaskByFrequency({Key? key,required this.frequency}):super(key: key);

  @override
  State<TaskByFrequency> createState() => _TaskByFrequencyState();
}

class _TaskByFrequencyState extends State<TaskByFrequency> {
  late List<TaskModel> _tasklist;

  @override
  void initState(){
    super.initState();
    getTaskByCategories();
  }

  getTaskByCategories() async{
    _tasklist =<TaskModel>[];

    print('-------> Received Frequency:');
    print(this.widget.frequency);

    var habits =await dbHelper.readDataByColumnName(
        DataBaseHelper.taskTable, DataBaseHelper.columnFrequency,this.widget.frequency);

    habits.forEach((task){
      setState(() {
        print(task['_id']);
        print(task['task']);
        print(task['frequency']);
        print(task['priority']);
        print(task['status']);

        var taskmodal =TaskModel(task['_id'],
            task['task'], task['frequency'], task['priority'], task['status']);
        _tasklist.add(taskmodal);

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task - Frequency List'),
      ),
      drawer: DrawerNavigation(),
      body: ListView.builder(
          itemCount: _tasklist.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    print(_tasklist[index].id);
                    print(_tasklist[index].task);
                    print(_tasklist[index].frequency);
                    print(_tasklist[index].priority);
                    print(_tasklist[index].status);
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_tasklist[index].task ?? 'No Data',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    _tasklist[index].frequency ?? 'No Data',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
