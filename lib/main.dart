import 'package:flutter/material.dart';

void main() {
  runApp(SmartDMSApp());
}

class SmartDMSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('ar'),
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF5F7FB),
        primaryColor: Color(0xFF0D47A1),
        fontFamily: 'Tajawal',
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.archive, size: 80, color: Color(0xFF0D47A1)),
                SizedBox(height: 16),
                Text('برنامج الارشفة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                Text('SmartDMS PRO'),
                SizedBox(height: 32),
                TextField(controller: userCtrl, decoration: InputDecoration(labelText: 'اسم المستخدم', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
                SizedBox(height: 16),
                TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0D47A1)),
                    onPressed: () {
                      if(userCtrl.text=='admin' && passCtrl.text=='admin'){
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>Dashboard()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الدخول')));
                      }
                    },
                    child: Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('لوحة التحكم - SmartDMS PRO'), backgroundColor: Color(0xFF0D47A1), foregroundColor: Colors.white),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(child: Text('أرشيف المستندات\nأحمد العلي\nمسؤول النظام'), decoration: BoxDecoration(color: Color(0xFFF5F7FB))),
              ListTile(title: Text('لوحة التحكم'), leading: Icon(Icons.dashboard), selected: true, selectedTileColor: Colors.blue.shade100),
              ListTile(title: Text('المستندات'), leading: Icon(Icons.description)),
              ListTile(title: Text('الأرشيف'), leading: Icon(Icons.inventory)),
              ListTile(title: Text('التصنيفات'), leading: Icon(Icons.folder)),
              ListTile(title: Text('المستخدمون'), leading: Icon(Icons.people)),
              ListTile(title: Text('الرفع'), leading: Icon(Icons.cloud_upload)),
              ListTile(title: Text('البحث'), leading: Icon(Icons.search)),
              ListTile(title: Text('التقارير'), leading: Icon(Icons.bar_chart)),
              ListTile(title: Text('الإعدادات'), leading: Icon(Icons.settings)),
              ListTile(title: Text('سلة المحذوفات'), leading: Icon(Icons.delete)),
              ListTile(title: Text('تسجيل الخروج'), leading: Icon(Icons.logout, color: Colors.red), textColor: Colors.red),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _statCard('إجمالي المستندات', '1,248', Icons.description, Colors.blue)),
                  SizedBox(width: 8),
                  Expanded(child: _statCard('قيد المراجعة', '18', Icons.hourglass_empty, Colors.orange)),
                  SizedBox(width: 8),
                  Expanded(child: _statCard('المستندات اليوم', '32', Icons.calendar_today, Colors.orangeAccent)),
                  SizedBox(width: 8),
                  Expanded(child: _statCard('مساحة التخزين', '68.5GB/100GB', Icons.storage, Colors.teal)),
                ],
              ),
              SizedBox(height: 16),
              Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue)), child: Row(children: [Icon(Icons.folder), SizedBox(width: 8), Expanded(child: Text('مسار التخزين: /storage/emulated/0/SmartDMS_PRO/2024/', overflow: TextOverflow.ellipsis)), ElevatedButton(onPressed: (){}, child: Text('تغيير المسار'))])),
              SizedBox(height: 16),
              Expanded(child: Row(children: [
                Expanded(flex: 2, child: Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('آخر المستندات المضافة', style: TextStyle(fontWeight: FontWeight.bold)), Divider(), Expanded(child: ListView(children: [ListTile(title: Text('عقد توريد 2024 - شركة النور'), subtitle: Text('2024-11-22 - موافق عليه')), ListTile(title: Text('فاتورة نوفمبر - مزود الخدمات.pdf'), subtitle: Text('2024-11-21 - قيد المراجعة')), ListTile(title: Text('تقرير المبيعات الشهري.pdf'), subtitle: Text('2024-11-20 - مؤرشف'))]))])))),
                SizedBox(width: 12),
                Expanded(child: Card(child: Padding(padding: EdgeInsets.all(12), child: Column(children: [Text('توزيع أنواع المستندات', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 20), Icon(Icons.pie_chart, size: 100, color: Colors.blue), SizedBox(height: 12), Text('عقود 40% - 499 مستند\nفواتير 25% - 312 مستند\nتقارير 20% - 250 مستند')] )))),
              ]))
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color){
    return Card(child: Padding(padding: EdgeInsets.all(12), child: Column(children: [CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), SizedBox(height: 8), Text(title, style: TextStyle(fontSize: 12), textAlign: TextAlign.center), SizedBox(height: 4), Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)) ])));
  }
}
