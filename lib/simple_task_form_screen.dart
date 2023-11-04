import 'package:flutter/material.dart';
import 'package:flutter_frequency_list_screen_jalal/database_helper.dart';
import 'package:flutter_frequency_list_screen_jalal/main.dart';
import 'package:flutter_frequency_list_screen_jalal/task_list_screen.dart';
import 'package:flutter_frequency_list_screen_jalal/task_model.dart';

class EditTaskFormScreen extends StatefulWidget {
  const EditTaskFormScreen({super.key});

  @override
  State<EditTaskFormScreen> createState() => _EditTaskFormScreenState();
}

class _EditTaskFormScreenState extends State<EditTaskFormScreen> {
  var _taskController = TextEditingController();
  var _selectedFrequencyValue;
  String selectedPriority = 'High';
  bool statusDefaultValue = false;
  var _frequencyDropdownList = <DropdownMenuItem>[];

  // Edit only
  bool firstTimeFlag = false;
  int _selectedId = 0;
  String buttonText = 'Save';

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
    if (firstTimeFlag == false) {
      print('----> once execute');

      firstTimeFlag = true;

      final task = ModalRoute.of(context)!.settings.arguments;

      if(task == null){
        print('------> FAB: Insert'); // Save
      }else{
        print('------> ListView clicked: Received Data: Edit/Delete');
        task as TaskModel;


      print('--------> Received Data');
      print(task.id);
      print(task.task);
      print(task.priority);
      print(task.status);


      _selectedId = task.id!;
      _taskController.text = task.task;
      _selectedFrequencyValue = task.frequency;
      buttonText = 'Update';

      //Radio button - Priority
      if (task.priority == 'High') {
        selectedPriority = 'High';
      } else {
        selectedPriority = 'Low';
      }

      //check box - Status
      if (task.status == 'true') {
        statusDefaultValue = true;
      } else {
        statusDefaultValue = false;
      }
    }}


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text('New Task Details'),
        actions:_selectedId != 0 ? [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(value:1,
                  child:Text('Delete')
              ),
            ],
            elevation: 2,
            onSelected: (value){
              if(value ==1){
                _deleteFormDialog(context);
              }
            },
          ),
        ]:null,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(fontSize: 20),
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
                ),
                SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  onPressed: () {
                    if(_selectedId == 0){
                      print('-----> Save');
                      _save();
                    }else {
                      print('----> update');
                      _update();
                    }
                    },
                  child: Text(
                    'Update',
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

  _save() async{
    String tempStatusValue ='false';

    if(statusDefaultValue == true){
      print('----> Save Status - true');
      tempStatusValue ='true';
    }else{
      print('-----> Save Status - flase');
      tempStatusValue ='false';
    }
    print('----------> Task: $_selectedId');
    print('----------> Task: ${_taskController.text}');
    print('----------> Frequency: $_selectedFrequencyValue');
    print('----------> Priority: $selectedPriority');
    print('----------> Status: $tempStatusValue');

    Map<String, dynamic> row = {
      DataBaseHelper.columnId: _selectedId,
      DataBaseHelper.columnTask: _taskController.text,
      DataBaseHelper.columnFrequency: _selectedFrequencyValue,
      DataBaseHelper.columnPriority: selectedPriority,
      DataBaseHelper.columnStatus: tempStatusValue,
    };
    final result = await dbHelper.insertData(row, DataBaseHelper.taskTable);

    debugPrint('------> Inserted Row Id: $result');

    if(result > 0){
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved');

      setState(() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => TaskListScreen()));
      });
    }
  }

  _update() async {
    String tempStatusValue = 'false';

    if (statusDefaultValue == true) {
      print('------>Save Status - true');
      tempStatusValue = 'true';
    } else {
      print('------>Save Status - false');
      tempStatusValue = 'false';
    }

    print('----------> Task: $_selectedId');
    print('----------> Task: ${_taskController.text}');
    print('----------> Frequency: $_selectedFrequencyValue');
    print('----------> Priority: $selectedPriority');
    print('----------> Status: $tempStatusValue');

    Map<String, dynamic> row = {
      DataBaseHelper.columnId: _selectedId,
      DataBaseHelper.columnTask: _taskController.text,
      DataBaseHelper.columnFrequency: _selectedFrequencyValue,
      DataBaseHelper.columnPriority: selectedPriority,
      DataBaseHelper.columnStatus: tempStatusValue,
    };

    final result = await dbHelper.insertData(row, DataBaseHelper.taskTable);

    debugPrint('-------> Inserted Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated');

      setState(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => TaskListScreen()));
      });
    }
  }
  _deleteFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await dbHelper.deleteData(
                      _selectedId, DataBaseHelper.taskTable);

                  debugPrint('-------> Deleted Row Id: $result');

                  if (result > 0) {
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Deleted');

                    setState(() {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => TaskListScreen()));
                    });
                  }
                },
                child: Text('Delete'),
              ),
            ],
            title: Text('Are you sure, you want to delete this?'),
          );
        });
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
