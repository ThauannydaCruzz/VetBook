/* Tela de listagem de donos/tutores — exclusiva do painel admin.
 * Exibe todos os donos cadastrados com paginação e permite criar novos
 * via o dialog de cadastro. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/dono_model.dart';
import '../../../services/dono_service.dart';
import 'dono_card.dart';
import 'dono_cadastrar_dialog.dart';

/// Página de listagem de Donos (acesso administrativo).
class DonosListarPage extends StatefulWidget {
  const DonosListarPage({super.key});

  @override
  State<DonosListarPage> createState() => _DonosListarPageState();
}

class _DonosListarPageState extends State<DonosListarPage> {
  List<DonoModel> _donos = [];
  bool _loading          = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await DonoService.listar(pageSize: 50);
      if (mounted) setState(() { _donos = result.items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cadastrar() async {
    final criado = await mostrarCadastrarDonoDialog(context);
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
            const Text('TUTORES / DONOS',
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
            ))
          else if (_donos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Nenhum dono cadastrado.',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ..._donos.map((d) => DonoCard(dono: d)),
        ],
      ),
    );
  }
}
