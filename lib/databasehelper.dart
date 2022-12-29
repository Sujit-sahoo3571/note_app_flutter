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
    return await openDatabase(path,
        version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute(''' 
CREATE TABLE notes(id INTEGER PRIMARY KEY, 
title TEXT, 
content TEXT)
''');

    // ignore: avoid_print
    print("ON create was called . ....");
  }

  // onupgrade
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // db.execute(
    //     "ALTER TABLE notes ADD COLUMN description TEXT NOT NULL DEFAULT ''");
    db.execute("ALTER TABLE notes ADD COLUMN description TEXT NULL");

    db.execute('''
CREATE TABLE todos(id INTEGER PRIMARY KEY, 
title TEXT, 
value BOOL)
''');
    print("upgrade  the notes");
  }

  //inset note

  static Future<void> insetNote(Note note) async {
    Database db = await getDatabase;
    await db.insert("notes", note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    // print(await db.query("notes"));
  }

  // retrive data
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

//update
  static Future<void> update(Note newNote) async {
    Database db = await getDatabase;

    await db.update("notes", newNote.toMap(),
        where: "id=?", whereArgs: [newNote.id]);
    // print(await db.query("notes"));
  }

  //delete
  static Future<void> delete(int id) async {
    Database db = await getDatabase;
    await db.delete("notes", where: "id = ?", whereArgs: [id]);
  }

  //delete all
  static Future<void> deleteAll() async {
    Database db = await getDatabase;
    await db.delete("notes");
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
