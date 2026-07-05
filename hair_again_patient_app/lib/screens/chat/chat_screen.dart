import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/app_data_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  final _msgs = <_Msg>[
    _Msg('Hello! Welcome to Hair Again support 👋\nHow can I help you today?', false, _fmtNow()),
  ];

  static const _quickReplies = [
    'My next appointment',
    'Reschedule appointment',
    'Treatment information',
    'Payment issue',
    'Loyalty points',
  ];

  static String _fmtNow() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m ${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _getResponse(String input) {
    final text = input.toLowerCase();
    final next = appData.nextAppointment;

    if (text.contains('next appointment') || text.contains('upcoming')) {
      if (next == null) return 'You have no upcoming appointments right now. Tap "Book" on the Home screen to schedule one — our team is ready!';
      return 'Your next appointment:\n\n🗓 ${next.title}\n👨‍⚕️ ${next.doctor}\n📅 ${next.dateStr}\n⏰ ${next.slot}\n\nStatus: ${next.status}\n\nWould you like to reschedule or need anything else?';
    }

    if (text.contains('reschedule') || text.contains('change') || text.contains('move')) {
      if (next == null) return 'You don\'t have any upcoming appointments to reschedule. Would you like to book a new one?';
      return 'To reschedule your ${next.title} on ${next.shortDate}, go to Appointments → tap Reschedule on the booking. Alternatively, I can pass your request to our scheduling team — just let me know your preferred new date and time!';
    }

    if (text.contains('cancel')) {
      return 'To cancel an appointment, go to the Appointments tab → tap Cancel on the relevant booking.\n\nPlease note: cancellations within 24 hours may incur a Rs 500 cancellation fee as per our policy. Is there a specific appointment you\'d like to cancel?';
    }

    if (text.contains('payment') || text.contains('bill') || text.contains('invoice') || text.contains('receipt')) {
      return 'For payment-related queries:\n\n• View invoices: Profile → Payment History\n• Billing team: billing@hairagain.pk\n• Phone: +92-21-XXXX-XXXX\n\nWe accept credit/debit cards, bank transfer, JazzCash and EasyPaisa. Is there a specific payment issue I can help with?';
    }

    if (text.contains('transplant') || text.contains('fue') || text.contains('fut')) {
      return 'Our FUE Hair Transplant:\n\n• Individual follicle extraction — natural results\n• Procedure duration: 6–8 hours\n• Recovery: 7–10 days\n• From Rs 80,000 (depending on graft count)\n• 95%+ graft survival rate\n\nWe recommend a consultation first to assess your donor area and suitability. Book via the app or call us!';
    }

    if (text.contains('prp') || text.contains('platelet')) {
      return 'PRP (Platelet Rich Plasma) Therapy:\n\n• Uses your own growth factors to stimulate follicles\n• Sessions: 3–4 recommended (monthly)\n• Each session: ~45 minutes\n• From Rs 12,000 per session\n• Zero downtime — return to work same day\n\nBest combined with a hair transplant for maximum results. Want to book a consultation?';
    }

    if (text.contains('scalp') || text.contains('micropigmentation') || text.contains('smp')) {
      return 'Scalp Micropigmentation (SMP):\n\n• Non-surgical — creates illusion of shaved head or density\n• 2–3 sessions typically needed\n• Lasts 3–5 years with occasional touch-ups\n• From Rs 25,000\n\nIdeal for those wanting immediate, maintenance-free results. Book a free consultation to see if SMP is right for you!';
    }

    if (text.contains('lllt') || text.contains('laser')) {
      return 'LLLT (Low Level Laser Therapy):\n\n• Stimulates hair follicles with low-level light\n• Non-invasive, painless sessions\n• Sessions: 30 minutes each\n• From Rs 6,000 per session\n• Best results with regular monthly sessions\n\nGreat for early-stage hair loss and post-transplant recovery!';
    }

    if (text.contains('loyalty') || text.contains('points') || text.contains('reward')) {
      return 'Your current loyalty points: ${appData.loyaltyPoints} pts 🌟\n\nHow to earn:\n• Rs 1,000 spent = 10 points\n• Referring a friend = 200 points\n• Leaving a review = 50 points\n\nHow to redeem:\n• 100 points = Rs 100 off\n• View in Profile → Loyalty Points';
    }

    if (text.contains('membership') || text.contains('gold') || text.contains('silver') || text.contains('plan')) {
      return 'Your membership: ${appData.membershipTier} Member ✨\n\nGold benefits:\n• Priority appointment booking\n• 10% off all services\n• Free consultation each month\n• Exclusive promotions\n\nUpgrade to Platinum for VIP treatment and 20% off all services. View plans in Profile → Membership Plan.';
    }

    if (text.contains('hours') || text.contains('open') || text.contains('timing') || text.contains('location')) {
      return 'Hair Again Clinic:\n\n📍 Main Branch, Karachi\n🕐 Mon–Sat: 9:00 AM – 8:00 PM\n🕐 Sunday: 10:00 AM – 4:00 PM\n📞 +92-21-XXXX-XXXX\n📧 info@hairagain.pk\n\nWe also offer online consultations via video call. Would you like to schedule one?';
    }

    if (text.contains('hello') || text.contains('hi') || text.contains('hey') || text.contains('salam')) {
      return 'Hello! Great to hear from you 😊 I\'m here to help with anything related to your Hair Again experience — appointments, treatments, payments, or general queries. What can I do for you today?';
    }

    if (text.contains('thank') || text.contains('shukria') || text.contains('shukriya')) {
      return 'You\'re most welcome! 😊 Is there anything else I can help you with? Remember, our team is here Mon–Sat, 9 AM – 8 PM. Have a great day!';
    }

    return 'Thank you for your message! Our support specialist will respond within a few minutes.\n\nFor urgent queries:\n📞 +92-21-XXXX-XXXX\n📧 support@hairagain.pk\n\nIs there anything I can help you with in the meantime?';
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text.trim(), true, _fmtNow()));
      _sending = true;
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent + 120, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    // Simulate typing delay based on response length
    final response = _getResponse(text);
    final delay = Duration(milliseconds: 900 + (response.length * 3).clamp(0, 1600));
    Future.delayed(delay, () {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(response, false, _fmtNow()));
        _sending = false;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      });
    });
  }

  @override
  void dispose() { _controller.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = HaTheme.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.surface,
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: p.border)),
        leadingWidth: 40,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 18, color: p.text), onPressed: () => Navigator.maybePop(context), padding: EdgeInsets.zero),
        title: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.black87, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hair Again Support', style: p.body(14, weight: FontWeight.w700)),
            Row(children: [
              Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 4), decoration: const BoxDecoration(color: kSuccess, shape: BoxShape.circle)),
              Text('Online', style: p.body(11, color: kSuccess)),
            ]),
          ]),
        ]),
      ),
      body: Column(children: [
        // Message list
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: _msgs.length + (_sending ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _msgs.length) return _TypingIndicator(p: p);
            return _MsgBubble(msg: _msgs[i], p: p);
          },
        )),

        // Quick replies — only show when last message is from support
        if (_msgs.isNotEmpty && !_msgs.last.isMe && !_sending)
          SizedBox(height: 48, child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            children: _quickReplies.map((q) => GestureDetector(
              onTap: () => _send(q),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: kGold.withValues(alpha: 0.4))),
                alignment: Alignment.center,
                child: Text(q, style: p.body(12, color: kGold)),
              ),
            )).toList(),
          )),

        Container(height: 1, color: p.border),

        // Input bar
        Padding(
          padding: EdgeInsets.fromLTRB(12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
          child: Row(children: [
            Expanded(child: Container(
              decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: p.border)),
              child: TextField(
                controller: _controller,
                style: p.body(14),
                maxLines: 4, minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: p.body(14, color: p.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: _send,
              ),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _send(_controller.text),
              child: Container(width: 44, height: 44, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.black87, size: 20)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Msg {
  final String text, time;
  final bool isMe;
  _Msg(this.text, this.isMe, this.time);
}

class _MsgBubble extends StatelessWidget {
  final _Msg msg;
  final AppPalette p;
  const _MsgBubble({super.key, required this.msg, required this.p});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!msg.isMe) ...[
          Container(width: 28, height: 28, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.black87, size: 14)),
          const SizedBox(width: 8),
        ],
        Flexible(child: Column(
          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                color: msg.isMe ? kGold.withValues(alpha: 0.15) : p.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                  bottomLeft: msg.isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: msg.isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: Border.all(color: msg.isMe ? kGold.withValues(alpha: 0.3) : p.border),
              ),
              child: Text(msg.text, style: p.body(14)),
            ),
            const SizedBox(height: 3),
            Text(msg.time, style: p.body(10, color: p.textMuted)),
          ],
        )),
        if (msg.isMe) const SizedBox(width: 4),
      ],
    ),
  );
}

class _TypingIndicator extends StatefulWidget {
  final AppPalette p;
  const _TypingIndicator({required this.p});
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  @override
  void initState() { super.initState(); _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true); }
  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(width: 28, height: 28, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle),
        child: const Icon(Icons.support_agent, color: Colors.black87, size: 14)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: widget.p.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: widget.p.border)),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) =>
            Container(width: 6, height: 6, margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: kGold.withValues(alpha: 0.25 + (_anim.value * (i == 1 ? 0.75 : 0.5)))),
            ))),
        ),
      ),
    ]),
  );
}
