/* Aba "Perfil" da tela principal.
 * Exibe os dados do usuário logado: nome/CPF e papel (role).
 * Permite escolher uma foto de perfil local (apenas visual — não é enviada ao servidor).
 * O botão "Sair" realiza o logout e redireciona para a tela de login. */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  File? _image;
  String _usuario = '...';
  String _role = '...';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await AuthService.getUsuario();
    final r = await AuthService.getRole();
    if (mounted) setState(() {
      _usuario = u ?? 'Usuário';
      _role = r ?? '';
    });
  }

  Future<void> _pickImage() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f != null && mounted) setState(() => _image = File(f.path));
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Center(child: Opacity(opacity: 0.07,
              child: Image.asset('assets/logo.png', width: 550, fit: BoxFit.contain))),
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primary,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Text(
                              _usuario.isNotEmpty ? _usuario[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: Text(_usuario,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary))),
              Center(child: Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: false ? AppColors.primaryLight : const Color(0xFFE8F3FB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: false ? AppColors.primary : AppColors.secondary,
                    )),
              )),
              const SizedBox(height: 32),
              _infoCard(Icons.person_outline, 'Usuário', _usuario),
              _infoCard(Icons.shield_outlined, 'Perfil de acesso', _role),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Sair da conta', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
        ]),
      );
}
