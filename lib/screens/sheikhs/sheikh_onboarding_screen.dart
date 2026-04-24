import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/sheikh_model.dart';

class SheikhOnboardingScreen extends StatefulWidget {
  const SheikhOnboardingScreen({super.key});

  @override
  State<SheikhOnboardingScreen> createState() => _SheikhOnboardingScreenState();
}

class _SheikhOnboardingScreenState extends State<SheikhOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Controllers
  final _englishNameController = TextEditingController();
  final _masjidController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _groupSizeController = TextEditingController();
  
  bool _offersGroupClasses = false;
  
  final List<String> _selectedSpecializations = [];
  final List<String> _availableSpecializations = [
    'Hafs an Asim',
    'Warsh an Nafi',
    'Qalun an Nafi',
    'Al-Duri an Abu Amr',
    'Shu\'bah an Asim',
    'Khalaf an Hamzah',
    'Ten Qira\'at',
    'Tajwid Theory',
    'Hifz Memorization',
    'Noorani Qaida',
    'Maqamat',
    'Tafsir',
    'Quranic Arabic',
    'Child Education',
    'Female Only Classes',
  ];

  @override
  void initState() {
    super.initState();
    _priceController.text = '500';
    _groupSizeController.text = '5';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user != null && _phoneController.text.isEmpty) {
      _phoneController.text = user.phone;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Scholar Onboarding'),
        leading: _currentPage > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            )
          : null,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildIntroStep(),
                _buildPersonalInfoStep(),
                _buildProfessionalInfoStep(),
                _buildSpecializationStep(),
                _buildPricingSettingsStep(),
                _buildSummaryStep(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(6, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentPage 
                  ? AppTheme.primaryGreen 
                  : AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIntroStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories, size: 80, color: AppTheme.primaryGreen),
          const SizedBox(height: 24),
          const Text(
            'Join as a Tajwid Scholar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Share your knowledge and help students worldwide perfect their Quranic recitation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),
          _buildRequirementTile(Icons.check_circle, 'Personalized student feedback'),
          _buildRequirementTile(Icons.check_circle, 'Issue digital Ijazah certificates'),
          _buildRequirementTile(Icons.check_circle, 'Manage your own student lists'),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildTextField(
            'Full Name (English)', 
            _englishNameController, 
            hint: 'e.g. Sheikh Ahmed',
          ),
          const SizedBox(height: 16),
          _buildTextField('Contact Phone', _phoneController, hint: '+91 ...'),
          const SizedBox(height: 16),
          _buildTextField('Brief Bio', _bioController, hint: 'Years of experience, teachers, etc.', maxLines: 5),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Affiliation & Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildTextField('Masjid / Institution', _masjidController, hint: 'e.g. Masjid Al-Haram'),
          const SizedBox(height: 16),
          _buildTextField('City', _cityController, hint: 'e.g. Medina'),
        ],
      ),
    );
  }

  Widget _buildSpecializationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Specializations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Select the areas you are qualified to teach:', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSpecializations.map((spec) {
              final isSelected = _selectedSpecializations.contains(spec);
              return FilterChip(
                label: Text(
                  spec,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryGreen : Colors.black87,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecializations.add(spec);
                    } else {
                      _selectedSpecializations.remove(spec);
                    }
                  });
                },
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryGreen,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pricing & Class Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildTextField(
            'Session Price (₹)', 
            _priceController, 
            hint: 'e.g. 500',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Offer Group Classes', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Allow up to 5 students in a single session'),
            value: _offersGroupClasses,
            activeColor: AppTheme.primaryGreen,
            onChanged: (val) => setState(() => _offersGroupClasses = val),
          ),
          if (_offersGroupClasses) ...[
            const SizedBox(height: 16),
            _buildTextField(
              'Max Group Size', 
              _groupSizeController, 
              hint: 'e.g. 5',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Icon(Icons.verified_user, size: 64, color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text('Review your Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSummaryItem('Scholar Name', _englishNameController.text),
          _buildSummaryItem('Bio', _bioController.text),
          _buildSummaryItem('Masjid', _masjidController.text),
          _buildSummaryItem('City', _cityController.text),
          _buildSummaryItem('Specializations', _selectedSpecializations.join(', ')),
          _buildSummaryItem('Pricing', '₹${_priceController.text} / session'),
          _buildSummaryItem('Group Classes', _offersGroupClasses ? 'Enabled (Max ${_groupSizeController.text})' : 'Disabled'),
          const SizedBox(height: 24),
          const Text(
            'By submitting, you agree to provide authentic and accurate feedback to students following the principles of Tajwid.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryGreen)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? 'Not provided' : value, style: const TextStyle(fontSize: 15)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final authProvider = context.watch<AuthProvider>();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _onNext,
              child: authProvider.isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_currentPage == 5 ? 'Complete' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _onNext() async {
    if (!_validateCurrentStep()) return;
    
    if (_currentPage < 5) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      await _submit();
    }
  }

  bool _validateCurrentStep() {
    String? error;
    if (_currentPage == 1) {
      if (_englishNameController.text.trim().isEmpty) {
        error = 'Please enter your name';
      } else if (_bioController.text.trim().length < 20) {
        error = 'Bio must be at least 20 characters';
      }
    } else if (_currentPage == 2) {
      if (_masjidController.text.trim().isEmpty) {
        error = 'Please enter your masjid or institution';
      } else if (_cityController.text.trim().isEmpty) {
        error = 'Please enter your city';
      }
    } else if (_currentPage == 3) {
      if (_selectedSpecializations.isEmpty) {
        error = 'Please select at least one specialization';
      }
    } else if (_currentPage == 4) {
      if (_priceController.text.isEmpty) {
        error = 'Please enter a session price';
      }
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final sheikhData = SheikhModel(
      id: user.uid,
      name: user.name,
      englishName: _englishNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: user.email ?? '',
      masjid: _masjidController.text.trim(),
      city: _cityController.text.trim(),
      specializations: _selectedSpecializations,
      bio: _bioController.text.trim(),
      pricePerSession: int.tryParse(_priceController.text) ?? 0,
      offersGroupClasses: _offersGroupClasses,
      groupClassSize: int.tryParse(_groupSizeController.text) ?? 5,
      isVerified: true, // Default to true for development
      isAvailable: true,
    );

    await auth.upgradeToSheikh(sheikhData);
    
    if (mounted) {
      if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
      } else {
        Navigator.pop(context); // Close onboarding
      }
    }
  }

  @override
  void dispose() {
    _englishNameController.dispose();
    _masjidController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _groupSizeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, int maxLines = 1, TextDirection? textDirection, List<TextInputFormatter>? inputFormatters, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textDirection: textDirection,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
