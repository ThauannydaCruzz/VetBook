/* Tela de listagem de consultas (versão alternativa ao ConsultasPage).
 * - Dono: vê apenas consultas cujo pet é seu (filtrado por donoId)
 * - Admin: vê todas as consultas com possibilidade de filtro
 * Pode ter sido substituída pela ConsultasPage dentro do MainScreen. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/consulta_model.dart';
import '../../../services/consulta_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/pet_service.dart';
import 'consulta_card.dart';
import 'consulta_cancelar_dialog.dart';

/// Página de listagem de consultas.
/// - Dono: exibe apenas consultas dos seus pets.
/// - Admin/Veterinário: exibe todas as consultas.
class ConsultasListarPage extends StatefulWidget {
  const ConsultasListarPage({super.key});

  @override
  State<ConsultasListarPage> createState() => _ConsultasListarPageState();
}

class _ConsultasListarPageState extends State<ConsultasListarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<ConsultaModel> _consultas = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final isDono  = await AuthService.isDono();
      final donoId  = await AuthService.getDonoId();
      List<ConsultaModel> todas = [];

      if (isDono && donoId != null) {
        // Busca os pets do dono e depois as consultas de cada pet
        final pets = await PetService.listarPorDono(donoId);
        for (final pet in pets) {
          try {
            final cs = await ConsultaService.listarPorPet(pet.id);
            todas.addAll(cs);
          } catch (_) {}
        }
        // Ordena por data decrescente
        todas.sort((a, b) => b.dataConsulta.compareTo(a.dataConsulta));
      } else {
        final result = await ConsultaService.listar(pageSize: 100);
        todas = result.items;
      }

      if (mounted) setState(() { _consultas = todas; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<ConsultaModel> get _ativas =>
      _consultas.where((c) => c.isPendente).toList();
  List<ConsultaModel> get _historico =>
      _consultas.where((c) => !c.isPendente).toList();

  Future<void> _cancelar(ConsultaModel c) async {
    final cancelado = await mostrarCancelarConsultaDialog(context, c);
    if (cancelado) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Ativas (${_ativas.length})'),
              Tab(text: 'Histórico (${_historico.length})'),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : _error != null
                  ? _errorWidget()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: TabBarView(
                        controller: _tab,
                        children: [
                          _buildList(_ativas, cancelavel: true),
                          _buildList(_historico, cancelavel: false),
                        ],
                      ),
                    ),
        ),
      ]),
    );
  }

  Widget _buildList(List<ConsultaModel> items, {required bool cancelavel}) {
    if (items.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 80),
        Center(
          child: Column(children: [
            Icon(Icons.calendar_today, size: 56, color: AppColors.border),
            SizedBox(height: 12),
            Text('Nenhuma consulta encontrada.',
                style: TextStyle(color: AppColors.textMuted)),
          ]),
        ),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => ConsultaCard(
        consulta: items[i],
        cancelavel: cancelavel,
        onCancelar: cancelavel ? () => _cancelar(items[i]) : null,
      ),
    );
  }

  Widget _errorWidget() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Tentar novamente',
                style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
}
