/* Aba "Início" — tela de boas-vindas do app VetBook.
 *
 * Exibe:
 * - Banner de "Agendar Consulta" — atalho direto para o wizard de agendamento
 * - Próximas consultas (máximo 2) — apenas consultas ativas (Agendada ou Confirmada)
 * - Chips de serviços (Consulta, Vacinação, Banho & Tosa) — todos levam ao agendamento
 *
 * Ao retornar do AgendarConsultaScreen, os dados são recarregados e o notificador
 * `onConsultaAgendada` avisa a aba de Consultas para também atualizar. */
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/consulta_model.dart';
import '../../services/consulta_service.dart';
import '../../services/auth_service.dart';
import '../consultas/agendar_consulta_screen.dart';
import 'package:intl/intl.dart';

class InicioPage extends StatefulWidget {
  final VoidCallback onStartBooking;
  final VoidCallback? onConsultaAgendada;
  const InicioPage({super.key, required this.onStartBooking, this.onConsultaAgendada});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  List<ConsultaModel> _proximas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final donoId = await AuthService.getDonoId();
      final result = await ConsultaService.listar(donoId: donoId, pageSize: 10);
      if (mounted) {
        setState(() {
          _proximas = result.items.where((c) => c.isPendente).take(2).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: Stack(
          children: [
            Center(child: Opacity(opacity: 0.07,
                child: Image.asset('assets/logo.png', width: 550, fit: BoxFit.contain))),
            ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('Olá! 👋',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary, fontFamily: 'Nunito')),
                const Text('Bem-vindo ao VetBook',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 24),

                // Banner agendar
                GestureDetector(
                  onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const AgendarConsultaScreen())).then((_) { _load(); widget.onConsultaAgendada?.call(); }),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Agendar Consulta', style: TextStyle(color: Colors.white,
                            fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Escolha o veterinário, pet e horário',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ])),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_today, color: Colors.white, size: 28),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 28),

                // Próximas consultas
                const Text('PRÓXIMAS CONSULTAS',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted,
                        fontSize: 12, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                if (_loading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ))
                else if (_proximas.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: const Row(children: [
                      Icon(Icons.calendar_today, color: AppColors.border, size: 32),
                      SizedBox(width: 16),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Nenhuma consulta agendada', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('Agende a primeira consulta do seu pet!', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ]),
                    ]),
                  )
                else
                  ..._proximas.map((c) => _consultaCard(c)),

                const SizedBox(height: 28),
                const Text('SERVIÇOS',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted,
                        fontSize: 12, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Row(children: [
                  _serviceChip('🩺', 'Consulta'),
                  const SizedBox(width: 10),
                  _serviceChip('💉', 'Vacinação'),
                  const SizedBox(width: 10),
                  _serviceChip('✂️', 'Banho & Tosa'),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _consultaCard(ConsultaModel c) {
    final dtStr = DateFormat('dd/MM/yyyy · HH:mm').format(c.dataConsulta.toLocal());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.motivoConsulta, style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(dtStr, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
          child: Text(c.statusConsulta, style: const TextStyle(color: AppColors.primary,
              fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _serviceChip(String emoji, String label) => Expanded(
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendarConsultaScreen())).then((_) { _load(); widget.onConsultaAgendada?.call(); }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
            ]),
          ),
        ),
      );
}
