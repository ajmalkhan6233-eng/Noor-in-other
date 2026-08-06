import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/adhan_audio/logic/adhan_audio_cubit.dart';
import 'features/adhan_audio/logic/adhan_audio_state.dart';
import 'features/adhan_audio/data/adhan_reciter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(NoorApp(prefs: prefs));
}

class NoorApp extends StatelessWidget {
  final SharedPreferences prefs;
  const NoorApp({super.key, required this.prefs});
  @override
  Widget build(BuildContext c) {
    return BlocProvider(
      create: (_) { final cubit = AdhanAudioCubit(); cubit.initialize(prefs); return cubit; },
      child: MaterialApp(title: 'noor (نور)', debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0A0D14)),
        home: const PrayerScreen(),
      ),
    );
  }
}

class PrayerTime {
  final String name, nameAr, time, remaining;
  final bool isNext;
  const PrayerTime({required this.name, required this.nameAr, required this.time, required this.remaining, this.isNext = false});
}

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});
  static const prayers = [
    PrayerTime(name:'Fajr',nameAr:'الفجر',time:'4:35 AM',remaining:'in 2h 15m'),
    PrayerTime(name:'Dhuhr',nameAr:'الظهر',time:'12:15 PM',remaining:'in 9h 55m',isNext:true),
    PrayerTime(name:'Asr',nameAr:'العصر',time:'3:45 PM',remaining:'in 13h 25m'),
    PrayerTime(name:'Maghrib',nameAr:'المغرب',time:'6:30 PM',remaining:'in 16h 10m'),
    PrayerTime(name:'Isha',nameAr:'العشاء',time:'7:50 PM',remaining:'in 17h 30m'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      body: Stack(children: [
        const Positioned.fill(child: CosmicBg()),
        SafeArea(child: Column(children: [
          const _Header(),
          const SizedBox(height:12),
          _nextPrayer(),
          const SizedBox(height:16),
          Expanded(child: BlocBuilder<AdhanAudioCubit,AdhanAudioState>(builder:(ctx,st)=>ListView.builder(
            padding:const EdgeInsets.only(bottom:20),itemCount:prayers.length,
            itemBuilder:(_,i){final p=prayers[i];final playing=st is AdhanAudioPlaying&&st.activePrayer==p.name.toLowerCase();return _card(ctx,p,playing,st);},
          ))),
        ])),
      ]),
    );
  }

  Widget _nextPrayer() {
    const p = PrayerTime(name:'Dhuhr',nameAr:'الظهر',time:'12:15 PM',remaining:'in 9h 55m',isNext:true);
    return Semantics(label:'Next prayer: Dhuhr in 9h 55m',child:Container(
      margin:const EdgeInsets.symmetric(horizontal:20),padding:const EdgeInsets.symmetric(horizontal:20,vertical:16),
      decoration:BoxDecoration(color:const Color(0xFFB8912F).withOpacity(0.08),borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0xFFB8912F).withOpacity(0.2),width:0.8),boxShadow:[BoxShadow(color:const Color(0xFFB8912F).withOpacity(0.06),blurRadius:20,spreadRadius:2)]),
      child:Row(children:[
        Container(width:44,height:44,decoration:BoxDecoration(shape:BoxShape.circle,color:const Color(0xFFB8912F).withOpacity(0.2)),child:const Icon(Icons.access_time_rounded,color:Color(0xFFD4A843),size:22)),
        const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Next: Dhuhr',style:TextStyle(fontFamily:'Inter',fontSize:13,fontWeight:FontWeight.w500,color:Color(0x99F2EFE7))),
          const SizedBox(height:2),
          const Text('in 9h 55m',style:TextStyle(fontFamily:'Inter',fontSize:22,fontWeight:FontWeight.w300,color:Color(0xFFD4A843),letterSpacing:-0.5)),
        ])),
        const Text('12:15 PM',style:TextStyle(fontFamily:'Inter',fontSize:18,fontWeight:FontWeight.w500,color:Color(0xFFF2EFE7))),
      ]),
    ));
  }

  Widget _card(BuildContext ctx, PrayerTime p, bool playing, AdhanAudioState st) {
    final reciters = st is AdhanAudioReady ? st.reciters : <AdhanReciter>[];
    final reciterName = reciters.isNotEmpty ? reciters.first.name : null;
    return Semantics(label:'${p.name} prayer at ${p.time}${p.isNext?", next":""}',child:AnimatedContainer(
      duration:const Duration(milliseconds:400),curve:Curves.easeOutCubic,margin:const EdgeInsets.symmetric(horizontal:16,vertical:5),
      decoration:BoxDecoration(color:playing?const Color(0xFFB8912F).withOpacity(0.12):const Color(0x1AF2EFE7),borderRadius:BorderRadius.circular(18),border:Border.all(color:p.isNext||playing?const Color(0xFFB8912F).withOpacity(0.35):const Color(0x25B8912F),width:p.isNext?1.5:0.8),boxShadow:p.isNext||playing?[const BoxShadow(color:Color(0x30B8912F),blurRadius:16,spreadRadius:1)]:null),
      child:Padding(padding:const EdgeInsets.symmetric(horizontal:18,vertical:14),child:Row(children:[
        Expanded(flex:3,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[
            Text(p.name,style:TextStyle(fontFamily:'Inter',fontSize:16,fontWeight:FontWeight.w600,color:p.isNext?const Color(0xFFB8912F):const Color(0xFFF2EFE7),letterSpacing:0.3)),
            if(p.isNext)...[const SizedBox(width:8),Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),decoration:BoxDecoration(color:const Color(0xFFB8912F).withOpacity(0.2),borderRadius:BorderRadius.circular(6)),child:const Text('NEXT',style:TextStyle(fontFamily:'Inter',fontSize:9,fontWeight:FontWeight.w700,color:Color(0xFFD4A843),letterSpacing:1.0)))],
          ]),
          const SizedBox(height:2),Text(p.nameAr,style:const TextStyle(fontFamily:'Amiri',fontSize:14,color:Color(0x66F2EFE7))),
          const SizedBox(height:4),Text(p.remaining,style:TextStyle(fontFamily:'Inter',fontSize:11,color:p.isNext?const Color(0xFFB8912F).withOpacity(0.8):const Color(0x66F2EFE7))),
        ])),
        Expanded(flex:2,child:Text(p.time,textAlign:TextAlign.center,style:TextStyle(fontFamily:'Inter',fontSize:24,fontWeight:FontWeight.w300,color:p.isNext?const Color(0xFFD4A843):const Color(0xFFF2EFE7),letterSpacing:-0.5))),
        SizedBox(width:64,child:Row(mainAxisAlignment:MainAxisAlignment.end,children:[
          const Icon(Icons.notifications_rounded,size:20,color:Color(0xFF8B7324)),
          const SizedBox(width:10),
          if(reciterName!=null) GestureDetector(
            onTap:(){final c=ctx.read<AdhanAudioCubit>();if(c.state is AdhanAudioPlaying){c.resetToReady();}else{c.setActivePrayer(p.name.toLowerCase());}},
            child:AnimatedContainer(duration:const Duration(milliseconds:250),width:36,height:36,decoration:BoxDecoration(shape:BoxShape.circle,color:playing?const Color(0xFFB8912F).withOpacity(0.25):const Color(0xFFB8912F).withOpacity(0.08),border:Border.all(color:playing?const Color(0xFFD4A843).withOpacity(0.6):const Color(0xFFB8912F).withOpacity(0.25),width:1.2),boxShadow:playing?[const BoxShadow(color:Color(0x30B8912F),blurRadius:10,spreadRadius:2)]:null),child:Icon(playing?Icons.pause_rounded:Icons.play_arrow_rounded,size:18,color:playing?const Color(0xFFD4A843):const Color(0xFF8B7324))),
          ),
        ])),
      ])),
    ));
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override Widget build(BuildContext c) => Padding(padding:const EdgeInsets.fromLTRB(20,8,20,0),child:Column(children:[
    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
      const Row(children:[Icon(Icons.location_on_outlined,size:14,color:Color(0x99F2EFE7)),SizedBox(width:4),Text('Colombo, Sri Lanka',style:TextStyle(fontFamily:'Inter',fontSize:13,color:Color(0x99F2EFE7)))]),
      GestureDetector(onTap:(){},child:Container(width:36,height:36,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white.withOpacity(0.05),border:Border.all(color:Colors.white.withOpacity(0.08))),child:const Icon(Icons.settings_outlined,size:18,color:Color(0x99F2EFE7)))),
    ]),
    const SizedBox(height:16),
    Semantics(label:'Allah',excludeSemantics:true,child:SizedBox(height:56,child:Center(child:Stack(alignment:Alignment.center,children:[
      Text('الله',style:TextStyle(fontFamily:'Amiri',fontSize:44,fontWeight:FontWeight.bold,foreground:Paint()..color=Colors.black.withOpacity(0.5)..maskFilter:const MaskFilter.blur(BlurStyle.normal,4))),
      Transform.translate(offset:const Offset(-1.5,-1.5),child:Text('الله',style:TextStyle(fontFamily:'Amiri',fontSize:44,fontWeight:FontWeight.bold,foreground:Paint()..color=Colors.white.withOpacity(0.35)..maskFilter:const MaskFilter.blur(BlurStyle.normal,2)))),
      const Text('الله',style:TextStyle(fontFamily:'Amiri',fontSize:44,fontWeight:FontWeight.bold,color:Color(0xFFB8912F))),
    ])))),
    const SizedBox(height:4),const Text('15 Muharram 1448',style:TextStyle(fontFamily:'Inter',fontSize:12,color:Color(0x66F2EFE7))),
  ]));
}

// ---- Cosmic background (CustomPainter, animated) ----
class CosmicBg extends StatefulWidget {
  const CosmicBg({super.key});
  @override State<CosmicBg> createState()=>_CosmicBgState();
}
class _CosmicBgState extends State<CosmicBg> with TickerProviderStateMixin {
  late final _c=AnimationController(vsync:this,duration:const Duration(seconds:8))..repeat();
  late final _s=AnimationController(vsync:this,duration:const Duration(seconds:20))..repeat();
  @override void dispose(){_c.dispose();_s.dispose();super.dispose();}
  @override Widget build(BuildContext c)=>AnimatedBuilder(animation:Listenable.merge([_c,_s]),builder:(_,__)=>CustomPaint(painter:_CP(t:_c.value,s:_s.value),size:Size.infinite));
}
class _CP extends CustomPainter {
  final double t,s;
  _CP({required this.t,required this.s});
  static const g=Color(0xFFB8912F),gb=Color(0xFFD4A843),tl=Color(0xFF0D9488),tlb=Color(0xFF2DD4BF),bl=Color(0xFF3B82F6),or=Color(0xFFF59E0B);
  @override void paint(Canvas c,Size sz) {
    c.drawRect(Rect.fromLTWH(0,0,sz.width,sz.height),Paint()..shader=RadialGradient(center:const Alignment(0.35,0.4),radius:1.3,colors:const[Color(0xFF121624),Color(0xFF0A0D14),Color(0xFF060810)],stops:const[0.0,0.6,1.0]).createShader(Rect.fromLTWH(0,0,sz.width,sz.height)));
    _wv(c,sz,sz.height*0.04,2.3,1.0,sz.height*0.15,g.withOpacity(0.3),g.withOpacity(0.08),2.5);
    _wv(c,sz,sz.height*0.035,1.7,0.7,sz.height*0.35,tl.withOpacity(0.25),tl.withOpacity(0.06),2.0);
    _wv(c,sz,sz.height*0.03,2.8,0.5,sz.height*0.65,bl.withOpacity(0.2),bl.withOpacity(0.05),1.5);
    _pt(c,sz);_sp(c,sz);
    c.drawRect(Rect.fromLTWH(0,0,sz.width,sz.height),Paint()..shader=RadialGradient(center:Alignment.center,radius:0.85,colors:const[Color(0x00000000),Color(0x40000000)]).createShader(Rect.fromLTWH(0,0,sz.width,sz.height)));
  }
  void _wv(Canvas c,Size sz,double a,double f,double sp,double y,Color cl,Color gl,double sw) {
    final p=Path();final pts=<Offset>[];
    for(int i=0;i<=120;i++){double x=sz.width*i/120,ph=t*math.pi*2*sp;pts.add(Offset(x,y+math.sin(x/sz.width*math.pi*f+ph)*a+math.sin(x/sz.width*math.pi*1.3+ph*0.6)*a*0.4));}
    if(pts.isNotEmpty){p.moveTo(pts.first.dx,pts.first.dy);for(int i=1;i<pts.length;i++){var p0=pts[i-1],p1=pts[i];p.quadraticBezierTo((p0.dx+p1.dx)/2,p1.dy-a*0.15,p1.dx,p1.dy);}}
    c.drawPath(p,Paint()..style=PaintingStyle.stroke..strokeWidth=sw+6..color=gl..maskFilter=const MaskFilter.blur(BlurStyle.normal,12));
    c.drawPath(p,Paint()..style=PaintingStyle.stroke..strokeWidth=sw..color=cl..maskFilter=const MaskFilter.blur(BlurStyle.normal,3));
  }
  void _pt(Canvas c,Size sz) {
    final r=math.Random(42);
    for(int i=0;i<80;i++) {
      double bx=r.nextDouble()*sz.width,by=r.nextDouble()*sz.height,rr=15+r.nextDouble()*80,rs=0.3+r.nextDouble()*0.7,ph=r.nextDouble()*math.pi*2,ss=1+r.nextDouble()*3.5,op=0.1+r.nextDouble()*0.5;
      Color pc;double ny=by/sz.height;
      if(ny<0.35)pc=r.nextDouble()<0.7?g:or;else if(ny<0.65)pc=r.nextDouble()<0.6?tl:g;else pc=r.nextDouble()<0.7?bl:tl;
      double x=bx+math.cos(t*rs*math.pi*2+ph)*rr,y=by+math.sin(t*rs*math.pi*2+ph)*rr*0.6;
      c.drawCircle(Offset(x,y),ss*3,Paint()..color=pc.withOpacity(op*0.2)..maskFilter=const MaskFilter.blur(BlurStyle.normal,4));
      c.drawCircle(Offset(x,y),ss,Paint()..color=pc.withOpacity(op));
    }
  }
  void _sp(Canvas c,Size sz) {
    final r=math.Random(137);
    for(int i=0;i<15;i++) {
      double x=r.nextDouble()*sz.width,y=r.nextDouble()*sz.height,ph=r.nextDouble()*math.pi*2,sp=0.5+r.nextDouble()*2,br=(math.sin(t*sp*math.pi*2+ph)+1)/2,op=br*(0.4+r.nextDouble()*0.6);
      if(op<0.15)continue;
      Color cl=r.nextDouble()<0.4?gb:tlb;double ss=2+r.nextDouble()*4;Offset o=Offset(x,y);
      c.drawCircle(o,ss*2.5,Paint()..color=cl.withOpacity(op*0.3)..maskFilter=const MaskFilter.blur(BlurStyle.normal,6));
      c.drawLine(Offset(x-ss,y),Offset(x+ss,y),Paint()..color=cl.withOpacity(op*0.8)..strokeWidth=0.8);
      c.drawLine(Offset(x,y-ss),Offset(x,y+ss),Paint()..color=cl.withOpacity(op*0.8)..strokeWidth=0.8);
    }
  }
  @override bool shouldRepaint(_CP o)=>t!=o.t||s!=o.s;
}