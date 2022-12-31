import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static Database? _database;

  static get getDatabase async {
    if (_database != null) {
      return _database;
    }

    _database = await initDatabase();

    return _database;
  }

  // initialize database
  static Future<Database> initDatabase() async {
    String path = p.join(await getDatabasesPath(), "notes_database.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    ); // onUpgrade: _onUpgrade
  }

  static Future _onCreate(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute(''' 
CREATE TABLE notes(id INTEGER PRIMARY KEY, 
title TEXT, 
content TEXT,
description TEXT NULL)
''');

    batch.execute('''
CREATE TABLE todos(id INTEGER PRIMARY KEY, 
title TEXT, 
value BOOL)
''');
    batch.commit();
    // ignore: avoid_print
    print("ON create was called . ....");
  }

//   // onupgrade
//   static Future<void> _onUpgrade(
//       Database db, int oldVersion, int newVersion) async {
//     // db.execute(
//     //     "ALTER TABLE notes ADD COLUMN description TEXT NOT NULL DEFAULT ''");
//     db.execute("ALTER TABLE notes ADD COLUMN description TEXT NULL");

//     db.execute('''
// CREATE TABLE todos(id INTEGER PRIMARY KEY,
// title TEXT,
// value BOOL)
// ''');
//     print("upgrade  the notes");
//   }

  //inset note

  static Future<void> insetNote(Note note) async {
    Database db = await getDatabase;
    await db.insert("notes", note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    // print(await db.query("notes"));
  }
  //inset todos

  static Future<void> insetTodo(Todo todo) async {
    Database db = await getDatabase;
    await db.insert("todos", todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(await db.query("todos"));
  }

  // retrive data notes
  static Future<List<Map>> loadNote() async {
    Database db = await getDatabase;
    List<Map> map = await db.query("notes");

    return List.generate(
        map.length,
        (i) => Note(
                id: map[i]["id"],
                title: map[i]["title"],
                content: map[i]["content"],
                description: map[i]["description"])
            .toMap());
  }

  // retrive data todos
  static Future<List<Map>> loadTodo() async {
    Database db = await getDatabase;
    List<Map> map = await db.query("todos");

    return List.generate(
        map.length,
        (i) => Todo(
              id: map[i]["id"],
              title: map[i]["title"],
              value: map[i]["value"],
            ).toMap());
  }

//update
  static Future<void> update(Note newNote) async {
    Database db = await getDatabase;

    await db.update("notes", newNote.toMap(),
        where: "id=?", whereArgs: [newNote.id]);
    // print(await db.query("notes"));
  }

//update todo
  static Future<void> updateTodo(Todo newTodo) async {
    Database db = await getDatabase;

    await db.update("todos", newTodo.toMap(),
        where: "id=?", whereArgs: [newTodo.id]);
    // print(await db.query("notes"));
  }

//update tododcheckbox
  static Future<void> updateTodoCheckBox(int id, int currentValue) async {
    Database db = await getDatabase;

    await db.update("todos", {"value": currentValue == 0 ? 1 : 0},
        where: "id=?", whereArgs: [id]);
    print(await db.query("todos"));
  }

  //delete
  static Future<void> delete(int id) async {
    Database db = await getDatabase;
    await db.delete("notes", where: "id = ?", whereArgs: [id]);
  }

  //delete
  static Future<void> deleteTodo(int id) async {
    Database db = await getDatabase;
    await db.delete("todos", where: "id = ?", whereArgs: [id]);
  }

  //delete all
  static Future<void> deleteAll() async {
    Database db = await getDatabase;
    await db.delete("notes");
  }

  //delete all
  static Future<void> deleteAllTodo() async {
    Database db = await getDatabase;
    await db.delete("todos");
  }
}

//class note model
class Note {
  final int? id;
  final String title;
  final String content;
  String? description;

  Note({this.id, required this.title, required this.content, this.description});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "description": description
    };
  }

  @override
  String toString() {
    return "Notes {id: $id, title : $title, content: $content , description: $description }";
  }
}

//class todo model
class Todo {
  final int? id;
  final String title;
  int value;

  Todo({this.id, required this.title, this.value = 0});

  Map<String, dynamic> toMap() {
    return {"id": id, "title": title, "value": value};
  }

  @override
  String toString() {
    return "Todo {id: $id, title : $title, value: $value }";
  }
}
