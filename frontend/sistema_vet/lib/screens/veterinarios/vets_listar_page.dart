/* Tela de listagem de veterinários — exclusiva do painel admin.
 * Exibe todos os veterinários com status ativo/inativo.
 * Permite criar novos veterinários e alternar o status via switch. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/veterinario_model.dart';
import '../../../services/veterinario_service.dart';
import 'vet_card.dart';
import 'vet_cadastrar_dialog.dart';

/// Página de listagem de Veterinários (acesso administrativo).
class VetsListarPage extends StatefulWidget {
  const VetsListarPage({super.key});

  @override
  State<VetsListarPage> createState() => _VetsListarPageState();
}

class _VetsListarPageState extends State<VetsListarPage> {
  List<VeterinarioModel> _vets = [];
  bool _loading                = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await VeterinarioService.listar(pageSize: 50);
      if (mounted) setState(() { _vets = result.items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cadastrar() async {
    final criado = await mostrarCadastrarVetDialog(context);
    if (criado) _load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('VETERINÁRIOS',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    fontSize: 12)),
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: _cadastrar,
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              label: const Text('Novo',
                  style: TextStyle(color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_vets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Nenhum veterinário cadastrado.',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ..._vets.map((v) => VetCard(vet: v, onRefresh: _load)),
        ],
      ),
    );
  }
}
