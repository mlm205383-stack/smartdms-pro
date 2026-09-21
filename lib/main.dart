
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// ================= CORE SYSTEMS =================
class AuthManager {
  static String hashPass(String pass) => sha256.convert(utf8.encode(pass)).toString();
  static Future<bool> login(String user, String pass) async {
    final db = await DatabaseHelper.instance.db;
    final hashed = hashPass(pass);
    final res = await db.query('users', where: 'username=? AND password_hash=?', whereArgs: [user, hashed]);
    return res.isNotEmpty;
  }
}

class StorageManager {
  static const _key = 'custom_root';
  static Future<String> getRoot() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_key)?? '/storage/emulated/0/SmartDMS_PRO/';
  }
  static Future<void> setRoot(String path) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, path);
  }
}

class FingerprintEngine {
  static String getFingerprint(File f) {
    final bytes = f.readAsBytesSync();
    if (bytes.length < 8) return 'UNKNOWN';
    if (bytes[0]==0x25 && bytes[1]==0x50 && bytes[2]==0x44 && bytes[3]==0x46) return 'PDF';
    if (bytes[0]==0xFF && bytes[1]==0xD8) return 'JPEG';
    if (bytes[0]==0x89 && bytes[1]==0x50) return 'PNG';
    if (bytes[0]==0x50 && bytes[1]==0x4B) return 'DOCX';
    return 'BIN';
  }
}

class ClassificationEngine {
  static Map<String,String> classify(String fileName, String fingerprint) {
    final lower = fileName.toLowerCase();
    if (lower.contains('فاتورة') || lower.contains('invoice')) return {'cat':'مالية','type':'فاتورة'};
    if (lower.contains('عقد') || lower.contains('contract')) return {'cat':'قانونية','type':'عقد'};
    if (lower.contains('تقرير') || lower.contains('report')) return {'cat':'ادارية','type':'تقرير'};
    if (fingerprint=='PDF') return {'cat':'عامة','type':'مستند'};
    return {'cat':'عامة','type':'ملف'};
  }
}

class SmartNamer {
  static String generate(String category, String type, String desc, int id, String ext) {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cleanDesc = desc.replaceAll(' ', '_').substring(0, desc.length>15?15:desc.length);
    return '${date}_${category}_${type}_${cleanDesc}_${id.toString().padLeft(3,'0')}.$ext';
  }
}
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();
  Database? _db;
  Future<Database> get db async {
    if (_db!=null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(p.join(dir,'smartdms.db'), version:1, onCreate: (db,v) async {
      await db.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password_hash TEXT, role TEXT, full_name TEXT)');
      await db.execute('CREATE TABLE documents(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, category TEXT, type TEXT, description TEXT, file_path TEXT, fingerprint TEXT, created_at TEXT, smart_name TEXT)');
      await db.execute("INSERT INTO users(username,password_hash,role,full_name) VALUES('admin','${AuthManager.hashPass('admin')}','super_admin','أحمد العلي')");
    });
    return _db!;
  }
  Future<List<Map<String,dynamic>>> getDocs() async {
    final d = await db;
    return d.query('documents', orderBy:'id DESC');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartDMSApp());
}

class SmartDMSApp extends StatelessWidget {
  const SmartDMSApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title:'SmartDMS PRO V1.0',
      theme: ThemeData(useMaterial3:true, scaffoldBackgroundColor: const Color(0xFFF5F7FB)),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{
  final u=TextEditingController(text:'admin');
  final pC=TextEditingController(text:'admin');
  bool loading=false;
  void _doLogin() async {
    setState(()=>loading=true);
    final ok = await AuthManager.login(u.text.trim(), pC.text.trim());
    setState(()=>loading=false);
    if(ok){
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const MainShell()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الدخول')));
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors:[Color(0xFF0D47A1),Color(0xFF1976D2)], begin:Alignment.topCenter, end:Alignment.bottomCenter)),
        child: Center(child: Card(margin: const EdgeInsets.all(24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children:[
          const Icon(Icons.archive, size:64, color:Color(0xFF0D47A1)),
          const SizedBox(height:12),
          const Text('SmartDMS PRO V1.0', style:TextStyle(fontSize:22, fontWeight:FontWeight.bold)),
          const Text('برنامج الارشفة الذكي', style:TextStyle(color:Colors.grey)),
          const SizedBox(height:24),
          TextField(controller:u, decoration: const InputDecoration(labelText:'اسم المستخدم', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
          const SizedBox(height:12),
          TextField(controller:pC, obscureText:true, decoration: const InputDecoration(labelText:'كلمة المرور', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
          const SizedBox(height:20),
          SizedBox(width: double.infinity, height:48, child: ElevatedButton(onPressed: loading?null:_doLogin, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)), child: loading? const CircularProgressIndicator(color:Colors.white): const Text('دخول', style:TextStyle(color:Colors.white)))),
          const SizedBox(height:12),
          const Text('admin / admin', style:TextStyle(fontSize:12, color:Colors.grey))
        ])))),
      ),
    );
  }
}
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState()=>_MainShellState();
}
class _MainShellState extends State<MainShell>{
  int idx=0;
  final screens=[
    const DashboardScreen(),
    const DocumentsScreen(),
    const AttachmentsScreen(),
    const ImportScreen(),
    const SearchScreen(),
    const PreviewScreen(),
    const TransferScreen(),
    const StatsScreen(),
    const FingerprintsScreen(),
    const UsersScreen(),
    const SettingsScreen(),
  ];
  final menu=[
    {'t':'الرئيسية','i':Icons.dashboard,'c':Color(0xFF0D47A1)},
    {'t':'المستندات','i':Icons.folder,'c':Color(0xFF2E7D32)},
    {'t':'المرفقات','i':Icons.attach_file,'c':Color(0xFF6A1B9A)},
    {'t':'الاستيراد','i':Icons.cloud_upload,'c':Color(0xFFEF6C00)},
    {'t':'البحث','i':Icons.search,'c':Color(0xFF00838F)},
    {'t':'المعاينة','i':Icons.preview,'c':Color(0xFF4E342E)},
    {'t':'النقل','i':Icons.drive_file_move,'c':Color(0xFF37474F)},
    {'t':'الاحصائيات','i':Icons.bar_chart,'c':Color(0xFFC2185B)},
    {'t':'البصمات','i':Icons.fingerprint,'c':Color(0xFF4527A0)},
    {'t':'المستخدمين','i':Icons.people,'c':Color(0xFF00695C)},
    {'t':'الاعدادات','i':Icons.settings,'c':Color(0xFF424242)},
  ];
  @override
  Widget build(BuildContext context){
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(backgroundColor: menu[idx]['c'] as Color, title: Text(menu[idx]['t'] as String, style: const TextStyle(color:Colors.white)), iconTheme: const IconThemeData(color:Colors.white)),
      drawer: Drawer(width:300, child: Column(children:[
        Container(width:double.infinity, padding: const EdgeInsets.fromLTRB(16,60,16,16), decoration: const BoxDecoration(gradient: LinearGradient(colors:[Color(0xFF0D47A1),Color(0xFF1976D2)])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          CircleAvatar(radius:32, backgroundColor:Colors.white, child: Icon(Icons.person, size:40, color:Color(0xFF0D47A1))),
          SizedBox(height:12),
          Text('أحمد العلي', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
          Text('مسؤول النظام - Super Admin', style:TextStyle(color:Colors.white70)),
        ])),
        Expanded(child: ListView.builder(itemCount: menu.length, itemBuilder: (c,i){
          final sel=idx==i;
          return Container(margin: const EdgeInsets.symmetric(horizontal:8, vertical:2), decoration: BoxDecoration(color: sel?(menu[i]['c'] as Color).withOpacity(0.12):null, borderRadius: BorderRadius.circular(8)), child: ListTile(
            leading: Icon(menu[i]['i'] as IconData, color: sel?menu[i]['c'] as Color:Colors.grey[700]),
            title: Text(menu[i]['t'] as String, style: TextStyle(fontWeight: sel?FontWeight.bold:null, color: sel?menu[i]['c'] as Color:null)),
            selected: sel,
            onTap:(){ Navigator.pop(context); setState(()=>idx=i); },
          ));
        })),
        const Divider(),
        ListTile(leading: const Icon(Icons.logout, color:Colors.red), title: const Text('تسجيل خروج', style:TextStyle(color:Colors.red)), onTap:()=>Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const LoginScreen()))),
        const SizedBox(height:12),
      ])),
      body: screens[idx],
    ));
  }
}
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override Widget build(BuildContext context){
    return GridView.count(crossAxisCount:2, padding: const EdgeInsets.all(16), children:[
      _card('125','مستند',Icons.description,Colors.blue),
      _card('342','مرفق',Icons.attach_file,Colors.green),
      _card('12','مستخدم',Icons.people,Colors.orange),
      _card('1.2GB','التخزين',Icons.storage,Colors.purple),
    ]);
  }
  Widget _card(String n,String t,IconData i,Color c){
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children:[Icon(i, color:c, size:40), const SizedBox(height:8), Text(n, style: const TextStyle(fontSize:22, fontWeight:FontWeight.bold)), Text(t)])));
  }
}

class DocumentsScreen extends StatefulWidget { const DocumentsScreen({super.key}); @override State<DocumentsScreen> createState()=>_DocState(); }
class _DocState extends State<DocumentsScreen>{
  List<Map<String,dynamic>> docs=[];
  @override void initState(){ super.initState(); _load(); }
  void _load() async { docs = await DatabaseHelper.instance.getDocs(); setState((){}); }
  @override Widget build(BuildContext context){
    return docs.isEmpty? const Center(child: Text('لا توجد مستندات بعد')): ListView.builder(itemCount: docs.length, itemBuilder:(c,i){
      final d=docs[i];
      return Card(margin: const EdgeInsets.symmetric(horizontal:12, vertical:6), child: ListTile(leading: const Icon(Icons.picture_as_pdf, color:Colors.red), title: Text(d['title']??'بدون عنوان'), subtitle: Text('${d['category']??''} - ${d['smart_name']??''}'), trailing: IconButton(icon: const Icon(Icons.open_in_new), onPressed:(){ if(d['file_path']!=null) OpenFilex.open(d['file_path']); }))));
    });
  }
}

class AttachmentsScreen extends StatelessWidget { const AttachmentsScreen({super.key}); @override Widget build(BuildContext context){ return const Center(child: Text('المرفقات - سيتم عرض المرفقات هنا')); } }

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});
  @override Widget build(BuildContext context){
    return Center(child: ElevatedButton.icon(onPressed:() async {
      final res=await FilePicker.platform.pickFiles();
      if(res!=null){
        final f=File(res.files.single.path!);
        final fp=FingerprintEngine.getFingerprint(f);
        final cls=ClassificationEngine.classify(res.files.single.name, fp);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الاستيراد: $fp - ${cls['cat']}')));
      }
    }, icon: const Icon(Icons.upload), label: const Text('اختر ملفات للاستيراد')));
  }
}

class SearchScreen extends StatelessWidget { const SearchScreen({super.key}); @override Widget build(BuildContext context){ return const Padding(padding: EdgeInsets.all(16), child: Column(children:[TextField(decoration: InputDecoration(labelText:'بحث في المستندات', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())), SizedBox(height:20), Text('نتائج البحث ستظهر هنا')])); } }
class PreviewScreen extends StatelessWidget { const PreviewScreen({super.key}); @override Widget build(BuildContext context){ return const Center(child: Text('المعاينة - معاينة الملفات')); } }
class TransferScreen extends StatelessWidget { const TransferScreen({super.key}); @override Widget build(BuildContext context){ return const Center(child: Text('النقل - نقل الملفات بين المجلدات')); } }
class StatsScreen extends StatelessWidget { const StatsScreen({super.key}); @override Widget build(BuildContext context){ return const Center(child: Text('الاحصائيات - احصائيات الاستخدام')); } }
class FingerprintsScreen extends StatelessWidget { const FingerprintsScreen({super.key}); @override Widget build(BuildContext context){ return const Center(child: Text('البصمات - 8 بايت للكشف عن نوع الملف')); } }
class UsersScreen extends StatelessWidget { const UsersScreen({super.key}); @override Widget build(BuildContext context){ return ListView(children: const [ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('أحمد العلي'), subtitle: Text('Super Admin - admin')), ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('موظف الارشيف'), subtitle: Text('Archivist'))]); } }

class SettingsScreen extends StatefulWidget { const SettingsScreen({super.key}); @override State<SettingsScreen> createState()=>_SetState(); }
class _SetState extends State<SettingsScreen>{
  String root='/storage/emulated/0/SmartDMS_PRO/';
  @override void initState(){ super.initState(); _load(); }
  void _load() async { root=await StorageManager.getRoot(); setState((){}); }
  @override Widget build(BuildContext context){
    return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      const Text('الاعدادات', style:TextStyle(fontSize:20, fontWeight:FontWeight.bold)),
      const SizedBox(height:16),
      Card(child: ListTile(title: const Text('مسار التخزين'), subtitle: Text(root), trailing: const Icon(Icons.folder), onTap:() async { String? sel=await FilePicker.platform.getDirectoryPath(); if(sel!=null){ await StorageManager.setRoot(sel); setState(()=>root=sel); }})),
      const SizedBox(height:12),
      const Card(child: ListTile(title: Text('اصدار التطبيق'), subtitle: Text('SmartDMS PRO V1.0 - حسب تصميمك'), leading: Icon(Icons.info))),
    ]));
  }
}
