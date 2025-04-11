import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ReportViolationScreen extends StatefulWidget {
  const ReportViolationScreen({Key? key}) : super(key: key);

  @override
  _ReportViolationScreenState createState() => _ReportViolationScreenState();
}

class _ReportViolationScreenState extends State<ReportViolationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _violationController = TextEditingController();
  
  // 이미지 피커 인스턴스
  final ImagePicker _picker = ImagePicker();
  
  // 선택된 이미지 파일
  File? _imageFile;
  
  // 로딩 상태
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // 현재 날짜를 기본값으로 설정
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
  
  @override
  void dispose() {
    _dateController.dispose();
    _locationController.dispose();
    _violationController.dispose();
    super.dispose();
  }
  
  // 이미지 선택 메서드
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
      );
    }
  }
  
  // 날짜 선택 메서드
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  // 신고 제출 메서드
  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      // 폼 검증 성공
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 첨부해주세요')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // 현재 사용자 가져오기
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인이 필요합니다')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        String? imageUrl;
        
        // 이미지 업로드
        if (_imageFile != null) {
          // 파일 이름 생성 (타임스탬프 사용)
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'violation_reports/${user.uid}_$timestamp.jpg';
          
          // Firebase Storage에 이미지 업로드
          final storageRef = FirebaseStorage.instance.ref().child(imageName);
          final uploadTask = storageRef.putFile(_imageFile!);
          final snapshot = await uploadTask;
          
          // 업로드된 이미지의 URL 가져오기
          imageUrl = await snapshot.ref.getDownloadURL();
        }
        
        // 유저별 컬렉션에 데이터 저장
        // 먼저 users 컬렉션 아래에 유저 ID로 문서 생성 (없으면)
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // 리포트 데이터 생성
        final reportData = {
          'userId': user.uid,
          'userEmail': user.email,
          'date': _dateController.text,
          'location': _locationController.text,
          'violation': _violationController.text,
          'imageUrl': imageUrl,
          'status': 'submitted', // 처리 상태
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // 유저 문서 내의 reports 하위 컬렉션에 리포트 추가
        await userDocRef.collection('reports').add(reportData);
        
        // 전체 리포트 컬렉션에도 동일한 데이터 저장 (검색 및 관리 목적)
        await FirebaseFirestore.instance.collection('all_reports').add(reportData);
        
        // 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('신고가 성공적으로 제출되었습니다')),
          );
          
          // 폼 초기화
          _locationController.clear();
          _violationController.clear();
          setState(() {
            _imageFile = null;
          });
        }
      } catch (e) {
        // 오류 처리
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('신고 제출 중 오류가 발생했습니다: $e')),
          );
        }
      } finally {
        // 로딩 상태 해제
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위반 사항 신고하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('날짜', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.orange),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '날짜를 선택해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('장소', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '위치를 입력해주세요',
                    suffixIcon: Icon(Icons.location_on, color: Colors.orange),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '장소를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('위험한 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('카메라로 촬영'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('갤러리에서 선택'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('위반 사항', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _violationController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '위반사항을 입력해주세요',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '위반 사항을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '신고하기',
                            style: TextStyle(fontSize: 16),
                          ),
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