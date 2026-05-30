/* Aba "Consultas" da tela principal.
 *
 * Exibe as consultas do dono logado em duas abas:
 * - Ativas: consultas com status Agendada ou Confirmada (podem ser canceladas)
 * - Histórico: consultas finalizadas ou canceladas
 *
 * O `refreshNotifier` é passado pelo MainScreen — quando ativado (ao agendar
 * uma nova consulta ou mudar para esta aba), a lista é recarregada da API.
 *
 * O FAB "+ Agendar" abre o wizard de agendamento e recarrega a lista ao voltar. */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../models/consulta_model.dart';
import '../../services/consulta_service.dart';
import '../../services/auth_service.dart';
import '../consultas/agendar_consulta_screen.dart';

class ConsultasPage extends StatefulWidget {
  final ChangeNotifier? refreshNotifier;
  const ConsultasPage({super.key, this.refreshNotifier});

  @override
  State<ConsultasPage> createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage>
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
    widget.refreshNotifier?.addListener(_load);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_load);
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final donoId = await AuthService.getDonoId();
      final result = await ConsultaService.listar(donoId: donoId, pageSize: 100);
      if (mounted) setState(() { _consultas = result.items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<ConsultaModel> get _ativas    => _consultas.where((c) => c.isPendente).toList();
  List<ConsultaModel> get _historico => _consultas.where((c) => !c.isPendente).toList();

  Future<void> _cancelar(ConsultaModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar Consulta'),
        content: const Text('Tem certeza que deseja cancelar esta consulta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Nao'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancelar consulta'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ConsultaService.cancelar(c.id, 'Cancelado pelo usuario');
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AgendarConsultaScreen()),
        ).then((_) => _load()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agendar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Ativas (${_ativas.length})'),
                Tab(text: 'Historico (${_historico.length})'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
        ],
      ),
    );
  }

  Widget _buildList(List<ConsultaModel> items, {required bool cancelavel}) {
    if (items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 80),
        Center(
          child: Column(children: [
            const Icon(Icons.calendar_today, size: 56, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              cancelavel
                  ? 'Nenhuma consulta ativa.\nToque em "+ Agendar" para marcar!'
                  : 'Nenhuma consulta no historico.',
              style: const TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _card(items[i], cancelavel: cancelavel),
    );
  }

  Widget _card(ConsultaModel c, {required bool cancelavel}) {
    Color statusColor;
    IconData statusIcon;
    switch (c.statusConsulta) {
      case 'Agendada':
        statusColor = AppColors.primary;
        statusIcon  = Icons.schedule;
      case 'Confirmada':
        statusColor = AppColors.success;
        statusIcon  = Icons.check_circle_outline;
      case 'Cancelada':
        statusColor = AppColors.error;
        statusIcon  = Icons.cancel_outlined;
      default:
        statusColor = AppColors.textMuted;
        statusIcon  = Icons.done_all;
    }
    final dtStr = DateFormat('dd/MM/yyyy - HH:mm').format(c.dataConsulta.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Status + data
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(statusIcon, color: statusColor, size: 13),
              const SizedBox(width: 4),
              Text(c.statusConsulta,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          ),
          Text(dtStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ]),

        const SizedBox(height: 12),

        // Motivo
        Row(children: [
          const Icon(Icons.medical_services_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(c.motivoConsulta,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]),

        const SizedBox(height: 6),

        // Pet + Vet
        Row(children: [
          const Icon(Icons.pets, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(child: Text('Pet: ${c.tituloPet}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
        ]),
        const SizedBox(height: 2),
        Row(children: [
          const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(child: Text('Vet: ${c.tituloVet}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
        ]),

        if (c.observacoes != null && c.observacoes!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(c.observacoes!,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ],

        if (cancelavel) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _cancelar(c),
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _errorWidget() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
        const SizedBox(height: 12),
        Text(_error!,
            style: const TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _load,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
        ),
      ]),
    ),
  );
}
