import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uas_ambw_c14210048/enterpin.dart';

class MyNotes extends StatefulWidget {
  const MyNotes({super.key});

  @override
  State<MyNotes> createState() => _MyNotesState();
}

class _MyNotesState extends State<MyNotes> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  late Box notesBox;

  @override
  void initState() {
    super.initState();
    notesBox = Hive.box('notes');

    print('notes awal: ${notesBox.values}');
  }

  void _addOrEditNote({int? index}) {
    if (index != null) {
      _titleController.text = notesBox.getAt(index)['title'];
      _contentController.text = notesBox.getAt(index)['content'];
    } else {
      _titleController.clear();
      _contentController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(index == null ? 'Add Note' : 'Edit Note'),
              if (index != null)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteNote(index);
                  },
                ),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.isEmpty) {
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Title note tidak boleh kosong.'),
                    ),
                  );
                  return;
                }

                if (_contentController.text.isEmpty) {
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Content note tidak boleh kosong.'),
                    ),
                  );
                  return;
                }

                final newNote = {
                  'title': _titleController.text,
                  'content': _contentController.text,
                  'createdAt': index == null
                      ? DateTime.now().toString()
                      : notesBox.getAt(index)['createdAt'],
                  'updatedAt': DateTime.now().toString(),
                };
                if (index == null) {
                  notesBox.add(newNote);
                } else {
                  notesBox.putAt(index, newNote);
                }
                setState(() {});
                Navigator.of(context).pop();
                print('notes setelah add edit: ${notesBox.values}');
              },
              child: Text(index == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Apakah anda yakin akan menghapus note ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                notesBox.deleteAt(index);
                setState(() {});
                print('notes setelah di delete: ${notesBox.values}');
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Apakah anda akan logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterPin(),
                  ),
                );
                print('User logged out');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: notesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text('Tidak ada notes.'),
            );
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 4,
              ),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final note = box.getAt(index);
                return GestureDetector(
                  onTap: () => _addOrEditNote(index: index),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              note['content'],
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 7,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Created: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.parse(note['createdAt']))}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Updated: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.parse(note['updatedAt']))}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        child: Icon(Icons.add),
      ),
    );
  }
}
