import 'package:flutter/material.dart';
import '../../../core/theme.dart';

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
    _Msg('Hello! Welcome to Hair Again support. How can I help you today?', false, '10:00 AM'),
    _Msg('Hi, I wanted to ask about my upcoming appointment.', true, '10:01 AM'),
    _Msg('Of course! I can see your appointment scheduled for 18 Jul 2026 at 11:00 AM with Dr. Bilal Khan. Is there anything specific you\'d like to know?', false, '10:01 AM'),
    _Msg('I need to change the time if possible. Is 2 PM available?', true, '10:03 AM'),
    _Msg('Let me check for you. Dr. Bilal Khan has a slot available at 2:30 PM on the same day. Would that work for you?', false, '10:04 AM'),
  ];

  static const _quickReplies = ['Reschedule appointment', 'Treatment info', 'Payment issue', 'General enquiry'];

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text.trim(), true, _timeNow()));
      _sending = true;
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scroll.animateTo(_scroll.position.maxScrollExtent + 100, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg('Thank you for your message. A support agent will respond shortly. Our team is available 9 AM – 8 PM, Mon – Sat.', false, _timeNow()));
        _sending = false;
      });
    });
  }

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
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
          Container(width: 38, height: 38, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle), child: const Icon(Icons.support_agent, color: Colors.black87, size: 20)),
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
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: _msgs.length + (_sending ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _msgs.length) return _TypingIndicator(p: p);
            return _MsgBubble(msg: _msgs[i], p: p);
          },
        )),

        // Quick replies (only if last msg is from support)
        if (_msgs.isNotEmpty && !_msgs.last.isMe)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: _quickReplies.map((q) =>
              GestureDetector(
                onTap: () => _send(q),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: kGold.withValues(alpha: 0.4))),
                  alignment: Alignment.center,
                  child: Text(q, style: p.body(12, color: kGold)),
                ),
              ),
            ).toList())),
          ),

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
              child: Container(width: 44, height: 44, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle), child: const Icon(Icons.send_rounded, color: Colors.black87, size: 20)),
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
          Container(width: 28, height: 28, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle), child: const Icon(Icons.support_agent, color: Colors.black87, size: 14)),
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
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
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
      Container(width: 28, height: 28, decoration: BoxDecoration(gradient: kGoldGradient, shape: BoxShape.circle), child: const Icon(Icons.support_agent, color: Colors.black87, size: 14)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: widget.p.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: widget.p.border)),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Container(
            width: 6, height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGold.withValues(alpha: 0.3 + (_anim.value * (i == 1 ? 0.7 : 0.5))),
            ),
          ))),
        ),
      ),
    ]),
  );
}
