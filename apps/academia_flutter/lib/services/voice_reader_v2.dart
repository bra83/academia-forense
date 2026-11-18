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
  bool _systemVoice=false;
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
      if (!_kokoroReady) _kokoroReady=await _kokoro.initialize(
        enginePackage:_systemVoice?'system':null);
      if (!_kokoroReady) throw StateError('Motor não inicializado.');
      final installed=await _kokoro.getAvailableVoices();
      final portuguese=installed.where((v)=>v.locale.toLowerCase().startsWith('pt')).toList();
      final voices=portuguese.isNotEmpty?portuguese:installed;
      if (!mounted) return;
      setState(() {
        _voices=voices.map((v)=>v.name).where((s)=>s.isNotEmpty).toList();
        if (!_voices.contains(_selectedVoice)) {
          _selectedVoice=_voices.isEmpty?null:_voices.first;
        }
        _message=_voices.isEmpty?'O motor não informou nenhuma voz. Confira '
          'os pacotes de voz no Android.':
          'Motor '+(_systemVoice?'Android':'Kokoro')+' inicializado; '
          '${_voices.length} voz(es) disponível(is).';
      });
    } catch (e) {
      if (mounted) setState(()=>_message='Falha ao inicializar voz '+
        (_systemVoice?'Android':'Kokoro')+': $e');
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

  Future<void> _toggle({bool shortTest=false}) async {
    if (_working) return;
    if (_playing) { await _stop(); return; }
    final text=shortTest ? 'Olá. Esta é uma verificação de voz da Academia Forense.' :
      widget.readText.trim();
    if (text.isEmpty) {setState(()=>_message='Sem texto disponível para leitura.');return;}
    _generation++;
    setState(()=>_working=true);
    try {
      if (_engine==AudioEngine.kokoroLocal) {
        if (!_kokoroReady || _selectedVoice==null) await _loadKokoroVoices();
        if (!_kokoroReady || _selectedVoice==null) {
          throw StateError(_systemVoice?
            'Motor Android indisponível. Configure um sintetizador de voz '
            'no dispositivo e instale a voz português do Brasil.':
            'Motor Braseiro Kokoro indisponível. É necessário instalar '
            'o Sherpa-ONNX como serviço TTS separado. Para testar sem '
            'ele, escolha Voz Android (sistema).');
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
          _playing=_kokoro.state==MotorPlaybackState.playing;
          _message=(_systemVoice?'Android':'Kokoro')+': '
            'síntese encaminhada à voz '+_selectedVoice!;
        });
      } else {
        final key=await widget.getApiKey();
        final model=widget.speechModel;
        if (key==null || key.isEmpty || model==null || model.isEmpty) {
          throw StateError('Configure a chave e o modelo Gemini TTS nas configurações.');
        }
        _chunks=SentenceSegmenter.segment(text,maxLength:420).chunks;
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
        _message='Falha de leitura: $e. Nenhum motor alternativo foi acionado.';
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
      await _geminiPlayer.setSource(BytesSource(audio.wavBytes));
      await _geminiPlayer.setPlaybackRate(_speed);
      await _geminiPlayer.resume();
      if (mounted) setState(()=>_message='Gemini '+_geminiVoice+
        ' — trecho '+_index.toString()+'/'+_chunks.length.toString());
    } catch(e) {
      if (mounted) setState(() {
        _playing=false;
        _message='Gemini TTS falhou: $e. Verifique ID do modelo, '
          'conexão e cota; Charon é uma voz, não um modelo.';
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
            selected:_engine==AudioEngine.kokoroLocal && !_systemVoice,
            onSelected:(_) async {
              await _stop();
              setState((){
                _engine=AudioEngine.kokoroLocal;_systemVoice=false;
                _kokoroReady=false;_voices=[];_selectedVoice=null;
              });
              await _loadKokoroVoices();
            }),
          ChoiceChip(label:const Text('Voz Android (sistema)'),
            selected:_engine==AudioEngine.kokoroLocal && _systemVoice,
            onSelected:(_) async {
              await _stop();
              setState((){
                _engine=AudioEngine.kokoroLocal;_systemVoice=true;
                _kokoroReady=false;_voices=[];_selectedVoice=null;
              });
              await _loadKokoroVoices();
            }),
          ChoiceChip(label:const Text('Gemini TTS'),
            selected:_engine==AudioEngine.geminiOnline,
            onSelected:(_) async {
              await _stop();
              setState(()=>_engine=AudioEngine.geminiOnline);
            }),
        ]),
        if (_engine==AudioEngine.kokoroLocal) ...[
          if (_voices.isNotEmpty)
            DropdownButtonFormField<String>(
              value:_voices.contains(_selectedVoice)?_selectedVoice:null,
              decoration:const InputDecoration(labelText:'Voz instalada'),
              items:_voices.map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),
              onChanged:(v)=>setState(()=>_selectedVoice=v)),
          Text(_systemVoice?'Usa o sintetizador padrão do Android. '
            'A voz pt-BR precisa estar instalada no aparelho.':
            'Exige o aplicativo Braseiro/Sherpa-ONNX TTS instalado. '
            'Não é integrado ao APK da Academia.',
            style:const TextStyle(fontSize:12)),
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
        Wrap(spacing:8,runSpacing:8,children:[
          FilledButton.icon(
            onPressed:_working?null:()=>_toggle(),
            icon:Icon(_playing?Icons.stop:Icons.play_arrow),
            label:Text(_playing?'Parar leitura':'Ler texto desta página')),
          OutlinedButton.icon(
            onPressed:_working?null:()=>_toggle(shortTest:true),
            icon:const Icon(Icons.volume_up_outlined),
            label:const Text('Testar voz (frase curta)')),
        ]),
        if (_message.isNotEmpty) Padding(padding:const EdgeInsets.only(top:8),
          child:Text(_message)),
      ]),
    ));
  }
}
