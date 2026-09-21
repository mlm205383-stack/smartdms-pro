import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

void main() {
  runApp(const SmartDMSApp());
}

class SmartDMSApp extends StatelessWidget {
  const SmartDMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartDMS Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> docs = [
    {
      "title": "ملف تجريبي 1",
      "category": "إداري",
      "smart_name": "وثيقة-001",
      "file_path": null
    },
    {
      "title": "تقرير المبيعات",
      "category": "مالي",
      "smart_name": "تقرير-2024",
      "file_path": null
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredDocs = docs.where((d) {
      final title = d["title"].toString().toLowerCase();
      final cat = d["category"].toString().toLowerCase();
      return title.contains(searchQuery.toLowerCase()) ||
          cat.contains(searchQuery.toLowerCase());
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الأرشيف الذكي Pro"),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "بحث...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    searchQuery = v;
                  });
                },
              ),
            ),
            Expanded(
              child: filteredDocs.isEmpty
                 ? const Center(child: Text("لا توجد ملفات"))
                  : ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final d = filteredDocs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.picture_as_pdf,
                                color: Colors.red),
                            title: Text(d["title"]?? "بدون عنوان"),
                            subtitle: Text(
                                "${d["category"]?? ""} - ${d["smart_name"]?? ""}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () {
                                if (d["file_path"]!= null) {
                                  OpenFilex.open(d["file_path"]);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("المسار غير متوفر")),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
