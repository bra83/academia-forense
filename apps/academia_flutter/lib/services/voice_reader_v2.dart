import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_core/audio_core.dart';

/// Real engine switching: a failed online request must never play local audio.
class VoiceReaderV2 extends StatefulWidget {
  const VoiceReaderV2({
    super.key,required this.readText,required this.getApiKey,
    required this.speechModel,this.sourceId='',this.sourceLabel='',
  });
  final String readText;
  final Future<String?> Function() getApiKey;
  final String? speechModel;
  final String sourceId,sourceLabel;
  @override
  State<VoiceReaderV2> createState()=>_VoiceReaderV2State();
}
class _VoiceReaderV2State extends State<VoiceReaderV2> {
  final MotorAKokoroController _kokoro=MotorAKokoroController();
  // A hidden, persistent voice panel must not initialize native audio until
  // playback actually starts. Flutter widget tests also lack audio plugins.
  AudioPlayer? _geminiPlayer;
  AudioPlayer get _player {
    final existing=_geminiPlayer;
    if(existing!=null)return existing;
    final player=AudioPlayer();
    _geminiPlayer=player;
    _finished=player.onPlayerComplete.listen((_)=>_playNextGemini());
    return player;
  }
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
  GeminiTtsClient? _client;
  Future<GeminiSpeechChunk?>? _prefetch;
  int _prefetchIndex=-1;
  String _requestError='';
  bool _stopping=false,_canResume=false;

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
  }
  @override
  void didUpdateWidget(covariant VoiceReaderV2 oldWidget){
    super.didUpdateWidget(oldWidget);
    if(oldWidget.sourceId!=widget.sourceId || oldWidget.readText!=widget.readText){
      _canResume=false;
      if(_playing||_working){unawaited(_stop());}
    }
  }

  Future<void> _loadKokoroVoices() async {
    try {
      if (!_kokoroReady) _kokoroReady=await _kokoro.initialize(
        enginePackage:_systemVoice?'system':null);
      if (!_kokoroReady) throw StateError('Motor não inicializado.');
      List<TtsVoiceInfo> installed=[];
      try{installed=await _kokoro.getAvailableVoices();}catch(_){/* Some engines expose only their default voice. */}
      final portuguese=installed.where((v)=>v.locale.toLowerCase().startsWith('pt')).toList();
      final voices=portuguese.isNotEmpty?portuguese:installed;
      if (!mounted) return;
      setState(() {
        _voices=<String>{'__engine_default__',...voices.map((v)=>v.name).where((s)=>s.isNotEmpty)}.toList();
        if (!_voices.contains(_selectedVoice)) {
          _selectedVoice=_voices.isEmpty?null:_voices.first;
        }
        _message=installed.isEmpty?'Motor inicializado sem lista de vozes. Será usada a voz padrão desse mesmo motor.':
          'Motor '+(_systemVoice?'Android':'Kokoro')+' inicializado; '
          '${_voices.length} voz(es) disponível(is).';
      });
    } catch (e) {
      if (mounted) setState(()=>_message='Falha ao inicializar voz '+
        (_systemVoice?'Android':'Kokoro')+': $e');
    }
  }
  Future<void> _stop() async {
    _stopping=true;_canResume=false;
    _generation++;
    _chunks=[];_prefetch=null;_prefetchIndex=-1;
    _client?.close();_client=null;
    if (mounted) setState(() { _playing=false;_working=false;_message='Reprodução parada.'; });
    try {
      await _kokoro.stop();
    } catch (_) {}
    try{await _geminiPlayer?.stop();}catch(_){}
    if(mounted)setState(()=>_stopping=false);
  }

  Future<void> _toggle({bool shortTest=false}) async {
    if (_playing) { await _stop(); return; }
    if (_working||_stopping) return;
    final text=shortTest ? 'Olá. Esta é uma verificação de voz da Academia Forense.' :
      widget.readText.trim();
    if (text.isEmpty) {setState(()=>_message='Sem texto disponível para leitura.');return;}
    final round=++_generation;
    setState((){_working=true;_canResume=false;});
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
        if(!mounted||round!=_generation)return;
        final voiceWasApplied=_selectedVoice=='__engine_default__'||await _kokoro.setVoice(_selectedVoice!);
        if (!voiceWasApplied) throw StateError('Voz rejeitada pelo motor selecionado.');
        if(!mounted||round!=_generation)return;
        await _kokoro.setSpeed(_speed);
        if(!mounted||round!=_generation)return;
        _chunks=SentenceSegmenter.segment(text,maxLength:900,maxSentences:8).chunks;
        await _kokoro.playChunks(_chunks);
        if (_kokoro.state==MotorPlaybackState.error) {
          throw StateError('Falha na síntese local.');
        }
        if (mounted&&round==_generation) setState(() {
          _playing=_kokoro.state==MotorPlaybackState.playing;
          _message=(_systemVoice?'Android':'Kokoro')+': '
            'síntese encaminhada à voz '+(_selectedVoice=='__engine_default__'?'padrão do motor':_selectedVoice!);
        });
      } else {
        final key=await widget.getApiKey();
        final model=widget.speechModel;
        if (key==null || key.isEmpty || model==null || model.isEmpty) {
          throw StateError('Configure a chave e o modelo Gemini TTS nas configurações.');
        }
        if(!mounted||round!=_generation)return;
        final clean=model.startsWith('models/')?model.substring(7):model;
        _client?.close();_client=GeminiTtsClient(apiKey:key,model:clean);
        _chunks=SentenceSegmenter.segment(text,maxLength:1100,maxSentences:12).chunks;
        _prefetch=null;_prefetchIndex=-1;_requestError='';
        _index=0;
        if (mounted) setState(() {
          _playing=true;
          _message='Solicitando síntese Gemini na voz '+_geminiVoice+'...';
        });
        await _playNextGemini();
      }
    } catch(e) {
      if (mounted&&round==_generation) setState(() {
        _playing=false;
        _message='Falha de leitura: $e. Nenhum motor alternativo foi acionado.';
      });
    } finally {
      if (mounted&&round==_generation) setState(()=>_working=false);
    }
  }

  Future<GeminiSpeechChunk?> _synthesize(int index,int round) async {
    final client=_client;
    if(client==null||round!=_generation||index>=_chunks.length)return null;
    final chunk=_chunks[index];
    final voice=_geminiVoice;
    for(var attempt=0;attempt<3;attempt++){
      if(!mounted||round!=_generation)return null;
      try{
        return await client.synthesize(chunkId:chunk.id,text:chunk.text,
          paragraphIndex:chunk.paragraphIndex,voiceName:voice).timeout(const Duration(seconds:60));
      }catch(e){
        if(!mounted||round!=_generation)return null;
        _requestError=e.toString();
        if(e is GeminiAuthException||e is GeminiModelNotFoundException||e is GeminiQuotaExceededException)return null;
        if(attempt<2)await Future<void>.delayed(Duration(milliseconds:800*(attempt+1)));
      }
    }
    return null;
  }

  Future<void> _playNextGemini() async {
    if(!mounted||!_playing||_engine!=AudioEngine.geminiOnline)return;
    if(_index>=_chunks.length){
      _client?.close();_client=null;_prefetch=null;
      setState((){_playing=false;_message='Leitura da página concluída.';});
      return;
    }
    final round=_generation,index=_index;
    try{
      final pending=_prefetchIndex==index?_prefetch:null;
      final audio=await (pending??_synthesize(index,round));
      if(!mounted||round!=_generation||!_playing)return;
      if(audio==null)throw StateError(_requestError.isEmpty?'Áudio não retornado':_requestError);
      _index=index+1;
      // Start generating the next chunk while the current audio is playing.
      _prefetchIndex=_index;
      _prefetch=_index<_chunks.length?_synthesize(_index,round):null;
      final player=_player;
      await player.play(BytesSource(audio.wavBytes));
      if(!mounted||round!=_generation){await player.stop();return;}
      await player.setPlaybackRate(_speed);
      if(mounted&&round==_generation)setState(()=>_message='Gemini '+_geminiVoice+
        ' — trecho '+(index+1).toString()+'/'+_chunks.length.toString());
    }catch(e){
      if(mounted&&round==_generation){
        _index=index;
        _canResume=true;
        _client?.close();_client=null;_prefetch=null;_prefetchIndex=-1;
        setState((){_playing=false;_message='Leitura interrompida no trecho '+(index+1).toString()+
          '/'+_chunks.length.toString()+': '+e.toString()+'. Nenhum trecho foi pulado.';});
      }
    }
  }

  Future<void> _resumeGemini() async {
    if(!_canResume||_working||_stopping||_playing||_engine!=AudioEngine.geminiOnline)return;
    final round=++_generation;
    setState((){_working=true;_canResume=false;});
    try{
      final key=await widget.getApiKey();
      final model=widget.speechModel;
      if(key==null||key.isEmpty||model==null||model.isEmpty)throw StateError('Chave ou modelo ausente.');
      if(!mounted||round!=_generation)return;
      _client=GeminiTtsClient(apiKey:key,model:model.startsWith('models/')?model.substring(7):model);
      _requestError='';
      setState(()=>_playing=true);
      await _playNextGemini();
    }catch(e){
      if(mounted&&round==_generation)setState((){_playing=false;_canResume=true;_message=e.toString();});
    }finally{
      if(mounted&&round==_generation)setState(()=>_working=false);
    }
  }

  @override
  void dispose() {
    _generation++;
    _client?.close();
    if (_progress!=null) unawaited(_progress!.cancel());
    if (_errors!=null) unawaited(_errors!.cancel());
    if (_finished!=null) unawaited(_finished!.cancel());
    unawaited(_kokoro.dispose().catchError((Object _){}));
    if(_geminiPlayer!=null)unawaited(_geminiPlayer!.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(child:Padding(
      padding:const EdgeInsets.all(16),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        if(widget.sourceLabel.isNotEmpty)Text('Fonte: '+widget.sourceLabel,style:const TextStyle(fontWeight:FontWeight.w600)),
        Text('Leitura por voz',style:Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:8),
        Wrap(spacing:8,runSpacing:8,children:[
          ChoiceChip(label:const Text('Kokoro local'),
            selected:_engine==AudioEngine.kokoroLocal && !_systemVoice,
            onSelected:_working||_stopping?null:(_) async {
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
              items:_voices.map((v)=>DropdownMenuItem(value:v,child:Text(v=='__engine_default__'?'Padrão do motor':v))).toList(),
              onChanged:_playing||_working?null:(v)=>setState(()=>_selectedVoice=v)),
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
          onChanged:_playing||_working?null:(v){if(v!=null)setState(()=>_geminiVoice=v);}),
        Row(children:[
          const Text('Velocidade'),
          Expanded(child:Slider(value:_speed,min:0.65,max:1.5,divisions:17,
            label:_speed.toStringAsFixed(2)+'×',
            onChanged:(v)=>setState(()=>_speed=v))),
          Text(_speed.toStringAsFixed(2)+'×'),
        ]),
        Wrap(spacing:8,runSpacing:8,children:[
          FilledButton.icon(
            onPressed:_stopping||(_working&&!_playing)?null:()=>_toggle(),
            icon:Icon(_playing?Icons.stop:Icons.play_arrow),
            label:Text(_playing?'Parar leitura':'Ler texto desta página')),
          OutlinedButton.icon(
            onPressed:_working||_stopping||_playing?null:()=>_toggle(shortTest:true),
            icon:const Icon(Icons.volume_up_outlined),
            label:const Text('Testar voz (frase curta)')),
        ]),
        if(_canResume)TextButton.icon(onPressed:_resumeGemini,icon:const Icon(Icons.replay),label:const Text('Retomar trecho interrompido')),
        if (_message.isNotEmpty) Padding(padding:const EdgeInsets.only(top:8),
          child:Text(_message)),
      ]),
    ));
  }
}
