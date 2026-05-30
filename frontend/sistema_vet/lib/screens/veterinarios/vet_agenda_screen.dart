/* Tela de agenda do veterinário — exibida no painel admin.
 *
 * Funcionalidades:
 * - Calendário mensal com pontos coloridos nos dias com consultas
 * - Cards de resumo no topo (totais por status: Agendadas, Confirmadas, Canceladas, Finalizadas)
 * - Ao tocar em um dia: exibe a lista de consultas daquele dia
 * - Cada consulta mostra botões de ação contextual:
 *     Agendada   → pode [Confirmar] ou [Cancelar]
 *     Confirmada → pode [Finalizar] ou [Cancelar]
 *
 * As ações (confirmar, cancelar, finalizar) usam o token do admin
 * para chamar os endpoints correspondentes no ConsultaService. */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../models/veterinario_model.dart';
import '../../models/consulta_model.dart';
import '../../services/consulta_service.dart';
import '../../services/admin_auth_service.dart';

class VetAgendaScreen extends StatefulWidget {
  final VeterinarioModel vet;
  const VetAgendaScreen({super.key, required this.vet});

  @override
  State<VetAgendaScreen> createState() => _VetAgendaScreenState();
}

class _VetAgendaScreenState extends State<VetAgendaScreen> {
  DateTime _mesAtual = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _diaSel;
  List<ConsultaModel> _todas  = [];
  bool   _loading = true;
  String? _erro;

  // Agrupa consultas por dia (yyyy-MM-dd)
  Map<String, List<ConsultaModel>> get _porDia {
    final m = <String, List<ConsultaModel>>{};
    for (final c in _todas) {
      final k = DateFormat('yyyy-MM-dd').format(c.dataConsulta.toLocal());
      m.putIfAbsent(k, () => []).add(c);
    }
    return m;
  }

  List<ConsultaModel> get _consultasDiaSel {
    if (_diaSel == null) return [];
    final k = DateFormat('yyyy-MM-dd').format(_diaSel!);
    return (_porDia[k] ?? [])
      ..sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      final token = await AdminAuthService.getAdminToken();
      final lista = await ConsultaService.listarPorVet(widget.vet.id, customToken: token);
      if (!mounted) return;
      setState(() { _todas = lista; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  // ── Helpers de status ─────────────────────────────────────────────────────
  Color _corStatus(String s) => switch (s) {
    'Confirmada' => AppColors.success,
    'Cancelada'  => AppColors.error,
    'Finalizada' => AppColors.textMuted,
    _            => AppColors.primary,
  };

  IconData _iconeStatus(String s) => switch (s) {
    'Confirmada' => Icons.check_circle_outline,
    'Cancelada'  => Icons.cancel_outlined,
    'Finalizada' => Icons.done_all,
    _            => Icons.schedule,
  };

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7FAF9),
    appBar: AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.vet.nome,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(widget.vet.especialidade,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _carregar,
          tooltip: 'Atualizar',
        ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _erro != null
            ? _erroWidget()
            : Column(children: [
                _resumoCards(),
                _calendarioHeader(),
                _calendarioGrid(),
                if (_diaSel != null) Expanded(child: _listaConsultas()),
                if (_diaSel == null)
                  Expanded(child: _instrucaoSelecionar()),
              ]),
  );

  // ── Resumo top ────────────────────────────────────────────────────────────
  Widget _resumoCards() {
    int agendadas  = _todas.where((c) => c.statusConsulta == 'Agendada').length;
    int confirmadas= _todas.where((c) => c.statusConsulta == 'Confirmada').length;
    int canceladas = _todas.where((c) => c.statusConsulta == 'Cancelada').length;
    int finalizadas= _todas.where((c) => c.statusConsulta == 'Finalizada').length;

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(children: [
        _chip('Agendadas',   agendadas,   Colors.white,              AppColors.primary),
        const SizedBox(width: 8),
        _chip('Confirmadas', confirmadas, AppColors.success,         Colors.white),
        const SizedBox(width: 8),
        _chip('Canceladas',  canceladas,  AppColors.error,           Colors.white),
        const SizedBox(width: 8),
        _chip('Finalizadas', finalizadas, AppColors.textMuted,       Colors.white),
      ]),
    );
  }

  Widget _chip(String label, int count, Color bg, Color fg) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bg.withValues(alpha: 0.4)),
      ),
      child: Column(children: [
        Text('$count', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70),
            textAlign: TextAlign.center),
      ]),
    ),
  );

  // ── Calendario header (navegar meses) ─────────────────────────────────────
  Widget _calendarioHeader() => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
        icon: const Icon(Icons.chevron_left, color: AppColors.primary),
        onPressed: () => setState(() {
          _mesAtual = DateTime(_mesAtual.year, _mesAtual.month - 1);
          _diaSel = null;
        }),
      ),
      Text(
        DateFormat('MMMM yyyy', 'pt_BR').format(_mesAtual),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
            color: AppColors.textPrimary),
      ),
      IconButton(
        icon: const Icon(Icons.chevron_right, color: AppColors.primary),
        onPressed: () => setState(() {
          _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + 1);
          _diaSel = null;
        }),
      ),
    ]),
  );

  // ── Grade do calendario ───────────────────────────────────────────────────
  Widget _calendarioGrid() {
    final hoje       = DateTime.now();
    final primeiroDia= DateTime(_mesAtual.year, _mesAtual.month, 1);
    final ultimoDia  = DateTime(_mesAtual.year, _mesAtual.month + 1, 0);
    final inicioGrid = primeiroDia.subtract(
        Duration(days: (primeiroDia.weekday % 7)));
    final fmt = DateFormat('yyyy-MM-dd');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(children: [
        // Cabecalho dias da semana
        Row(children: ['Dom','Seg','Ter','Qua','Qui','Sex','Sab']
            .map((d) => Expanded(child: Center(child: Text(d,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                    color: AppColors.textMuted)))))
            .toList()),
        const SizedBox(height: 6),
        // Grade 6 semanas
        ...List.generate(6, (semana) => Row(
          children: List.generate(7, (dow) {
            final dia = inicioGrid.add(Duration(days: semana * 7 + dow));
            if (dia.month != _mesAtual.month) {
              return Expanded(child: Container(
                margin: const EdgeInsets.all(2),
                height: 36,
              ));
            }
            final k         = fmt.format(dia);
            final consultas = _porDia[k] ?? [];
            final temConsulta= consultas.isNotEmpty;
            final isHoje    = dia.year == hoje.year && dia.month == hoje.month && dia.day == hoje.day;
            final isSel     = _diaSel != null && fmt.format(_diaSel!) == k;
            final temCancel = consultas.any((c) => c.statusConsulta == 'Cancelada');
            final temConfirm= consultas.any((c) => c.statusConsulta == 'Confirmada');

            Color dotColor = AppColors.primary;
            if (temCancel && consultas.every((c) => c.statusConsulta == 'Cancelada')) {
              dotColor = AppColors.error;
            } else if (temConfirm) {
              dotColor = AppColors.success;
            }

            return Expanded(
              child: GestureDetector(
                onTap: temConsulta
                    ? () => setState(() => _diaSel = dia)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.all(2),
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary
                        : isHoje ? AppColors.primaryLight
                        : temConsulta ? dotColor.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSel ? null
                        : isHoje ? Border.all(color: AppColors.primary, width: 1.5)
                        : temConsulta ? Border.all(color: dotColor.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${dia.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: temConsulta || isHoje ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white
                              : isHoje ? AppColors.primary
                              : AppColors.textPrimary,
                        )),
                    if (temConsulta) ...[
                      const SizedBox(height: 2),
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              consultas.length.clamp(1, 3), (_) => Container(
                                width: 4, height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSel ? Colors.white : dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ))),
                    ],
                  ]),
                ),
              ),
            );
          }),
        )),
      ]),
    );
  }

  // ── Lista de consultas do dia selecionado ─────────────────────────────────
  Widget _listaConsultas() {
    final consultas = _consultasDiaSel;
    final dtFmt = DateFormat('EEEE, dd/MM/yyyy', 'pt_BR');
    final hrFmt = DateFormat('HH:mm');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        color: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          '${dtFmt.format(_diaSel!)} — ${consultas.length} consulta${consultas.length != 1 ? "s" : ""}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
        ),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: consultas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _cardConsulta(consultas[i], hrFmt),
        ),
      ),
    ]);
  }

  Widget _cardConsulta(ConsultaModel c, DateFormat hrFmt) {
    final cor  = _corStatus(c.statusConsulta);
    final hora = hrFmt.format(c.dataConsulta.toLocal());
    final podeConfirmar = c.statusConsulta == 'Agendada';
    final podeCancelar  = c.statusConsulta == 'Agendada' || c.statusConsulta == 'Confirmada';
    final podeFinalizar = c.statusConsulta == 'Confirmada';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // Linha principal
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Hora + icone
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(children: [
                Icon(_iconeStatus(c.statusConsulta), color: cor, size: 18),
                const SizedBox(height: 4),
                Text(hora, style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.bold, color: cor)),
              ]),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.motivoConsulta,
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.pets, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(c.tituloPet,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
              ]),
              if (c.observacoes != null && c.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(c.observacoes!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ])),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cor.withValues(alpha: 0.4)),
              ),
              child: Text(c.statusConsulta,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cor)),
            ),
          ]),
        ),

        // Botoes de acao (so aparecem se houver acoes possiveis)
        if (podeConfirmar || podeCancelar || podeFinalizar)
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(children: [
              // Confirmar
              if (podeConfirmar) Expanded(
                child: TextButton.icon(
                  onPressed: () => _confirmar(c),
                  icon: const Icon(Icons.check_circle_outline, size: 15, color: AppColors.success),
                  label: const Text('Confirmar',
                      style: TextStyle(fontSize: 12, color: AppColors.success,
                          fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.success.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              // Finalizar
              if (podeFinalizar) ...[
                if (podeConfirmar) const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _finalizar(c),
                    icon: const Icon(Icons.done_all, size: 15, color: AppColors.primary),
                    label: const Text('Finalizar',
                        style: TextStyle(fontSize: 12, color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ],
              // Cancelar
              if (podeCancelar) ...[
                if (podeConfirmar || podeFinalizar) const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _cancelar(c),
                    icon: const Icon(Icons.cancel_outlined, size: 15, color: AppColors.error),
                    label: const Text('Cancelar',
                        style: TextStyle(fontSize: 12, color: AppColors.error,
                            fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ],
            ]),
          ),
      ]),
    );
  }

  // ── Acoes de consulta ─────────────────────────────────────────────────────
  Future<void> _confirmar(ConsultaModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Consulta'),
        content: Text('Confirmar a consulta de ${c.tituloPet} às '
            '${DateFormat('HH:mm').format(c.dataConsulta.toLocal())}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Nao')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final token = await AdminAuthService.getAdminToken();
      await ConsultaService.confirmar(c.id, customToken: token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Consulta confirmada!'), backgroundColor: AppColors.success));
      _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _cancelar(ConsultaModel c) async {
    final motivoCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar Consulta',
            style: TextStyle(color: AppColors.error)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Consulta de ${c.tituloPet} às '
              '${DateFormat('HH:mm').format(c.dataConsulta.toLocal())}'),
          const SizedBox(height: 12),
          TextField(
            controller: motivoCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Motivo do cancelamento (opcional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancelar consulta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final token  = await AdminAuthService.getAdminToken();
      final motivo = motivoCtrl.text.trim().isEmpty
          ? 'Cancelado pelo administrador' : motivoCtrl.text.trim();
      await ConsultaService.cancelar(c.id, motivo, customToken: token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Consulta cancelada.'), backgroundColor: AppColors.error));
      _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _finalizar(ConsultaModel c) async {
    final obsCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Finalizar Consulta',
            style: TextStyle(color: AppColors.primary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Finalizar consulta de ${c.tituloPet}?'),
          const SizedBox(height: 12),
          TextField(
            controller: obsCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Observacoes finais (opcional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Finalizar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final token = await AdminAuthService.getAdminToken();
      await ConsultaService.finalizar(c.id, obsCtrl.text.trim(), customToken: token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Consulta finalizada!'), backgroundColor: AppColors.primary));
      _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error));
    }
  }

  Widget _instrucaoSelecionar() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.touch_app_rounded, size: 48, color: AppColors.border),
      const SizedBox(height: 12),
      const Text('Toque em um dia com consultas\npara ver os detalhes',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
    ]),
  );

  Widget _erroWidget() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
      const SizedBox(height: 12),
      Text(_erro!, textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted)),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _carregar,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
      ),
    ]),
  );
}
