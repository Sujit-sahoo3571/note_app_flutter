import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app_flutter/databasehelper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper.getDatabase;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Todorey Pro'),
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
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  final textstyle = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w400, color: Colors.white);

  String newTitle = "";
  String newContent = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                DatabaseHelper.deleteAllTodo();
                DatabaseHelper.deleteAll().whenComplete(() => setState(() {}));
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.yellow,
                size: 30.0,
              )),
          const SizedBox(
            width: 10.0,
          )
        ],
      ),
      body: Column(
        children: [
          //note listview
          Expanded(
            child: FutureBuilder(
                future: DatabaseHelper.loadNote(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var note = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) =>
                                    DatabaseHelper.delete(note["id"])
                                        .whenComplete(() => setState(() {})),
                                child: Card(
                                  elevation: 11.0,
                                  color: Colors.green,
                                  margin: const EdgeInsets.all(5.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Text("Id : ${note["id"]} ",
                                            //     style: textstyle),
                                            Text("Title : ${note["title"]} ",
                                                style: textstyle),
                                            IconButton(
                                                onPressed: () {
                                                  showDialogForEditNote(
                                                      context,
                                                      note["id"],
                                                      note["title"],
                                                      note["content"]);
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 35.0,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                        // Text("Title : ${note["title"]} ",
                                        //     style: textstyle),
                                        Text("Content : ${note["content"]} ",
                                            style: textstyle),
                                        Text(
                                            "Time :  ${DateFormat("EEE, dd-MMM-yyyy hh:mm a ").format(DateTime.now())}",
                                            // ${note["description"]} ",
                                            style: textstyle),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return const Center(
                        child: Text(
                          "Write New Notes ",
                          style: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
                        ),
                      );
                    }
                  }
                  return const Center(
                    child: Text(
                      "Write New Notes ",
                      style: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
                    ),
                  );
                }),
          ),
          // todos listview

          Expanded(
            child: FutureBuilder(
                future: DatabaseHelper.loadTodo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var todo = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) =>
                                    DatabaseHelper.deleteTodo(todo["id"])
                                        .whenComplete(() => setState(() {})),
                                child: Card(
                                    elevation: 11.0,
                                    color: Colors.orange,
                                    margin: const EdgeInsets.all(5.0),
                                    child: ListTile(
                                      onTap: () {
                                        // DatabaseHelper.updateTodo(newTodo)
                                        showDialogForEditTodo(
                                            context, todo["id"], todo["title"]);
                                      },
                                      //update check value
                                      leading: Checkbox(
                                          value:
                                              todo["value"] == 1 ? true : false,
                                          onChanged: (bool? value) {
                                            DatabaseHelper.updateTodoCheckBox(
                                                    todo["id"], todo["value"])
                                                .whenComplete(
                                                    () => setState(() {}));
                                          }),
                                      title: Text(
                                        todo["title"],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            decoration: todo["value"] == 1
                                                ? TextDecoration.lineThrough
                                                : null),
                                      ),
                                    )),
                              ),
                            );
                          });
                    } else {
                      return const Center(
                        child: Text(
                          "Write New Todos ",
                          style: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
                        ),
                      );
                    }
                  }
                  return const Center(
                    child: Text(
                      "Write New Todos ",
                      style: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //add notes
          FloatingActionButton(
            key: UniqueKey(),
            onPressed: () {
              showDialogForNewNote(context);
            },
            tooltip: 'Add Notes',
            child: const Icon(Icons.add),
          ),
          // add todos
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              key: UniqueKey(),
              onPressed: () {
                showDialogForNewTodo(context);
              },
              tooltip: 'Add Todos',
              child: const Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ),
    );
  }

// create new note
  Future<dynamic> showDialogForNewNote(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Notes"),
              content: SizedBox(
                height: 200.0,
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                    ),
                    TextField(
                      controller: contentController,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No")),
                TextButton(
                    onPressed: () {
                      DatabaseHelper.insetNote(Note(
                              title: titleController.text,
                              content: contentController.text,
                              description:
                                  DateFormat("EEE, dd-MMM-yyyy hh:mm a ")
                                      .format(DateTime.now())))
                          .whenComplete(() => setState(() {}));
                      titleController.clear();
                      contentController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"))
              ],
            ));
  }

// create new todos
  Future<dynamic> showDialogForNewTodo(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Todo"),
              content: SizedBox(
                height: 200.0,
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No")),
                TextButton(
                    onPressed: () {
                      DatabaseHelper.insetTodo(Todo(
                        title: titleController.text,
                      )).whenComplete(() => setState(() {}));
                      titleController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"))
              ],
            ));
  }

// edit the note
  Future<dynamic> showDialogForEditNote(
      BuildContext context, int id, String initTitle, String initContent) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Edit Notes"),
              content: SizedBox(
                height: 200.0,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: initTitle,
                      // controller: titleController, //cause null error
                      onChanged: (value) {
                        newTitle = value;
                      },
                    ),
                    TextFormField(
                      initialValue: initContent,
                      // controller: contentController,
                      onChanged: (value) {
                        newContent = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No")),
                TextButton(
                    onPressed: () {
                      DatabaseHelper.update(Note(
                        id: id,
                        content: newContent == "" ? initContent : newContent,
                        title: newTitle == "" ? initTitle : newTitle,
                        description: DateTime.now().toIso8601String(),
                      )).whenComplete(() => setState(() {}));

                      titleController.clear();
                      contentController.clear();
                      newContent = "";
                      newTitle = "";
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"))
              ],
            ));
  }

// edit the todo
  Future<dynamic> showDialogForEditTodo(
      BuildContext context, int id, String initTitle) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Edit Todo"),
              content: SizedBox(
                height: 200.0,
                child: TextFormField(
                  initialValue: initTitle,
                  // controller: titleController, //cause null error
                  onChanged: (value) {
                    newTitle = value;
                  },
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No")),
                TextButton(
                    onPressed: () {
                      DatabaseHelper.updateTodo(Todo(
                        id: id,
                        title: newTitle == "" ? initTitle : newTitle,
                      )).whenComplete(() => setState(() {}));

                      titleController.clear();
                      newTitle = "";
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"))
              ],
            ));
  }
}
