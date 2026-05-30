/* Tela de agendamento de consultas — wizard de 6 passos.
 *
 * Cada passo é uma etapa da seleção de agendamento:
 *   Passo 1 - Clínica:        Lista as clínicas veterinárias ativas
 *   Passo 2 - Veterinário:    Lista os vets ativos da clínica selecionada
 *   Passo 3 - Pet:            Lista os pets do dono logado
 *   Passo 4 - Tipo:           Seleciona o tipo de consulta (6 opções com preço)
 *   Passo 5 - Data e Horário: Calendário + grade de slots de 30 em 30 minutos
 *   Passo 6 - Confirmar:      Resumo completo + campo de observações
 *
 * Detecção de conflitos de horário:
 * No passo 5, ao selecionar a data, a tela consulta a API para buscar
 * as consultas já existentes do veterinário naquele dia. Slots ocupados
 * (dentro de 60 minutos de outra consulta) ficam bloqueados na grade.
 *
 * Ao confirmar, a consulta é criada via ConsultaService.agendar() e a
 * tela retorna true para o chamador, indicando que um agendamento foi feito. */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../models/clinica_model.dart';
import '../../../models/veterinario_model.dart';
import '../../../models/pet_model.dart';
import '../../../models/consulta_model.dart';
import '../../../services/clinica_service.dart';
import '../../../services/veterinario_service.dart';
import '../../../services/pet_service.dart';
import '../../../services/consulta_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../../services/api_service.dart';

// ─── Tipo de Consulta (somente frontend) ─────────────────────────────────────

class TipoConsulta {
  final String   id;
  final String   nome;
  final String   descricao;
  final IconData icone;
  final Color    cor;
  final double   valor;
  const TipoConsulta({required this.id, required this.nome,
      required this.descricao, required this.icone,
      required this.cor, required this.valor});
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AgendarConsultaScreen extends StatefulWidget {
  const AgendarConsultaScreen({super.key});
  @override
  State<AgendarConsultaScreen> createState() => _AgendarConsultaScreenState();
}

class _AgendarConsultaScreenState extends State<AgendarConsultaScreen> {
  // ── Passos: 1-Clinica 2-Vet 3-Pet 4-Tipo 5-Data/Hora 6-Confirmar ──────────
  int _step = 1;
  static const int _totalSteps = 6;

  // Selecoes
  ClinicaModel?      _clinicaSel;
  VeterinarioModel?  _vetSel;
  PetModel?          _petSel;
  TipoConsulta?      _tipoSel;
  DateTime?          _dataSel;
  String?            _horaSel;
  final _obsCtrl = TextEditingController();

  // Dados
  List<ClinicaModel>     _clinicas  = [];
  List<VeterinarioModel> _todosVets = [];
  List<PetModel>         _pets      = [];
  Set<String>            _horasOcupadas = {};

  // Loading
  bool _carregando = true;
  bool _loadingSlots = false;
  bool _agendando    = false;
  String? _erro;

  // ── Tipos de consulta ─────────────────────────────────────────────────────
  static const _tipos = [
    TipoConsulta(id:'rotina',    nome:'Consulta de Rotina',  descricao:'Check-up geral e prevencao',  icone:Icons.health_and_safety_rounded,   cor:Color(0xFF2D7D5A), valor:120),
    TipoConsulta(id:'vacina',    nome:'Vacinacao',           descricao:'Vacinas e imunizacao',         icone:Icons.vaccines_rounded,            cor:Color(0xFF4A90D9), valor:80),
    TipoConsulta(id:'emergencia',nome:'Emergencia',          descricao:'Atendimento urgente 24h',      icone:Icons.emergency_rounded,           cor:Color(0xFFE24B4A), valor:200),
    TipoConsulta(id:'cirurgia',  nome:'Cirurgia',            descricao:'Procedimentos cirurgicos',     icone:Icons.biotech_rounded,             cor:Color(0xFF9B59B6), valor:350),
    TipoConsulta(id:'retorno',   nome:'Retorno',             descricao:'Revisao de tratamento',        icone:Icons.refresh_rounded,             cor:Color(0xFF27AE60), valor:60),
    TipoConsulta(id:'exame',     nome:'Exames',              descricao:'Laboratorial e imagem',        icone:Icons.science_rounded,             cor:Color(0xFFF39C12), valor:150),
  ];

  // Slots 08:00 ate 18:30 de 30 em 30 min
  static final _slots = List.generate(22, (i) {
    final h = 8 + (i ~/ 2);
    final m = (i % 2) * 30;
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}';
  });

  // ── Vets da clinica selecionada ───────────────────────────────────────────
  List<VeterinarioModel> get _vetsClinica =>
      _clinicaSel == null ? [] :
      _todosVets.where((v) => v.clinicaId == _clinicaSel!.id).toList();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() { super.initState(); _carregar(); }

  @override
  void dispose() { _obsCtrl.dispose(); super.dispose(); }

  // ── Carregamento inicial ──────────────────────────────────────────────────
  Future<void> _carregar() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      final donoId = await AuthService.getDonoId();
      final r = await Future.wait([
        ClinicaService.listarAtivas(),
        VeterinarioService.listarAtivos(),
        donoId != null
            ? PetService.listarPorDono(donoId)
            : PetService.listar(pageSize:100).then((r) => r.items),
      ]);
      if (!mounted) return;
      setState(() {
        _clinicas  = r[0] as List<ClinicaModel>;
        _todosVets = r[1] as List<VeterinarioModel>;
        _pets      = r[2] as List<PetModel>;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _carregando = false; _erro = 'Erro ao carregar dados: $e'; });
    }
  }

  // ── Slots ocupados ────────────────────────────────────────────────────────
  Future<void> _carregarSlots() async {
    if (_vetSel == null || _dataSel == null) return;
    setState(() { _loadingSlots = true; _horasOcupadas = {}; });
    try {
      final inicio = DateTime(_dataSel!.year, _dataSel!.month, _dataSel!.day);
      final fim    = inicio.add(const Duration(hours:23, minutes:59));
      final url = '${ApiConstants.consultas}?veterinarioId=${_vetSel!.id}'
          '&dataInicio=${inicio.toUtc().toIso8601String()}'
          '&dataFim=${fim.toUtc().toIso8601String()}&pageSize=100';
      final res   = await ApiService.get(url);
      final data  = res['data'] as Map<String, dynamic>? ?? {};
      final items = (data['items'] as List<dynamic>?) ?? [];
      final ocup  = <String>{};
      for (final c in items) {
        final dt = DateTime.tryParse(c['dataConsulta'] as String? ?? '');
        if (dt == null) continue;
        final local = dt.toLocal();
        for (final slot in _slots) {
          final p = slot.split(':');
          final sd = DateTime(_dataSel!.year, _dataSel!.month, _dataSel!.day,
              int.parse(p[0]), int.parse(p[1]));
          if (local.difference(sd).inMinutes.abs() < 60) ocup.add(slot);
        }
      }
      if (!mounted) return;
      setState(() { _horasOcupadas = ocup; _loadingSlots = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loadingSlots = false; });
    }
  }

  // ── Navegacao ─────────────────────────────────────────────────────────────
  void _avancar() {
    setState(() => _erro = null);
    switch (_step) {
      case 1:
        if (_clinicaSel == null) { _setErro('Selecione uma clinica.'); return; }
        if (_vetSel != null && _vetSel!.clinicaId != _clinicaSel!.id) {
          _vetSel = null; _horaSel = null; _horasOcupadas = {};
        }
      case 2:
        if (_vetSel == null) { _setErro('Selecione o veterinario.'); return; }
      case 3:
        if (_petSel == null) { _setErro('Selecione o pet.'); return; }
      case 4:
        if (_tipoSel == null) { _setErro('Selecione o tipo de consulta.'); return; }
      case 5:
        if (_dataSel == null) { _setErro('Selecione a data.'); return; }
        if (_horaSel == null) { _setErro('Selecione o horario.'); return; }
      case 6:
        _salvar();
        return;
    }
    setState(() => _step++);
    if (_step == 5 && _vetSel != null && _dataSel != null) _carregarSlots();
  }

  void _voltar() {
    if (_step > 1) setState(() { _step--; _erro = null; });
    else Navigator.pop(context);
  }

  void _setErro(String msg) => setState(() => _erro = msg);

  // ── Salvar consulta ───────────────────────────────────────────────────────
  Future<void> _salvar() async {
    setState(() { _agendando = true; _erro = null; });
    try {
      final p    = _horaSel!.split(':');
      final hora = DateTime(_dataSel!.year, _dataSel!.month, _dataSel!.day,
          int.parse(p[0]), int.parse(p[1]));

      if (hora.isBefore(DateTime.now())) {
        _setErro('O horario selecionado ja passou. Escolha outro.');
        setState(() => _agendando = false);
        return;
      }

      await ConsultaService.agendar(CreateConsultaRequest(
        petId:          _petSel!.id,
        veterinarioId:  _vetSel!.id,
        dataConsulta:   hora.toUtc(),
        motivoConsulta: _tipoSel!.nome +
            (_obsCtrl.text.trim().isNotEmpty ? ' - ${_obsCtrl.text.trim()}' : ''),
        observacoes: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Consulta agendada com sucesso!'),
        backgroundColor: AppColors.success,
      ));
      Navigator.pop(context, true);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      _setErro(msg.length > 200 ? '${msg.substring(0,200)}...' : msg);
    } finally {
      if (mounted) setState(() => _agendando = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: Column(children: [
      _header(),
      if (_erro != null) _banner(),
      Expanded(
        child: _carregando
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : AnimatedSwitcher(
                duration: const Duration(milliseconds:220),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: switch (_step) {
                    1 => _p1Clinica(),
                    2 => _p2Vet(),
                    3 => _p3Pet(),
                    4 => _p4Tipo(),
                    5 => _p5DataHora(),
                    _ => _p6Confirmar(),
                  },
                ),
              ),
      ),
      _rodape(),
    ]),
  );

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _header() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryMid, AppColors.primary],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 12,
      left:16, right:16, bottom:20,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        GestureDetector(
          onTap: _voltar,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color:Colors.white, size:18),
          ),
        ),
        const SizedBox(width:12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Novo Agendamento',
              style: TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
          Text(_labelPasso(), style: const TextStyle(color:Colors.white70, fontSize:12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$_step/$_totalSteps',
              style: const TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:13)),
        ),
      ]),
      const SizedBox(height:16),
      Row(
        children: List.generate(_totalSteps, (i) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds:300),
            height:4,
            margin: const EdgeInsets.symmetric(horizontal:2),
            decoration: BoxDecoration(
              color: i+1 < _step  ? Colors.white
                   : i+1 == _step ? AppColors.accent
                   : Colors.white.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    ]),
  );

  Widget _banner() => Container(
    margin: const EdgeInsets.fromLTRB(16,12,16,0),
    padding: const EdgeInsets.symmetric(horizontal:14, vertical:10),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha:0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.error.withValues(alpha:0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.warning_amber_rounded, color:AppColors.error, size:18),
      const SizedBox(width:8),
      Expanded(child: Text(_erro!, style: const TextStyle(color:AppColors.error, fontSize:13))),
      GestureDetector(
        onTap: () => setState(() => _erro = null),
        child: const Icon(Icons.close, color:AppColors.error, size:16),
      ),
    ]),
  );

  Widget _rodape() => Container(
    padding: const EdgeInsets.fromLTRB(16,12,16,24),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color:Color(0x12000000), blurRadius:12, offset:Offset(0,-4))],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _step == _totalSteps ? AppColors.success : AppColors.primary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation:0,
      ),
      onPressed: _agendando ? null : _avancar,
      child: _agendando
          ? const SizedBox(width:22, height:22,
              child: CircularProgressIndicator(color:Colors.white, strokeWidth:2))
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                _step == _totalSteps ? 'Confirmar Agendamento' : 'Proximo',
                style: const TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:16),
              ),
              const SizedBox(width:8),
              Icon(_step == _totalSteps ? Icons.check_circle_outline : Icons.arrow_forward,
                  color:Colors.white, size:20),
            ]),
    ),
  );

  // ── Passo 1: Clinica ──────────────────────────────────────────────────────
  Widget _p1Clinica() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _titulo('Escolha a Clinica', 'Selecione a unidade de sua preferencia'),
      const SizedBox(height:16),
      if (_clinicas.isEmpty)
        _vazio('Nenhuma clinica disponivel no momento.')
      else
        ..._clinicas.map(_cardClinica),
    ],
  );

  Widget _cardClinica(ClinicaModel c) {
    final sel = _clinicaSel?.id == c.id;
    return GestureDetector(
      onTap: () => setState(() { _clinicaSel = c; _erro = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds:200),
        margin: const EdgeInsets.only(bottom:12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel?2:1),
          boxShadow: [BoxShadow(color:Colors.black.withValues(alpha:0.04), blurRadius:8, offset:const Offset(0,2))],
        ),
        child: Row(children: [
          Container(
            width:52, height:52,
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(c.iniciais,
                style: TextStyle(color: sel?Colors.white:AppColors.primary,
                    fontWeight:FontWeight.bold, fontSize:18))),
          ),
          const SizedBox(width:14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.nome, style: TextStyle(fontWeight:FontWeight.bold, fontSize:15,
                color: sel?AppColors.primary:AppColors.textPrimary)),
            const SizedBox(height:2),
            Text(c.endereco, style: const TextStyle(fontSize:12, color:AppColors.textMuted)),
            const SizedBox(height:2),
            Row(children: [
              const Icon(Icons.phone_rounded, size:12, color:AppColors.textMuted),
              const SizedBox(width:4),
              Text(c.telefone, style: const TextStyle(fontSize:12, color:AppColors.textMuted)),
            ]),
          ])),
          if (sel) const Icon(Icons.check_circle, color:AppColors.primary, size:22),
        ]),
      ),
    );
  }

  // ── Passo 2: Veterinario ──────────────────────────────────────────────────
  Widget _p2Vet() {
    final vets = _vetsClinica;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _titulo('Veterinario', 'Profissionais da ${_clinicaSel?.nome ?? "clinica"}'),
        const SizedBox(height:12),
        if (vets.isEmpty)
          _vazio('Nenhum veterinario disponivel nesta clinica.')
        else
          ...vets.map(_cardVet),
      ],
    );
  }

  Widget _cardVet(VeterinarioModel v) {
    final sel = _vetSel?.id == v.id;
    return GestureDetector(
      onTap: () => setState(() {
        _vetSel = v; _erro = null; _horasOcupadas = {}; _horaSel = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds:200),
        margin: const EdgeInsets.only(bottom:10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel?AppColors.primary:AppColors.border, width:sel?2:1),
          boxShadow: [BoxShadow(color:Colors.black.withValues(alpha:0.04), blurRadius:6)],
        ),
        child: Row(children: [
          CircleAvatar(
            radius:26,
            backgroundColor: sel ? AppColors.primary : AppColors.primaryLight,
            child: Text(v.iniciais, style: TextStyle(
                color: sel?Colors.white:AppColors.primary,
                fontWeight:FontWeight.bold, fontSize:16)),
          ),
          const SizedBox(width:12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v.nome, style: TextStyle(fontWeight:FontWeight.bold,
                color: sel?AppColors.primary:AppColors.textPrimary)),
            const SizedBox(height:2),
            Text(v.especialidade, style: const TextStyle(fontSize:12, color:AppColors.textMuted)),
            Text('CRMV: ${v.crmv}', style: const TextStyle(fontSize:11, color:AppColors.textMuted)),
          ])),
          if (sel) const Icon(Icons.check_circle, color:AppColors.primary, size:22),
        ]),
      ),
    );
  }

  // ── Passo 3: Pet ──────────────────────────────────────────────────────────
  Widget _p3Pet() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _titulo('Seu Pet', 'Quem sera atendido?'),
      const SizedBox(height:12),
      if (_pets.isEmpty)
        _vazio('Nenhum pet cadastrado. Cadastre em "Meus Pets".')
      else
        ..._pets.map(_cardPet),
    ],
  );

  Widget _cardPet(PetModel p) {
    final sel = _petSel?.id == p.id;
    return GestureDetector(
      onTap: () => setState(() { _petSel = p; _erro = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds:200),
        margin: const EdgeInsets.only(bottom:10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel?AppColors.primary:AppColors.border, width:sel?2:1),
          boxShadow: [BoxShadow(color:Colors.black.withValues(alpha:0.04), blurRadius:6)],
        ),
        child: Row(children: [
          Container(
            width:52, height:52,
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(p.emojiEspecie, style: const TextStyle(fontSize:26))),
          ),
          const SizedBox(width:12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.nome, style: TextStyle(fontWeight:FontWeight.bold, fontSize:15,
                color: sel?AppColors.primary:AppColors.textPrimary)),
            const SizedBox(height:2),
            Text(p.raca, style: const TextStyle(fontSize:12, color:AppColors.textMuted)),
            Text('${p.idade} anos - ${p.sexo}',
                style: const TextStyle(fontSize:12, color:AppColors.textMuted)),
          ])),
          if (sel) const Icon(Icons.check_circle, color:AppColors.primary, size:22),
        ]),
      ),
    );
  }

  // ── Passo 4: Tipo de Consulta ─────────────────────────────────────────────
  Widget _p4Tipo() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _titulo('Tipo de Consulta', 'Selecione o procedimento e veja o valor'),
      const SizedBox(height:16),
      ..._tipos.map(_cardTipo),
    ],
  );

  Widget _cardTipo(TipoConsulta t) {
    final sel = _tipoSel?.id == t.id;
    final fmt = NumberFormat.currency(locale:'pt_BR', symbol:'R\$');
    return GestureDetector(
      onTap: () => setState(() { _tipoSel = t; _erro = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds:180),
        margin: const EdgeInsets.only(bottom:10),
        padding: const EdgeInsets.symmetric(horizontal:14, vertical:12),
        decoration: BoxDecoration(
          color: sel ? t.cor.withValues(alpha:0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? t.cor : AppColors.border,
            width: sel ? 2 : 1,
          ),
          boxShadow: [BoxShadow(
            color: sel ? t.cor.withValues(alpha:0.12) : Colors.black.withValues(alpha:0.04),
            blurRadius: sel ? 10 : 6,
            offset: const Offset(0,2),
          )],
        ),
        child: Row(children: [
          // Icone colorido
          Container(
            width:48, height:48,
            decoration: BoxDecoration(
              color: t.cor.withValues(alpha: sel ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(t.icone, color: t.cor, size:24),
          ),
          const SizedBox(width:14),
          // Nome + descricao
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.nome, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: sel ? t.cor : AppColors.textPrimary,
              )),
              const SizedBox(height:2),
              Text(t.descricao, style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              )),
            ],
          )),
          const SizedBox(width:10),
          // Preco + check
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal:10, vertical:5),
              decoration: BoxDecoration(
                color: sel ? t.cor : t.cor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                fmt.format(t.valor),
                style: TextStyle(
                  color: sel ? Colors.white : t.cor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            if (sel) ...[
              const SizedBox(height:4),
              Icon(Icons.check_circle, color: t.cor, size:18),
            ],
          ]),
        ]),
      ),
    );
  }

  // ── Passo 5: Data e Horario ───────────────────────────────────────────────
  Widget _p5DataHora() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _titulo('Data', 'Selecione o dia da consulta'),
      const SizedBox(height:12),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color:Colors.black.withValues(alpha:0.04), blurRadius:8)],
        ),
        child: CalendarDatePicker(
          initialDate: _dataSel ?? DateTime.now().add(const Duration(days:1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days:365)),
          onDateChanged: (d) {
            setState(() { _dataSel = d; _horaSel = null; });
            _carregarSlots();
          },
          selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
        ),
      ),
      if (_dataSel != null) ...[
        const SizedBox(height:20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _titulo('Horarios Disponiveis', ''),
          if (_loadingSlots)
            const SizedBox(width:18, height:18,
                child: CircularProgressIndicator(strokeWidth:2, color:AppColors.primary)),
        ]),
        const SizedBox(height:12),
        Wrap(spacing:8, runSpacing:8,
            children: _slots.map(_chipSlot).toList()),
        const SizedBox(height:10),
        Row(children: [
          _dot(AppColors.primary),
          const Text('  Disponivel  ', style:TextStyle(fontSize:11, color:AppColors.textMuted)),
          _dot(AppColors.accent),
          const Text('  Selecionado  ', style:TextStyle(fontSize:11, color:AppColors.textMuted)),
          _dot(AppColors.border),
          const Text('  Ocupado', style:TextStyle(fontSize:11, color:AppColors.textMuted)),
        ]),
      ],
    ],
  );

  Widget _chipSlot(String slot) {
    final ocupado  = _horasOcupadas.contains(slot);
    final selected = _horaSel == slot;
    bool passado   = false;
    if (_dataSel != null) {
      final now = DateTime.now();
      final hoje = _dataSel!.year == now.year &&
          _dataSel!.month == now.month && _dataSel!.day == now.day;
      if (hoje) {
        final p  = slot.split(':');
        final sd = DateTime(now.year, now.month, now.day,
            int.parse(p[0]), int.parse(p[1]));
        passado = sd.isBefore(now);
      }
    }
    final bloq = ocupado || passado;
    return GestureDetector(
      onTap: bloq ? null : () => setState(() { _horaSel = slot; _erro = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds:150),
        padding: const EdgeInsets.symmetric(horizontal:14, vertical:10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : bloq ? const Color(0xFFF0F0F0) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : bloq ? AppColors.border
                : AppColors.primary.withValues(alpha:0.4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(slot, style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.white : bloq ? AppColors.border : AppColors.textPrimary,
          fontSize:13,
        )),
      ),
    );
  }

  Widget _dot(Color cor) => Container(
      width:10, height:10,
      decoration: BoxDecoration(color:cor, shape:BoxShape.circle));

  // ── Passo 6: Confirmar ────────────────────────────────────────────────────
  Widget _p6Confirmar() {
    final fmt = NumberFormat.currency(locale:'pt_BR', symbol:'R\$');
    final dtFmt = DateFormat('dd/MM/yyyy (EEEE)', 'pt_BR');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _titulo('Confirmar Agendamento', 'Revise os dados antes de finalizar'),
        const SizedBox(height:16),

        // Badge tipo
        Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal:16, vertical:8),
          decoration: BoxDecoration(
            color: (_tipoSel?.cor ?? AppColors.primary).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_tipoSel?.icone ?? Icons.medical_services,
                color: _tipoSel?.cor ?? AppColors.primary, size:18),
            const SizedBox(width:8),
            Text(_tipoSel?.nome ?? '',
                style: TextStyle(fontWeight:FontWeight.bold,
                    color: _tipoSel?.cor ?? AppColors.primary)),
          ]),
        )),
        const SizedBox(height:16),

        // Card resumo
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color:Colors.black.withValues(alpha:0.05), blurRadius:10)],
          ),
          child: Column(children: [
            _linha(Icons.local_hospital_rounded,  'Clinica',       _clinicaSel?.nome ?? '-'),
            _sep(),
            _linha(Icons.person_rounded,          'Veterinario',   _vetSel?.nome ?? '-'),
            _linha(Icons.badge_rounded,           'Especialidade', _vetSel?.especialidade ?? '-'),
            _sep(),
            _linha(Icons.pets,                    'Pet',           _petSel?.nome ?? '-'),
            _linha(Icons.category_rounded,        'Raca',          _petSel?.raca ?? '-'),
            _sep(),
            _linha(Icons.calendar_today_rounded,  'Data',
                _dataSel != null ? dtFmt.format(_dataSel!) : '-'),
            _linha(Icons.access_time_rounded,     'Horario',       _horaSel ?? '-'),
          ]),
        ),
        const SizedBox(height:12),

        // Card valor
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors:[AppColors.primaryMid, AppColors.primary]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Valor estimado',    style:TextStyle(color:Colors.white70, fontSize:13)),
              Text('Pagamento na clinica', style:TextStyle(color:Colors.white54, fontSize:11)),
            ]),
            Text(fmt.format(_tipoSel?.valor ?? 0),
                style: const TextStyle(color:Colors.white, fontSize:22, fontWeight:FontWeight.bold)),
          ]),
        ),
        const SizedBox(height:16),

        // Observacoes
        const Text('Observacoes (opcional)',
            style:TextStyle(fontWeight:FontWeight.w600, fontSize:13, color:AppColors.textPrimary)),
        const SizedBox(height:8),
        TextField(
          controller: _obsCtrl,
          maxLines:3,
          maxLength:300,
          decoration: InputDecoration(
            hintText: 'Ex: Pet com medo de barulhos, alergias...',
            hintStyle: const TextStyle(color:AppColors.textMuted, fontSize:13),
            filled:true, fillColor:Colors.white,
            counterStyle: const TextStyle(color:AppColors.textMuted, fontSize:11),
            border:        OutlineInputBorder(borderRadius:BorderRadius.circular(12),
                borderSide:const BorderSide(color:AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(12),
                borderSide:const BorderSide(color:AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(12),
                borderSide:const BorderSide(color:AppColors.primary, width:1.5)),
          ),
        ),
        const SizedBox(height:8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color:AppColors.primaryLight,
              borderRadius:BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.info_outline, color:AppColors.primary, size:16),
            SizedBox(width:8),
            Expanded(child: Text('Voce recebera uma confirmacao apos o agendamento.',
                style:TextStyle(fontSize:12, color:AppColors.primary))),
          ]),
        ),
        const SizedBox(height:8),
      ],
    );
  }

  Widget _linha(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical:7),
    child: Row(children: [
      Icon(icon, size:16, color:AppColors.primary),
      const SizedBox(width:10),
      Text(label, style: const TextStyle(fontSize:13, color:AppColors.textMuted)),
      const Spacer(),
      Flexible(child: Text(value,
          style: const TextStyle(fontSize:13, fontWeight:FontWeight.w600,
              color:AppColors.textPrimary),
          textAlign:TextAlign.end)),
    ]),
  );

  Widget _sep() => Divider(color:AppColors.border.withValues(alpha:0.5), height:16);

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _titulo(String t, String sub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(t, style: const TextStyle(fontSize:16, fontWeight:FontWeight.bold,
          color:AppColors.textPrimary)),
      if (sub.isNotEmpty) ...[
        const SizedBox(height:2),
        Text(sub, style: const TextStyle(fontSize:12, color:AppColors.textMuted)),
      ],
    ],
  );

  Widget _vazio(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical:32, horizontal:24),
      child: Column(children: [
        const Icon(Icons.search_off_rounded, size:48, color:AppColors.textMuted),
        const SizedBox(height:12),
        Text(msg, style: const TextStyle(color:AppColors.textMuted),
            textAlign:TextAlign.center),
      ]),
    ),
  );

  String _labelPasso() => switch (_step) {
    1 => 'Passo 1 - Clinica',
    2 => 'Passo 2 - Veterinario',
    3 => 'Passo 3 - Pet',
    4 => 'Passo 4 - Tipo de Consulta',
    5 => 'Passo 5 - Data e Horario',
    _ => 'Passo 6 - Confirmar',
  };
}
