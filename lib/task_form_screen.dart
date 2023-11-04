import 'package:flutter/material.dart';
import 'package:flutter_frequency_list_screen_jalal/database_helper.dart';
import 'package:flutter_frequency_list_screen_jalal/main.dart';
import 'package:flutter_frequency_list_screen_jalal/task_list_screen.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  var _taskController = TextEditingController();
  var _selectedFrequencyValue;
  String selectedPriority = 'High';
  bool statusDefaultValue = false;
  var _frequencyDropdownList = <DropdownMenuItem>[];

  @override
  void initState() {
    super.initState();
    getAllFrequency();
  }

  getAllFrequency() async {
    var frequencies =
        await dbHelper.queryAllRows(DataBaseHelper.frequencyTable);

    frequencies.forEach((frequency) {
      setState(() {
        _frequencyDropdownList.add(DropdownMenuItem(
          child: Text(frequency['frequency']),
          value: frequency['frequency'],
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text('New Task Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Task',
                  hintText: 'Enter Task',
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButtonFormField(
                    value: _selectedFrequencyValue,
                    items: _frequencyDropdownList,
                    hint: Text('Frequency'),
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequencyValue = value;
                        print(_selectedFrequencyValue);
                      });
                    }),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Task Priorty',
                  style: TextStyle(fontSize: 20),
                ),
                RadioListTile(
                    title: Text(
                      'High',
                      style: TextStyle(fontSize: 18),
                    ),
                    value: 'High',
                    groupValue: selectedPriority,
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value as String;
                        print('--------> Task Priority:$value');
                      });
                    }),
                RadioListTile(
                    title: Text(
                      'Low',
                      style: TextStyle(fontSize: 18),
                    ),
                    value: 'Low',
                    groupValue: selectedPriority,
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value as String;
                        print('--------> Task Priority:$value');
                      });
                    }),
                SizedBox(
                  height: 40,
                ),
                Card(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Status',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Checkbox(
                          value: this.statusDefaultValue,
                          onChanged: (value) {
                            setState(() {
                              this.statusDefaultValue = value!;
                              print('-------> status checkBox:$value');
                            });
                          }),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  onPressed: () {
                    print('----> TaskForm: Save');
                    _save();
                  },
                  child: Text(
                    'save',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _save() async {
    String tempStatusValue = 'false';

    if (statusDefaultValue == true) {
      print('------>Save Status - true');
      tempStatusValue = 'true';
    } else {
      print('------>Save Status - false');
      tempStatusValue = 'false';
    }

    print('----------> Task: ${_taskController.text}');
    print('----------> Frequency: $_selectedFrequencyValue');
    print('----------> Priority: $selectedPriority');
    print('----------> Status: $tempStatusValue');

    Map<String, dynamic> row = {
      DataBaseHelper.columnTask: _taskController.text,
      DataBaseHelper.columnFrequency: _selectedFrequencyValue,
      DataBaseHelper.columnPriority: selectedPriority,
      DataBaseHelper.columnStatus: tempStatusValue,
    };

    final result = await dbHelper.insertData(row, DataBaseHelper.taskTable);

    debugPrint('-------> Inserted Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved');

      setState(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => TaskListScreen()));
      });
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
