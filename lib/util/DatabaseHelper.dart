import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

import '../models/note.dart';

class DatabaseHelper {
  static  late DatabaseHelper _databaseHelper;
 static late Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';
  DatabaseHelper._createInstance();
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();

    String path = '${directory.path}notes.db';
    var notesDatabase = openDatabase(path, version: 1, onCreate: _createDb);

    return notesDatabase;
  }

  void _createDb(Database db, int newversion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMary KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER, $colDate TEXT )');
  }



 Future<List<Map<String,dynamic>>> getNoteMapList() async{
    Database db=await database;
 //   var result=await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');

  var result1=await db.query(noteTable,orderBy:'$colPriority ASC' );

  return result1;
  }


  Future<int> insertNote(Note note) async{
    Database db=await database;
    var result=db.insert(noteTable, note.toMap());
    return result;
  }


 Future<int> updateNote(Note note) async{
    Database db=await database;
    var result=db.update(noteTable, note.toMap(),where:'$colId=?',whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async{
    Database db=await database;
    var result=db.rawDelete('DELETE FROM $noteTable WHERE $colId=$id');
    return result;
  }


Future<int?> getCount() async {

  Database db=await database;

  List<Map<String,dynamic>> x=await db.rawQuery('SELECT COUNT (*) from $noteTable');
  int? result=Sqflite.firstIntValue(x);
  return result;

}

Future<List<Note>> getNoteList() async {

		var noteMapList = await getNoteMapList(); // Get 'Map List' from database
		int count = noteMapList.length;         // Count the number of map entries in db table

		List<Note> noteList = <Note>[];
		// For loop to create a 'Note List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			noteList.add(Note.fromMapObject(noteMapList[i]));
		}

		return noteList;
	}


}
