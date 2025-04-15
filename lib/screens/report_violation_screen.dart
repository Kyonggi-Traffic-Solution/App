import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../utils/ui_helper.dart';

class ReportViolationScreen extends StatefulWidget {
  const ReportViolationScreen({Key? key}) : super(key: key);

  @override
  _ReportViolationScreenState createState() => _ReportViolationScreenState();
}

class _ReportViolationScreenState extends State<ReportViolationScreen> with SingleTickerProviderStateMixin {
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
  
  // 애니메이션 컨트롤러
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
  // 위반 사항 선택을 위한 리스트
  final List<String> _violationTypes = [
    '안전모 미착용',
    '2인 탑승',
    '기타',
  ];
  
  // 선택된 위반 사항
  String? _selectedViolationType;
  
  @override
  void initState() {
    super.initState();
    // 현재 날짜를 기본값으로 설정
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    // 애니메이션 시작
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _dateController.dispose();
    _locationController.dispose();
    _violationController.dispose();
    _animationController.dispose();
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
      UIHelper.showErrorSnackBar(
        context,
        message: '이미지 선택 중 오류가 발생했습니다: $e',
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  // 위치정보 가져오기 (가상의 함수, 실제 구현은 위치 서비스에 따라 다름)
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 실제 구현에서는 여기에 위치 서비스 API를 호출
      // 예시로 가상의 위치 정보를 반환
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _locationController.text = "서울시 강남구 테헤란로 123";
          _isLoading = false;
        });
        
        UIHelper.showSuccessSnackBar(
          context,
          message: '현재 위치를 가져왔습니다.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        UIHelper.showErrorSnackBar(
          context,
          message: '위치 정보를 가져오는데 실패했습니다: $e',
        );
      }
    }
  }
  
  // 신고 제출 메서드
  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      // 폼 검증 성공
      if (_imageFile == null) {
        UIHelper.showWarningSnackBar(
          context,
          message: '이미지를 첨부해주세요',
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
          UIHelper.showErrorSnackBar(
            context,
            message: '로그인이 필요합니다',
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
          
          // 업로드 진행 상황을 사용자에게 보여줄 수 있음
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            print('Upload progress: $progress');
            // 여기서 진행 막대를 업데이트할 수 있음
          });
          
          final snapshot = await uploadTask;
          
          // 업로드된 이미지의 URL 가져오기
          imageUrl = await snapshot.ref.getDownloadURL();
        }
        
        // 위반 사항 텍스트 준비
        final violationText = _selectedViolationType == '기타' 
            ? _violationController.text.trim() 
            : _selectedViolationType ?? _violationController.text.trim();
        
        // 유저별 컬렉션에 데이터 저장
        // 먼저 users 컬렉션 아래에 유저 ID로 문서 생성 (없으면)
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // 리포트 데이터 생성
        final reportData = {
          'userId': user.uid,
          'userEmail': user.email,
          'date': _dateController.text,
          'location': _locationController.text,
          'violation': violationText,
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
          UIHelper.showSuccessSnackBar(
            context,
            message: '신고가 성공적으로 제출되었습니다',
          );
          
          // 폼 초기화 및 이미지 리셋 (성공 애니메이션과 함께)
          _resetForm();
        }
      } catch (e) {
        // 오류 처리
        if (mounted) {
          UIHelper.showErrorSnackBar(
            context,
            message: '신고 제출 중 오류가 발생했습니다: $e',
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
  
  // 폼 초기화 메서드
  void _resetForm() {
    _locationController.clear();
    _violationController.clear();
    setState(() {
      _selectedViolationType = null;
      _imageFile = null;
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    });
    
    // 애니메이션 효과 재생
    _animationController.reset();
    _animationController.forward();
  }

  // 미리보기 대화상자 표시
  void _showPreviewDialog() {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      final violationText = _selectedViolationType == '기타' 
          ? _violationController.text.trim() 
          : _selectedViolationType ?? _violationController.text.trim();
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '신고 내용 확인',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPreviewItem('날짜', _dateController.text),
                      _buildPreviewItem('장소', _locationController.text),
                      _buildPreviewItem('위반 사항', violationText),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('수정하기'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _submitReport();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('신고하기'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      UIHelper.showWarningSnackBar(
        context,
        message: '모든 필드를 입력하고 이미지를 첨부해주세요',
      );
    }
  }
  
  // 미리보기 항목 위젯
  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위반 사항 신고하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('날짜', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today, color: Colors.orange),
                          onPressed: _selectDate,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '날짜를 선택해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('장소', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _isLoading ? null : _getCurrentLocation,
                        icon: const Icon(Icons.my_location, size: 16),
                        label: const Text('현재 위치 가져오기'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                        hintText: '위치를 입력해주세요',
                        suffixIcon: const Icon(Icons.location_on, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '장소를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('위험한 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                '이미지 선택',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                                ),
                                title: const Text('카메라로 촬영'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.photo_library, color: Colors.green),
                                ),
                                title: const Text('갤러리에서 선택'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _imageFile != null ? Colors.orange : Colors.grey,
                          width: _imageFile != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _imageFile != null
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: _imageFile != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(
                                    _imageFile!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imageFile = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    '이미지를 선택해주세요',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('위반 사항', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  // 위반 사항 선택 드롭다운
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedViolationType,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        hint: const Text('위반 사항 유형 선택'),
                        items: _violationTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedViolationType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null && _violationController.text.isEmpty) {
                            return '위반 사항을 선택하거나 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 기타 위반 사항일 경우 상세 설명 필드 표시
                  if (_selectedViolationType == '기타' || _selectedViolationType == null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _violationController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                          ),
                          hintText: _selectedViolationType == '기타' 
                              ? '위반사항을 상세히 입력해주세요' 
                              : '위반사항을 입력해주세요',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (_selectedViolationType == '기타' && (value == null || value.isEmpty)) {
                            return '위반 사항을 입력해주세요';
                          }
                          if (_selectedViolationType == null && (value == null || value.isEmpty)) {
                            return '위반 사항을 선택하거나 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // 신고하기 전 미리보기 버튼
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showPreviewDialog,
                        icon: const Icon(Icons.preview),
                        label: const Text('미리보기 및 신고하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // 도움말 대화상자
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '신고 방법 안내',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. 날짜 입력: 위반 사항을 목격한 날짜를 선택하세요.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '2. 장소 입력: 위반 장소를 최대한 상세히 입력하세요. \'현재 위치 가져오기\' 버튼을 눌러 자동으로 현재 위치를 입력할 수 있습니다.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '3. 이미지 첨부: 위반 사항을 확인할 수 있는 사진을 첨부하세요. 사진은 명확하게 찍어주세요.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '4. 위반 사항 선택: 위반 사항의 유형을 선택하거나, \'기타\'를 선택한 경우 상세 내용을 입력하세요.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '5. 미리보기 및 신고: 입력한 내용을 미리보기로 확인한 후 신고하세요.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '※ 허위 신고나 악의적인 신고는 법적 책임이 따를 수 있습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}