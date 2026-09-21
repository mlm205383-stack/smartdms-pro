import 'package:flutter/material.dart';
void main() => runApp(SmartDMSApp());
class SmartDMSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'SmartDMS PRO', theme: ThemeData(primarySwatch: Colors.blue), home: LoginScreen());
  }
}
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final u = TextEditingController(text: 'admin');
  final p = TextEditingController(text: 'admin');
  String err='';
  void login(){
    if(u.text=='admin' && p.text=='admin'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MainScreen()));
    } else { setState(()=>err='خطأ في الدخول'); }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(body: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inventory_2, size:80, color:Colors.blue), SizedBox(height:20), Text('SmartDMS PRO', style:TextStyle(fontSize:28, fontWeight:FontWeight.bold)), SizedBox(height:30), TextField(controller:u, decoration:InputDecoration(labelText:'المستخدم', border:OutlineInputBorder())), SizedBox(height:16), TextField(controller:p, obscureText:true, decoration:InputDecoration(labelText:'كلمة المرور', border:OutlineInputBorder())), SizedBox(height:16), if(err.isNotEmpty) Text(err, style:TextStyle(color:Colors.red)), SizedBox(height:20), SizedBox(width:double.infinity, child:ElevatedButton(onPressed:login, child:Text('دخول')))])));
  }
}
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int currentIndex=0;
  final pages=['الرئيسية','المبيعات','المشتريات','المخزون','العملاء','التقارير','الاعدادات'];
  final icons=[Icons.dashboard, Icons.point_of_sale, Icons.shopping_cart, Icons.warehouse, Icons.people, Icons.bar_chart, Icons.settings];
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(pages[currentIndex])),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(decoration: BoxDecoration(color: Colors.blue), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.person, color:Colors.white, size:50), SizedBox(height:8), Text('admin', style:TextStyle(color:Colors.white, fontSize:18)), Text('المدير العام', style:TextStyle(color:Colors.white70))])),
         ...List.generate(pages.length, (i) => ListTile(
            leading: Icon(icons[i]),
            title: Text(pages[i]),
            selected: currentIndex==i,
            onTap: () {
              Navigator.pop(context);
              setState(()=>currentIndex=i);
            },
          )),
          Divider(),
          ListTile(leading: Icon(Icons.logout, color:Colors.red), title: Text('خروج', style:TextStyle(color:Colors.red)), onTap: (){
            Navigator.pop(context);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
          }),
        ]),
      ),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icons[currentIndex], size:100, color:Colors.blue.shade200), SizedBox(height:20), Text(pages[currentIndex], style:TextStyle(fontSize:32, fontWeight:FontWeight.bold)), SizedBox(height:10), Text('تم اصلاح الجمود', style:TextStyle(color:Colors.green, fontSize:16))])),
    );
  }
}
