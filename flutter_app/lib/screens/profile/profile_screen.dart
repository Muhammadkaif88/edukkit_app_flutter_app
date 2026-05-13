import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Edukkit's available courses — update this list as new courses are added.
const List<String> kEdukkitCourses = [
  'Robotics & IoT',
  'Home Automation',
  'Solar Energy Kit',
  'AI + IoT',
  '3D Printing',
  'School STEM Course',
  'VR Immersive Learning',
  'DIY Electronics',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for editable personal fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Academic info — locked for students, editable for admin/teacher
  final _studentIdController = TextEditingController(text: 'EDK-2024-0042');
  String _selectedCourse = kEdukkitCourses.first;

  String _selectedGender = 'Male';
  DateTime? _dob;
  bool _isEditing = false;
  bool _isUploadingPhoto = false;
  Uint8List? _localPhotoBytes; // preview before upload completes

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = auth.userName == 'Guest' ? '' : auth.userName;
  }

  Future<void> _pickAndUploadPhoto() async {
    // Capture provider reference before any async gap
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final source = await _showSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();

    // Show local preview immediately
    setState(() {
      _localPhotoBytes = bytes;
      _isUploadingPhoto = true;
    });

    final url = await auth.uploadProfilePhoto(bytes, ext);

    if (mounted) {
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            url != null ? 'Profile photo updated!' : 'Upload failed. Try again.',
          ),
          backgroundColor:
              url != null ? const Color(0xFF4A40DF) : Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<ImageSource?> _showSourceSheet() async {
    // On web only gallery is supported
    if (identical(0, 0.0)) return ImageSource.gallery; // never true, just keep API
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Update Profile Photo',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEEBFF),
                  child: Icon(Icons.photo_library_outlined,
                      color: Color(0xFF4A40DF)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEEBFF),
                  child: Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF4A40DF)),
                ),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _canEditAcademic(AuthProvider auth) =>
      auth.role == UserRole.admin || auth.role == UserRole.teacher;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF4A40DF)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  String get _dobText {
    if (_dob == null) return 'Select Date of Birth';
    return '${_dob!.day.toString().padLeft(2, '0')}/'
        '${_dob!.month.toString().padLeft(2, '0')}/'
        '${_dob!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final canEditAcademic = _canEditAcademic(auth);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF4A40DF),
            leading: IconButton(
              icon:
                  const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(
                  _isEditing
                      ? Icons.check_circle_outline
                      : Icons.edit_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  _isEditing ? 'Save' : 'Edit',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5B52F0), Color(0xFF3B30C8)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.white,
                              backgroundImage: _localPhotoBytes != null
                                  ? MemoryImage(_localPhotoBytes!)
                                  : auth.userPhotoUrl != null
                                      ? NetworkImage(auth.userPhotoUrl!)
                                          as ImageProvider
                                      : null,
                              child: (_localPhotoBytes == null &&
                                      auth.userPhotoUrl == null)
                                  ? const Icon(Icons.person,
                                      size: 56,
                                      color: Color(0xFF4A40DF))
                                  : null,
                            ),
                          ),
                          // Upload progress overlay
                          if (_isUploadingPhoto)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Colors.black.withValues(alpha: 0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Camera button
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingPhoto
                                  ? null
                                  : _pickAndUploadPhoto,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: _isUploadingPhoto
                                      ? Colors.grey.shade400
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Color(0xFF4A40DF), size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Text(
                        auth.userName == 'Guest'
                            ? 'Your Name'
                            : auth.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          auth.role.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Academic Info ──────────────────────────────────
                  _buildSectionCard(
                    title: 'Academic Info',
                    icon: Icons.school_outlined,
                    children: [
                      // Student ID — locked for students
                      _buildInfoRow(
                        Icons.badge_outlined,
                        'Student ID',
                        _studentIdController,
                        enabled: _isEditing && canEditAcademic,
                        lockedForStudent: !canEditAcademic,
                      ),
                      _buildDivider(),
                      // Course — dropdown, locked for students
                      _buildCourseDropdown(
                        canEdit: _isEditing && canEditAcademic,
                        lockedForStudent: !canEditAcademic,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Personal Details ───────────────────────────────
                  _buildSectionCard(
                    title: 'Personal Details',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow(
                        Icons.person_outline,
                        'Full Name',
                        _nameController,
                        enabled: _isEditing,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.mail_outline,
                        'Email',
                        _emailController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        hint: 'Enter your email',
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Phone Number',
                        _phoneController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        hint: 'Enter phone number',
                      ),
                      _buildDivider(),
                      // Gender dropdown
                      _buildGenderRow(),
                      _buildDivider(),
                      // DOB picker
                      _buildDobRow(),
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Address',
                        _addressController,
                        enabled: _isEditing,
                        hint: 'Enter your address',
                        maxLines: 2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Save button (edit mode only)
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile saved successfully!'),
                              backgroundColor: Color(0xFF4A40DF),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A40DF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Course Dropdown ─────────────────────────────────────────────────
  Widget _buildCourseDropdown({
    required bool canEdit,
    required bool lockedForStudent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.menu_book_outlined,
              color: Color(0xFF4A40DF), size: 22),
          const SizedBox(width: 16),
          const SizedBox(
            width: 110,
            child: Text(
              'Course',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: canEdit
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCourse,
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2D2D2D),
                        fontWeight: FontWeight.w500,
                      ),
                      items: kEdukkitCourses
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCourse = v!),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedCourse,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF2D2D2D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (lockedForStudent)
                        const Icon(Icons.lock_outline,
                            size: 15, color: Colors.grey),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Gender Dropdown ─────────────────────────────────────────────────
  Widget _buildGenderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.wc_outlined,
              color: Color(0xFF4A40DF), size: 22),
          const SizedBox(width: 16),
          const SizedBox(
            width: 110,
            child: Text(
              'Gender',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: _isEditing
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2D2D2D),
                        fontWeight: FontWeight.w500,
                      ),
                      items: _genderOptions
                          .map((g) =>
                              DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedGender = v!),
                    ),
                  )
                : Text(
                    _selectedGender,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── DOB Picker ──────────────────────────────────────────────────────
  Widget _buildDobRow() {
    return GestureDetector(
      onTap: _isEditing ? _pickDate : null,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined,
                color: Color(0xFF4A40DF), size: 22),
            const SizedBox(width: 16),
            const SizedBox(
              width: 110,
              child: Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                _dobText,
                style: TextStyle(
                  fontSize: 15,
                  color: _dob == null
                      ? Colors.grey.shade400
                      : const Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_isEditing)
              const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF4A40DF), size: 18),
          ],
        ),
      ),
    );
  }

  // ── Section Card ────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4A40DF), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // ── Info Row (text field) ───────────────────────────────────────────
  Widget _buildInfoRow(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool enabled = false,
    bool lockedForStudent = false,
    TextInputType? keyboardType,
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF4A40DF), size: 22),
          const SizedBox(width: 16),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint ?? label,
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (lockedForStudent && !enabled)
            const Icon(Icons.lock_outline,
                size: 15, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, indent: 54, endIndent: 16);
}
