import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class CountryModel {
  final String code;
  final String flag;
  final String name;

  const CountryModel({
    required this.code,
    required this.flag,
    required this.name,
  });
}

const List<CountryModel> _countries = [
  CountryModel(code: '+93', flag: '🇦🇫', name: 'Afghanistan'),
  CountryModel(code: '+355', flag: '🇦🇱', name: 'Albania'),
  CountryModel(code: '+213', flag: '🇩🇿', name: 'Algeria'),
  CountryModel(code: '+376', flag: '🇦🇩', name: 'Andorra'),
  CountryModel(code: '+244', flag: '🇦🇴', name: 'Angola'),
  CountryModel(code: '+1-268', flag: '🇦🇬', name: 'Antigua and Barbuda'),
  CountryModel(code: '+54', flag: '🇦🇷', name: 'Argentina'),
  CountryModel(code: '+374', flag: '🇦🇲', name: 'Armenia'),
  CountryModel(code: '+61', flag: '🇦🇺', name: 'Australia'),
  CountryModel(code: '+43', flag: '🇦🇹', name: 'Austria'),
  CountryModel(code: '+994', flag: '🇦🇿', name: 'Azerbaijan'),
  CountryModel(code: '+1-242', flag: '🇧🇸', name: 'Bahamas'),
  CountryModel(code: '+973', flag: '🇧🇭', name: 'Bahrain'),
  CountryModel(code: '+880', flag: '🇧🇩', name: 'Bangladesh'),
  CountryModel(code: '+1-246', flag: '🇧🇧', name: 'Barbados'),
  CountryModel(code: '+375', flag: '🇧🇾', name: 'Belarus'),
  CountryModel(code: '+32', flag: '🇧🇪', name: 'Belgium'),
  CountryModel(code: '+501', flag: '🇧🇿', name: 'Belize'),
  CountryModel(code: '+229', flag: '🇧🇯', name: 'Benin'),
  CountryModel(code: '+975', flag: '🇧🇹', name: 'Bhutan'),
  CountryModel(code: '+591', flag: '🇧🇴', name: 'Bolivia'),
  CountryModel(code: '+387', flag: '🇧🇦', name: 'Bosnia and Herzegovina'),
  CountryModel(code: '+267', flag: '🇧🇼', name: 'Botswana'),
  CountryModel(code: '+55', flag: '🇧🇷', name: 'Brazil'),
  CountryModel(code: '+673', flag: '🇧🇳', name: 'Brunei'),
  CountryModel(code: '+359', flag: '🇧🇬', name: 'Bulgaria'),
  CountryModel(code: '+226', flag: '🇧🇫', name: 'Burkina Faso'),
  CountryModel(code: '+257', flag: '🇧🇮', name: 'Burundi'),
  CountryModel(code: '+238', flag: '🇨🇻', name: 'Cabo Verde'),
  CountryModel(code: '+855', flag: '🇰🇭', name: 'Cambodia'),
  CountryModel(code: '+237', flag: '🇨🇲', name: 'Cameroon'),
  CountryModel(code: '+1', flag: '🇨🇦', name: 'Canada'),
  CountryModel(code: '+236', flag: '🇨🇫', name: 'Central African Republic'),
  CountryModel(code: '+235', flag: '🇹🇩', name: 'Chad'),
  CountryModel(code: '+56', flag: '🇨🇱', name: 'Chile'),
  CountryModel(code: '+86', flag: '🇨🇳', name: 'China'),
  CountryModel(code: '+57', flag: '🇨🇴', name: 'Colombia'),
  CountryModel(code: '+269', flag: '🇰🇲', name: 'Comoros'),
  CountryModel(code: '+242', flag: '🇨🇬', name: 'Congo'),
  CountryModel(code: '+243', flag: '🇨🇩', name: 'DR Congo'),
  CountryModel(code: '+506', flag: '🇨🇷', name: 'Costa Rica'),
  CountryModel(code: '+385', flag: '🇭🇷', name: 'Croatia'),
  CountryModel(code: '+53', flag: '🇨🇺', name: 'Cuba'),
  CountryModel(code: '+357', flag: '🇨🇾', name: 'Cyprus'),
  CountryModel(code: '+420', flag: '🇨🇿', name: 'Czechia'),
  CountryModel(code: '+45', flag: '🇩🇰', name: 'Denmark'),
  CountryModel(code: '+253', flag: '🇩🇯', name: 'Djibouti'),
  CountryModel(code: '+1-767', flag: '🇩🇲', name: 'Dominica'),
  CountryModel(code: '+1-809', flag: '🇩🇴', name: 'Dominican Republic'),
  CountryModel(code: '+593', flag: '🇪🇨', name: 'Ecuador'),
  CountryModel(code: '+20', flag: '🇪🇬', name: 'Egypt'),
  CountryModel(code: '+503', flag: '🇸🇻', name: 'El Salvador'),
  CountryModel(code: '+240', flag: '🇬🇶', name: 'Equatorial Guinea'),
  CountryModel(code: '+291', flag: '🇪🇷', name: 'Eritrea'),
  CountryModel(code: '+372', flag: '🇪🇪', name: 'Estonia'),
  CountryModel(code: '+268', flag: '🇸🇿', name: 'Eswatini'),
  CountryModel(code: '+251', flag: '🇪🇹', name: 'Ethiopia'),
  CountryModel(code: '+679', flag: '🇫🇯', name: 'Fiji'),
  CountryModel(code: '+358', flag: '🇫🇮', name: 'Finland'),
  CountryModel(code: '+33', flag: '🇫🇷', name: 'France'),
  CountryModel(code: '+241', flag: '🇬🇦', name: 'Gabon'),
  CountryModel(code: '+220', flag: '🇬🇲', name: 'Gambia'),
  CountryModel(code: '+995', flag: '🇬🇪', name: 'Georgia'),
  CountryModel(code: '+49', flag: '🇩🇪', name: 'Germany'),
  CountryModel(code: '+233', flag: '🇬🇭', name: 'Ghana'),
  CountryModel(code: '+30', flag: '🇬🇷', name: 'Greece'),
  CountryModel(code: '+1-473', flag: '🇬🇩', name: 'Grenada'),
  CountryModel(code: '+502', flag: '🇬🇹', name: 'Guatemala'),
  CountryModel(code: '+224', flag: '🇬🇳', name: 'Guinea'),
  CountryModel(code: '+245', flag: '🇬🇼', name: 'Guinea-Bissau'),
  CountryModel(code: '+592', flag: '🇬🇾', name: 'Guyana'),
  CountryModel(code: '+509', flag: '🇭🇹', name: 'Haiti'),
  CountryModel(code: '+504', flag: '🇭🇳', name: 'Honduras'),
  CountryModel(code: '+36', flag: '🇭🇺', name: 'Hungary'),
  CountryModel(code: '+354', flag: '🇮🇸', name: 'Iceland'),
  CountryModel(code: '+91', flag: '🇮🇳', name: 'India'),
  CountryModel(code: '+62', flag: '🇮🇩', name: 'Indonesia'),
  CountryModel(code: '+98', flag: '🇮🇷', name: 'Iran'),
  CountryModel(code: '+964', flag: '🇮🇶', name: 'Iraq'),
  CountryModel(code: '+353', flag: '🇮🇪', name: 'Ireland'),
  CountryModel(code: '+972', flag: '🇮🇱', name: 'Israel'),
  CountryModel(code: '+39', flag: '🇮🇹', name: 'Italy'),
  CountryModel(code: '+1-876', flag: '🇯🇲', name: 'Jamaica'),
  CountryModel(code: '+81', flag: '🇯🇵', name: 'Japan'),
  CountryModel(code: '+962', flag: '🇯🇴', name: 'Jordan'),
  CountryModel(code: '+7', flag: '🇰🇿', name: 'Kazakhstan'),
  CountryModel(code: '+254', flag: '🇰🇪', name: 'Kenya'),
  CountryModel(code: '+686', flag: '🇰🇮', name: 'Kiribati'),
  CountryModel(code: '+850', flag: '🇰🇵', name: 'North Korea'),
  CountryModel(code: '+82', flag: '🇰🇷', name: 'South Korea'),
  CountryModel(code: '+965', flag: '🇰🇼', name: 'Kuwait'),
  CountryModel(code: '+996', flag: '🇰🇬', name: 'Kyrgyzstan'),
  CountryModel(code: '+856', flag: '🇱🇦', name: 'Laos'),
  CountryModel(code: '+371', flag: '🇱🇻', name: 'Latvia'),
  CountryModel(code: '+961', flag: '🇱🇧', name: 'Lebanon'),
  CountryModel(code: '+266', flag: '🇱🇸', name: 'Lesotho'),
  CountryModel(code: '+231', flag: '🇱🇷', name: 'Liberia'),
  CountryModel(code: '+218', flag: '🇱🇾', name: 'Libya'),
  CountryModel(code: '+423', flag: '🇱🇮', name: 'Liechtenstein'),
  CountryModel(code: '+370', flag: '🇱🇹', name: 'Lithuania'),
  CountryModel(code: '+352', flag: '🇱🇺', name: 'Luxembourg'),
  CountryModel(code: '+389', flag: '🇲🇰', name: 'North Macedonia'),
  CountryModel(code: '+261', flag: '🇲🇬', name: 'Madagascar'),
  CountryModel(code: '+265', flag: '🇲🇼', name: 'Malawi'),
  CountryModel(code: '+60', flag: '🇲🇾', name: 'Malaysia'),
  CountryModel(code: '+960', flag: '🇲🇻', name: 'Maldives'),
  CountryModel(code: '+223', flag: '🇲🇱', name: 'Mali'),
  CountryModel(code: '+356', flag: '🇲🇹', name: 'Malta'),
  CountryModel(code: '+692', flag: '🇲🇭', name: 'Marshall Islands'),
  CountryModel(code: '+222', flag: '🇲🇷', name: 'Mauritania'),
  CountryModel(code: '+230', flag: '🇲🇺', name: 'Mauritius'),
  CountryModel(code: '+52', flag: '🇲🇽', name: 'Mexico'),
  CountryModel(code: '+691', flag: '🇫🇲', name: 'Micronesia'),
  CountryModel(code: '+373', flag: '🇲🇩', name: 'Moldova'),
  CountryModel(code: '+377', flag: '🇲🇨', name: 'Monaco'),
  CountryModel(code: '+976', flag: '🇲🇳', name: 'Mongolia'),
  CountryModel(code: '+382', flag: '🇲🇪', name: 'Montenegro'),
  CountryModel(code: '+212', flag: '🇲🇦', name: 'Morocco'),
  CountryModel(code: '+258', flag: '🇲🇿', name: 'Mozambique'),
  CountryModel(code: '+95', flag: '🇲🇲', name: 'Myanmar'),
  CountryModel(code: '+264', flag: '🇳🇦', name: 'Namibia'),
  CountryModel(code: '+674', flag: '🇳🇷', name: 'Nauru'),
  CountryModel(code: '+977', flag: '🇳🇵', name: 'Nepal'),
  CountryModel(code: '+31', flag: '🇳🇱', name: 'Netherlands'),
  CountryModel(code: '+64', flag: '🇳🇿', name: 'New Zealand'),
  CountryModel(code: '+505', flag: '🇳🇮', name: 'Nicaragua'),
  CountryModel(code: '+227', flag: '🇳🇪', name: 'Niger'),
  CountryModel(code: '+234', flag: '🇳🇬', name: 'Nigeria'),
  CountryModel(code: '+47', flag: '🇳🇴', name: 'Norway'),
  CountryModel(code: '+968', flag: '🇴🇲', name: 'Oman'),
  CountryModel(code: '+92', flag: '🇵🇰', name: 'Pakistan'),
  CountryModel(code: '+680', flag: '🇵🇼', name: 'Palau'),
  CountryModel(code: '+970', flag: '🇵🇸', name: 'Palestine'),
  CountryModel(code: '+507', flag: '🇵🇦', name: 'Panama'),
  CountryModel(code: '+675', flag: '🇵🇬', name: 'Papua New Guinea'),
  CountryModel(code: '+595', flag: '🇵🇾', name: 'Paraguay'),
  CountryModel(code: '+51', flag: '🇵🇪', name: 'Peru'),
  CountryModel(code: '+63', flag: '🇵🇭', name: 'Philippines'),
  CountryModel(code: '+48', flag: '🇵🇱', name: 'Poland'),
  CountryModel(code: '+351', flag: '🇵🇹', name: 'Portugal'),
  CountryModel(code: '+974', flag: '🇶🇦', name: 'Qatar'),
  CountryModel(code: '+40', flag: '🇷🇴', name: 'Romania'),
  CountryModel(code: '+7', flag: '🇷🇺', name: 'Russia'),
  CountryModel(code: '+250', flag: '🇷🇼', name: 'Rwanda'),
  CountryModel(code: '+1-767', flag: '🇰🇳', name: 'Saint Kitts and Nevis'),
  CountryModel(code: '+1-758', flag: '🇱🇨', name: 'Saint Lucia'),
  CountryModel(code: '+1-784', flag: '🇻🇨', name: 'Saint Vincent and the Grenadines'),
  CountryModel(code: '+685', flag: '🇼🇸', name: 'Samoa'),
  CountryModel(code: '+378', flag: '🇸🇲', name: 'San Marino'),
  CountryModel(code: '+239', flag: '🇸🇹', name: 'Sao Tome and Principe'),
  CountryModel(code: '+966', flag: '🇸🇦', name: 'Saudi Arabia'),
  CountryModel(code: '+221', flag: '🇸🇳', name: 'Senegal'),
  CountryModel(code: '+381', flag: '🇷🇸', name: 'Serbia'),
  CountryModel(code: '+248', flag: '🇸🇨', name: 'Seychelles'),
  CountryModel(code: '+232', flag: '🇸🇱', name: 'Sierra Leone'),
  CountryModel(code: '+65', flag: '🇸🇬', name: 'Singapore'),
  CountryModel(code: '+421', flag: '🇸🇰', name: 'Slovakia'),
  CountryModel(code: '+386', flag: '🇸🇮', name: 'Slovenia'),
  CountryModel(code: '+677', flag: '🇸🇧', name: 'Solomon Islands'),
  CountryModel(code: '+252', flag: '🇸🇴', name: 'Somalia'),
  CountryModel(code: '+27', flag: '🇿🇦', name: 'South Africa'),
  CountryModel(code: '+211', flag: '🇸🇸', name: 'South Sudan'),
  CountryModel(code: '+34', flag: '🇪🇸', name: 'Spain'),
  CountryModel(code: '+94', flag: '🇱🇰', name: 'Sri Lanka'),
  CountryModel(code: '+249', flag: '🇸🇩', name: 'Sudan'),
  CountryModel(code: '+597', flag: '🇸🇷', name: 'Suriname'),
  CountryModel(code: '+46', flag: '🇸🇪', name: 'Sweden'),
  CountryModel(code: '+41', flag: '🇨🇭', name: 'Switzerland'),
  CountryModel(code: '+963', flag: '🇸🇾', name: 'Syria'),
  CountryModel(code: '+886', flag: '🇹🇼', name: 'Taiwan'),
  CountryModel(code: '+992', flag: '🇹🇯', name: 'Tajikistan'),
  CountryModel(code: '+255', flag: '🇹🇿', name: 'Tanzania'),
  CountryModel(code: '+66', flag: '🇹🇭', name: 'Thailand'),
  CountryModel(code: '+670', flag: '🇹🇱', name: 'Timor-Leste'),
  CountryModel(code: '+228', flag: '🇹🇬', name: 'Togo'),
  CountryModel(code: '+690', flag: '🇹🇰', name: 'Tokelau'),
  CountryModel(code: '+676', flag: '🇹🇴', name: 'Tonga'),
  CountryModel(code: '+1-868', flag: '🇹🇹', name: 'Trinidad and Tobago'),
  CountryModel(code: '+216', flag: '🇹🇳', name: 'Tunisia'),
  CountryModel(code: '+90', flag: '🇹🇷', name: 'Turkey'),
  CountryModel(code: '+993', flag: '🇹🇲', name: 'Turkmenistan'),
  CountryModel(code: '+688', flag: '🇹🇻', name: 'Tuvalu'),
  CountryModel(code: '+256', flag: '🇺🇬', name: 'Uganda'),
  CountryModel(code: '+380', flag: '🇺🇦', name: 'Ukraine'),
  CountryModel(code: '+971', flag: '🇦🇪', name: 'UAE'),
  CountryModel(code: '+44', flag: '🇬🇧', name: 'United Kingdom'),
  CountryModel(code: '+1', flag: '🇺🇸', name: 'United States'),
  CountryModel(code: '+598', flag: '🇺🇾', name: 'Uruguay'),
  CountryModel(code: '+998', flag: '🇺🇿', name: 'Uzbekistan'),
  CountryModel(code: '+678', flag: '🇻🇺', name: 'Vanuatu'),
  CountryModel(code: '+39', flag: '🇻🇦', name: 'Vatican'),
  CountryModel(code: '+58', flag: '🇻🇪', name: 'Venezuela'),
  CountryModel(code: '+84', flag: '🇻🇳', name: 'Vietnam'),
  CountryModel(code: '+967', flag: '🇾🇪', name: 'Yemen'),
  CountryModel(code: '+260', flag: '🇿🇲', name: 'Zambia'),
  CountryModel(code: '+263', flag: '🇿🇼', name: 'Zimbabwe'),
];

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  CountryModel _selectedCountry = _countries[0]; // Default to UAE (+971)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _smsController = TextEditingController();
  bool _codeSent = false;
  bool _isEmailAuth = true; // Default to email auth
  bool _isSignUp = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _smsController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    String filterQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF070F1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCountries = _countries.where((c) {
              return c.name.toLowerCase().contains(filterQuery.toLowerCase()) ||
                  c.code.contains(filterQuery);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      // Pull handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select Country Code',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      TextField(
                        onChanged: (val) {
                          setModalState(() {
                            filterQuery = val;
                          });
                        },
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by country name or code...',
                          hintStyle: GoogleFonts.outfit(color: const Color(0xFF3F5575), fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00E676), size: 20),
                          filled: true,
                          fillColor: const Color(0xFF070F1C),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF00E676),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredCountries.length,
                          itemBuilder: (context, index) {
                            final country = filteredCountries[index];
                            final isSelected = country.code == _selectedCountry.code && country.flag == _selectedCountry.flag;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCountry = country;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF00E676).withValues(alpha: 0.08) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF00E676).withValues(alpha: 0.2) : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      country.flag,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        country.name,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      country.code,
                                      style: GoogleFonts.outfit(
                                        color: isSelected ? const Color(0xFF00E676) : const Color(0xFF8FA3C8),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _submit() async {
    HapticFeedback.mediumImpact();
    final auth = context.read<AuthProvider>();

    if (_isEmailAuth) {
      if (_isSignUp) {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: AppTheme.qalqalahRed,
          ));
          return;
        }
        await auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      } else {
        await auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } else {
      if (_codeSent) {
        await auth.signInWithSmsCode(_smsController.text.trim());
      } else {
        String phoneInput = _phoneController.text.trim();
        if (!phoneInput.startsWith('+')) {
          if (phoneInput.startsWith('0')) {
            phoneInput = phoneInput.substring(1);
          }
          phoneInput = '${_selectedCountry.code}$phoneInput';
        }
        await auth.verifyPhoneNumber(phoneInput);
        if (auth.error == null && mounted) {
          _fadeController.reset();
          _slideController.reset();
          setState(() => _codeSent = true);
          _fadeController.forward();
          _slideController.forward();
        }
      }
    }

    if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error!),
        backgroundColor: AppTheme.qalqalahRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = controller.text.trim();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await context.read<AuthProvider>().sendPasswordResetEmail(email);
              if (!mounted) return;
              navigator.pop();
              messenger.showSnackBar(const SnackBar(
                content: Text('Reset link sent! Please check your email.'),
                backgroundColor: AppTheme.primaryGreen,
              ));
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF070D16),
      body: Stack(
        children: [
          // ─── Background ────────────────────────────────────────────────
          const Positioned.fill(child: _AuthBackground()),

          // ─── Scrollable Content ────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ─── Logo ─────────────────────────────────────
                        _buildLogo(),
                        const SizedBox(height: 32),

                        // ─── Glassmorphic Card ─────────────────────────
                        _buildFormCard(auth),

                        const SizedBox(height: 24),

                        // ─── Learners Capsule ──────────────────────────
                        _buildLearnersCapsule(),
                        const SizedBox(height: 24),
                        Text(
                          'By continuing, you agree to our Terms & Privacy Policy',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF4A5A7A),
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo container with green glowing border and crescent moon
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A2318), Color(0xFF030D0A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withValues(alpha: 0.18),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.dark_mode_rounded,
              color: Color(0xFFFFC107), // beautiful golden yellow crescent moon
              size: 46,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Tajwid AI',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'MASTER THE ART OF RECITATION',
            style: GoogleFonts.outfit(
              fontSize: 11,
              letterSpacing: 1.5,
              color: const Color(0xFF00E676),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(AuthProvider auth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1420).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Mode Toggle (Phone/Email) ───
              if (!_codeSent) ...[
                _buildAuthModeToggle(),
                const SizedBox(height: 28),
              ],

              // Header
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Column(
                  key: ValueKey('${_codeSent}_${_isEmailAuth}_$_isSignUp'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _codeSent
                              ? 'Verify your number'
                              : (_isEmailAuth 
                                  ? (_isSignUp ? 'Create Account' : 'Welcome Back') 
                                  : 'Sign in with Phone'),
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _codeSent
                              ? 'Enter the 6-digit code sent to your phone'
                              : (_isEmailAuth 
                                  ? (_isSignUp ? 'Join the community & master recitation' : 'Log in to continue your progress')
                                  : 'We\'ll send you a verification code'),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: const Color(0xFF8FA3C8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Fields
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _codeSent
                    ? _buildOTPField()
                    : (_isEmailAuth ? _buildEmailFields() : _buildPhoneField()),
              ),

              if (_isEmailAuth && !_isSignUp) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00E676),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 28),
              ],

              // CTA Button
              _buildSubmitButton(auth),

              // ─── Switch Login/Signup Divider & Toggle ───
              if (!_codeSent && _isEmailAuth) ...[
                const SizedBox(height: 24),
                Divider(
                  color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 24),
                _buildSignupToggle(),
              ],

              // Back to phone
              if (_codeSent) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _fadeController.reset();
                      _slideController.reset();
                      setState(() => _codeSent = false);
                      _fadeController.forward();
                      _slideController.forward();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8FA3C8),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14),
                    label: Text(
                      'Change Phone Number',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeToggle() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF060B12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleItem('Email', _isEmailAuth, () => setState(() => _isEmailAuth = true)),
          _buildToggleItem('Phone', !_isEmailAuth, () => setState(() => _isEmailAuth = false)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E676).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF003018) : const Color(0xFF8FA3C8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupToggle() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _isSignUp = !_isSignUp),
        child: RichText(
          text: TextSpan(
            text: _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8FA3C8),
            ),
            children: [
              TextSpan(
                text: _isSignUp ? 'Log In' : 'Sign Up',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00E676),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailFields() {
    return Column(
      key: const ValueKey('email_fields'),
      children: [
        if (_isSignUp) ...[
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Your name',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 20),
        ],
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'you@example.com',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_rounded,
          obscureText: !_showPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: const Color(0xFF8FA3C8),
              size: 20,
            ),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ),
        if (_isSignUp) ...[
          const SizedBox(height: 20),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: '••••••••',
            icon: Icons.lock_clock_rounded,
            obscureText: !_showConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: const Color(0xFF8FA3C8),
                size: 20,
              ),
              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8FA3C8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: const Color(0xFF3F5575), fontSize: 15),
            prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF070F1C),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF00E676),
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8FA3C8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '50 123 4567',
            hintStyle: GoogleFonts.outfit(color: const Color(0xFF3F5575), fontSize: 15),
            filled: true,
            fillColor: const Color(0xFF070F1C),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF00E676),
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            prefixIcon: GestureDetector(
              onTap: _showCountryPicker,
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00E676).withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountry.code,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Color(0xFF8FA3C8),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPField() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Code',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8FA3C8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _smsController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: const Color(0xFF00E676),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: GoogleFonts.outfit(
              color: const Color(0xFF3F5575),
              fontSize: 28,
              letterSpacing: 12,
            ),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFF070F1C),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF00E676),
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF1E2D4A).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.message_rounded,
                  color: Color(0xFF00E676), size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: auth.isLoading ? const Color(0xFF00C853) : const Color(0xFF00E676),
          borderRadius: BorderRadius.circular(16),
          boxShadow: auth.isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: auth.isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: const Color(0xFF003018),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: auth.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF003018),
                  ),
                )
              : Text(
                  _codeSent ? 'Verify Code ✓' : (_isEmailAuth ? (_isSignUp ? 'Sign Up' : 'Log In') : 'Send Code →'),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLearnersCapsule() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1624),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF1E2D4A).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF2E2413),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Color(0xFFFFB300),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '5,432 learners practicing today',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: const Color(0xFF8FA3C8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Background
// ─────────────────────────────────────────────────────────────────────────────
class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF002921), // Slate green top
            Color(0xFF070D16), // Sleek dark slate blue-black bottom
          ],
        ),
      ),
    );
  }
}
