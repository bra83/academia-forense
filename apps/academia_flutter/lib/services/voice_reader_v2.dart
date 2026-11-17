import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_core/audio_core.dart';

/// Real engine switching: a failed online request must never play local audio.
class VoiceReaderV2 extends StatefulWidget {
  const VoiceReaderV2({
    super.key,required this.readText,required this.getApiKey,
    required this.speechModel,
  });
  final String readText;
  final Future<String?> Function() getApiKey;
  final String? speechModel;
  @override
  State<VoiceReaderV2> createState()=>_VoiceReaderV2State();
}
class _VoiceReaderV2State extends State<VoiceReaderV2> {
  final MotorAKokoroController _kokoro=MotorAKokoroController();
  final AudioPlayer _geminiPlayer=AudioPlayer();
  StreamSubscription<MotorProgressEvent>? _progress;
  StreamSubscription<String>? _errors;
  StreamSubscription<void>? _finished;
  AudioEngine _engine=AudioEngine.kokoroLocal;
  List<String> _voices=[];
  String? _selectedVoice;
  String _geminiVoice='Charon';
  double _speed=1.0;
  bool _playing=false, _working=false, _kokoroReady=false;
  String _message='';
  List<AudioChunk> _chunks=[];
  int _index=0, _generation=0;

  @override
  void initState() {
    super.initState();
    _progress=_kokoro.progressStream.listen((event){
      if (!mounted) return;
      if (event.state==MotorPlaybackState.stopped ||
          event.state==MotorPlaybackState.error) {
        setState(()=>_playing=false);
      }
    });
    _errors=_kokoro.errorStream.listen((err){
      if (mounted) setState(() {
        _playing=false;
        _working=false;
        _message='Erro Kokoro: '+err;
      });
    });
    _finished=_geminiPlayer.onPlayerComplete.listen((_)=>_playNextGemini());
  }
  Future<void> _loadKokoroVoices() async {
    try {
      if (!_kokoroReady) _kokoroReady=await _kokoro.initialize();
      if (!_kokoroReady) throw StateError('Motor não inicializado.');
      final voices=await _kokoro.getAvailableVoices();
      if (!mounted) return;
      setState(() {
        _voices=voices.map((v)=>v.name).where((s)=>s.isNotEmpty).toList();
        if (!_voices.contains(_selectedVoice)) {
          _selectedVoice=_voices.isEmpty?null:_voices.first;
        }
        _message=_voices.isEmpty?'Nenhuma voz disponível no Kokoro.':
          'Vozes instaladas: '+_voices.length.toString();
      });
    } catch (e) {
      if (mounted) setState(()=>_message='Kokoro não encontrado ou indisponível: '+e.runtimeType.toString());
    }
  }
  Future<void> _stop() async {
    _generation++;
    _chunks=[];
    try {
      await _kokoro.stop();
      await _geminiPlayer.stop();
    } catch (_) {}
    if (mounted) setState(() { _playing=false;_working=false;_message='Reprodução parada.'; });
  }

  Future<void> _toggle() async {
    if (_working) return;
    if (_playing) { await _stop(); return; }
    final text=widget.readText.trim();
    if (text.isEmpty) {setState(()=>_message='Sem texto disponível para leitura.');return;}
    _generation++;
    setState(()=>_working=true);
    try {
      if (_engine==AudioEngine.kokoroLocal) {
        if (!_kokoroReady || _selectedVoice==null) await _loadKokoroVoices();
        if (!_kokoroReady || _selectedVoice==null) {
          throw StateError('Instale e habilite o motor Braseiro Kokoro.');
        }
        final voiceWasApplied=await _kokoro.setVoice(_selectedVoice!);
        if (!voiceWasApplied) throw StateError('Voz Kokoro rejeitada pelo motor.');
        await _kokoro.setSpeed(_speed);
        _chunks=SentenceSegmenter.segment(text).chunks;
        await _kokoro.playChunks(_chunks);
        if (_kokoro.state==MotorPlaybackState.error) {
          throw StateError('Falha na síntese local.');
        }
        if (mounted) setState(() {
          _playing=true;
          _message='Kokoro: áudio solicitado à voz real '+_selectedVoice!;
        });
      } else {
        final key=await widget.getApiKey();
        final model=widget.speechModel;
        if (key==null || key.isEmpty || model==null || model.isEmpty) {
          throw StateError('Configure a chave e o modelo Gemini TTS nas configurações.');
        }
        _chunks=SentenceSegmenter.segment(text,maxLength:450).chunks;
        _index=0;
        if (mounted) setState(() {
          _playing=true;
          _message='Solicitando síntese Gemini na voz '+_geminiVoice+'...';
        });
        await _playNextGemini();
      }
    } catch(e) {
      if (mounted) setState(() {
        _playing=false;
        _message='A leitura falhou ('+e.runtimeType.toString()+'). Nenhum outro motor foi acionado.';
      });
    } finally {
      if (mounted) setState(()=>_working=false);
    }
  }

  Future<void> _playNextGemini() async {
    if (!mounted || !_playing || _engine!=AudioEngine.geminiOnline) return;
    if (_index>=_chunks.length) {
      setState(()=>_playing=false);
      return;
    }
    final round=_generation;
    final chunk=_chunks[_index++];
    try {
      final key=await widget.getApiKey();
      final model=widget.speechModel;
      if (key==null || model==null) throw StateError('Chave ou modelo ausente.');
      final clean=model.startsWith('models/')?model.substring(7):model;
      final audio=await GeminiTtsClient(apiKey:key,model:clean).synthesize(
        chunkId:chunk.id,text:chunk.text,
        paragraphIndex:chunk.paragraphIndex,voiceName:_geminiVoice);
      if (!mounted || round!=_generation || !_playing) return;
      await _geminiPlayer.setPlaybackRate(_speed);
      await _geminiPlayer.play(BytesSource(audio.wavBytes));
      if (mounted) setState(()=>_message='Gemini '+_geminiVoice+
        ' — trecho '+_index.toString()+'/'+_chunks.length.toString());
    } catch(e) {
      if (mounted) setState(() {
        _playing=false;
        _message='Gemini TTS falhou ('+e.runtimeType.toString()+
          '). Verifique modelo, chave, internet e cota.';
      });
    }
  }

  @override
  void dispose() {
    _generation++;
    if (_progress!=null) unawaited(_progress!.cancel());
    if (_errors!=null) unawaited(_errors!.cancel());
    if (_finished!=null) unawaited(_finished!.cancel());
    unawaited(_kokoro.dispose().catchError((Object _){}));
    unawaited(_geminiPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(child:Padding(
      padding:const EdgeInsets.all(16),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Leitura por voz',style:Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:8),
        Wrap(spacing:8,runSpacing:8,children:[
          ChoiceChip(label:const Text('Kokoro local'),
            selected:_engine==AudioEngine.kokoroLocal,
            onSelected:(_) async {await _stop();setState(()=>_engine=AudioEngine.kokoroLocal);await _loadKokoroVoices();}),
          ChoiceChip(label:const Text('Gemini TTS (Charon)'),
            selected:_engine==AudioEngine.geminiOnline,
            onSelected:(_) async {await _stop();setState(()=>_engine=AudioEngine.geminiOnline);}),
        ]),
        if (_engine==AudioEngine.kokoroLocal) ...[
          if (_voices.isNotEmpty)
            DropdownButtonFormField<String>(
              value:_voices.contains(_selectedVoice)?_selectedVoice:null,
              decoration:const InputDecoration(labelText:'Voz instalada'),
              items:_voices.map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),
              onChanged:(v)=>setState(()=>_selectedVoice=v)),
          TextButton.icon(onPressed:_loadKokoroVoices,
            icon:const Icon(Icons.refresh),label:const Text('Buscar vozes instaladas')),
        ] else DropdownButtonFormField<String>(
          value:_geminiVoice,
          decoration:const InputDecoration(labelText:'Voz Gemini'),
          items:GeminiTtsPayloadBuilder.supportedVoices.map((v)=>
            DropdownMenuItem(value:v,child:Text(v))).toList(),
          onChanged:(v){if(v!=null)setState(()=>_geminiVoice=v);}),
        Row(children:[
          const Text('Velocidade'),
          Expanded(child:Slider(value:_speed,min:0.65,max:1.5,divisions:17,
            label:_speed.toStringAsFixed(2)+'×',
            onChanged:(v)=>setState(()=>_speed=v))),
          Text(_speed.toStringAsFixed(2)+'×'),
        ]),
        FilledButton.icon(onPressed:_working?null:_toggle,
          icon:Icon(_playing?Icons.stop:Icons.play_arrow),
          label:Text(_playing?'Parar leitura':'Ler texto desta página')),
        if (_message.isNotEmpty) Padding(padding:const EdgeInsets.only(top:8),
          child:Text(_message)),
      ]),
    ));
  }
}
