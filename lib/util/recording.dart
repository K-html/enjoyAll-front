import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/temp_recording.wav';

    try {
      await _recorder.startRecorder(
        toFile: tempPath,
        codec: Codec.pcm16WAV,
      );

      setState(() {
        _isRecording = true;
        _filePath = tempPath;
      });
    } catch (e) {
      print('Recorder error: $e');
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();

    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _playRecording() async {
    if (_filePath != null && !_isPlaying) {
      try {
        await _player.startPlayer(
          fromURI: _filePath,
          codec: Codec.pcm16WAV,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
            });
          },
        );

        setState(() {
          _isPlaying = true;
        });
      } catch (e) {
        print('Player error: $e');
      }
    } else if (_isPlaying) {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> _sendRecording() async {
    if (_filePath != null) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://175.45.205.178/chat'),
        );

        request.files
            .add(await http.MultipartFile.fromPath('file', _filePath!));
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          Navigator.pop(context, responseData); // 응답 데이터를 전달
        } else {
          Navigator.pop(context, '녹음 전송에 실패했습니다.');
        }
      } catch (e) {
        Navigator.pop(context, '오류가 발생했습니다: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '음성 녹음',
          style: TextStyle(
            color: Color(0xFF1D1B20),
            fontSize: 22,
            fontFamily: 'GmarketSansTTFMedium',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 50,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
              ),
              SizedBox(height: 20),
              Text(
                _isRecording ? '녹음 중...' : '녹음을 시작하려면 버튼을 누르세요',
                style: TextStyle(
                  color: Color(0xFF595858),
                  fontSize: 18,
                  fontFamily: 'GmarketSansTTFBold',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _playRecording,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _isPlaying ? Colors.red : Colors.blue,
                  // 텍스트 색상
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_isPlaying ? '재생 중지' : '녹음된 파일 재생'),
              ),

// 서버로 전송 버튼
              ElevatedButton(
                onPressed: _sendRecording,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  // 텍스트 색상
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('서버로 전송'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
