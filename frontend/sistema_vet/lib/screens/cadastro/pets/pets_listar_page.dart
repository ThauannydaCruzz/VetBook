/* Tela de listagem de pets.
 * - Dono logado: vê apenas seus próprios pets
 * - Admin: vê todos os pets com paginação
 * Permite cadastrar e excluir pets. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/pet_model.dart';
import '../../../services/pet_service.dart';
import '../../../services/auth_service.dart';
import 'pet_card.dart';
import 'pet_cadastrar_dialog.dart';
import 'pet_excluir_dialog.dart';

/// Página principal de Pets do dono logado.
/// - Se o usuário for Dono, lista apenas os seus pets (por donoId).
/// - Se for Admin, lista todos os pets.
class PetsListarPage extends StatefulWidget {
  const PetsListarPage({super.key});

  @override
  State<PetsListarPage> createState() => _PetsListarPageState();
}

class _PetsListarPageState extends State<PetsListarPage> {
  List<PetModel> _pets  = [];
  bool _loading         = true;
  String? _error;
  String? _donoId;
  bool _isDono          = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _donoId  = await AuthService.getDonoId();
    _isDono  = await AuthService.isDono();
    await _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      List<PetModel> pets;
      if (_isDono && _donoId != null) {
        // Dono: busca apenas os seus pets
        pets = await PetService.listarPorDono(_donoId!);
      } else {
        // Admin / Veterinário: busca todos
        final result = await PetService.listar(pageSize: 100);
        pets = result.items;
      }
      if (mounted) setState(() { _pets = pets; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _cadastrar() async {
    final criado = await mostrarCadastrarPetDialog(context);
    if (criado) _load();
  }

  Future<void> _excluir(PetModel pet) async {
    final removido = await mostrarExcluirPetDialog(context, pet);
    if (removido) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.07,
              child: Image.asset('assets/logo.png', width: 550, height: 550,
                  fit: BoxFit.contain),
            ),
          ),
          RefreshIndicator(
            onRefresh: _load,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('MEUS PETS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: _cadastrar,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Cadastrar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ]),
                const SizedBox(height: 16),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_error != null)
                  _errorCard()
                else if (_pets.isEmpty)
                  _emptyState()
                else
                  ..._pets.map((p) => PetCard(
                        pet: p,
                        onExcluir: () => _excluir(p),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Text(_error!, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 12),
          TextButton(
              onPressed: _load,
              child: const Text('Tentar novamente')),
        ]),
      );

  Widget _emptyState() => const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: Column(children: [
            Icon(Icons.pets, size: 64, color: AppColors.border),
            SizedBox(height: 12),
            Text('Nenhum pet cadastrado ainda.',
                style: TextStyle(color: AppColors.textMuted)),
            SizedBox(height: 4),
            Text('Toque em "Cadastrar" para adicionar.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ]),
        ),
      );
}
