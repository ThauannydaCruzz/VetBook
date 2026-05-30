/* Tela de agendamento (versão alternativa/legada).
 * Esta tela pode ter sido substituída pelo AgendarConsultaScreen (wizard de 6 passos).
 * Mantida no projeto para referência ou uso futuro. */
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../models/veterinario_model.dart';
import '../models/pet_model.dart';
import '../models/consulta_model.dart';
import '../services/veterinario_service.dart';
import '../services/pet_service.dart';
import '../services/consulta_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 1;

  List<VeterinarioModel> _vets = [];
  List<PetModel> _pets = [];
  VeterinarioModel? _vetSel;
  PetModel? _petSel;
  DateTime? _dataSel;
  TimeOfDay? _horaSel;
  final _motivoCtrl = TextEditingController();

  bool _loadingVets = true;
  bool _loadingPets = true;
  bool _agendando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final vets = await VeterinarioService.listarAtivos();
      final pets = await PetService.listar(pageSize: 50);
      if (mounted) setState(() {
        _vets = vets;
        _pets = pets.items;
        _loadingVets = false;
        _loadingPets = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loadingVets = false;
        _loadingPets = false;
        _error = 'Erro ao carregar dados: $e';
      });
    }
  }

  DateTime? get _dataHora {
    if (_dataSel == null || _horaSel == null) return null;
    return DateTime(_dataSel!.year, _dataSel!.month, _dataSel!.day, _horaSel!.hour, _horaSel!.minute);
  }

  Future<void> _agendar() async {
    if (_vetSel == null || _petSel == null || _dataHora == null || _motivoCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Preencha todos os campos antes de confirmar.');
      return;
    }
    setState(() { _agendando = true; _error = null; });
    try {
      await ConsultaService.agendar(CreateConsultaRequest(
        petId: _petSel!.id,
        veterinarioId: _vetSel!.id,
        dataConsulta: _dataHora!.toUtc(),
        motivoConsulta: _motivoCtrl.text.trim(),
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta agendada com sucesso! ✅'),
            backgroundColor: AppColors.success),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      if (mounted) setState(() => _agendando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16, right: 16, bottom: 20,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () => _step > 1 ? setState(() => _step--) : Navigator.pop(context),
                  child: const Icon(TablerIcons.arrow_left, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Novo Agendamento',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              Row(
                children: List.generate(4, (i) {
                  final done = i + 1 < _step;
                  final active = i + 1 == _step;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accent : (done ? Colors.white : Colors.white.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(_stepLabel(), style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),

          // Content
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.error.withValues(alpha: 0.1),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                GestureDetector(onTap: () => setState(() => _error = null),
                    child: const Icon(Icons.close, color: AppColors.error, size: 18)),
              ]),
            ),

          Expanded(
            child: (_loadingVets || _loadingPets)
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _buildStep(),
          ),

          // Footer button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _agendando ? null : () {
                if (_step < 4) {
                  setState(() => _step++);
                } else {
                  _agendar();
                }
              },
              child: _agendando
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_step == 4 ? 'Confirmar Agendamento ✓' : 'Próximo →',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1: return _stepVet();
      case 2: return _stepPet();
      case 3: return _stepDataHora();
      default: return _stepRevisao();
    }
  }

  Widget _stepVet() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Escolha o Veterinário', style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (_vets.isEmpty)
            const Center(child: Text('Nenhum veterinário ativo disponível.',
                style: TextStyle(color: AppColors.textMuted)))
          else
            ..._vets.map((v) => _selCard(
              isSelected: _vetSel == v,
              onTap: () => setState(() => _vetSel = v),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(v.iniciais, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              title: v.nome,
              subtitle: '${v.crmv} · ${v.especialidade}',
            )),
        ],
      );

  Widget _stepPet() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Escolha o Pet', style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (_pets.isEmpty)
            const Center(child: Text('Nenhum pet cadastrado. Cadastre um pet na aba Meus Pets.',
                style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center))
          else
            ..._pets.map((p) => _selCard(
              isSelected: _petSel == p,
              onTap: () => setState(() => _petSel = p),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(p.emojiEspecie, style: const TextStyle(fontSize: 20)),
              ),
              title: p.nome,
              subtitle: '${p.raca} · ${p.idade} anos',
            )),
        ],
      );

  Widget _stepDataHora() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Data e Horário', style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _pickerBtn(
              icon: Icons.calendar_today,
              label: _dataSel == null ? 'Escolher data' : DateFormat('dd/MM/yyyy').format(_dataSel!),
              onTap: () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                    child: child!,
                  ),
                );
                if (p != null) setState(() => _dataSel = p);
              },
            )),
            const SizedBox(width: 12),
            Expanded(child: _pickerBtn(
              icon: Icons.access_time,
              label: _horaSel == null ? 'Horário' : _horaSel!.format(context),
              onTap: () async {
                final p = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 9, minute: 0),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                    child: child!,
                  ),
                );
                if (p != null) setState(() => _horaSel = p);
              },
            )),
          ]),
          const SizedBox(height: 24),
          const Text('Motivo da Consulta *', style: TextStyle(fontWeight: FontWeight.w600,
              fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _motivoCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Check-up anual, vacinação, coceira...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ],
      );

  Widget _stepRevisao() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Confirmar Agendamento', style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _reviewCard([
            _reviewRow('Veterinário', _vetSel?.nome ?? '-'),
            _reviewRow('Especialidade', _vetSel?.especialidade ?? '-'),
            _reviewRow('Pet', _petSel?.nome ?? '-'),
            _reviewRow('Raça', _petSel?.raca ?? '-'),
            _reviewRow('Data', _dataSel != null ? DateFormat('dd/MM/yyyy').format(_dataSel!) : '-'),
            _reviewRow('Horário', _horaSel?.format(context) ?? '-'),
            _reviewRow('Motivo', _motivoCtrl.text.trim().isEmpty ? '-' : _motivoCtrl.text.trim()),
          ]),
        ],
      );

  Widget _selCard({required bool isSelected, required VoidCallback onTap,
      required Widget leading, required String title, required String subtitle}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Row(children: [
          leading,
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ])),
          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
        ]),
      ),
    );
  }

  Widget _pickerBtn({required IconData icon, required String label, required VoidCallback onTap}) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: AppColors.primary),
        label: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.border),
        ),
      );

  Widget _reviewCard(List<Widget> rows) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(children: rows),
      );

  Widget _reviewRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold,
              color: AppColors.textPrimary, fontSize: 14), textAlign: TextAlign.end)),
        ]),
      );

  String _stepLabel() {
    switch (_step) {
      case 1: return 'Passo 1 de 4 — Veterinário';
      case 2: return 'Passo 2 de 4 — Pet';
      case 3: return 'Passo 3 de 4 — Data & Horário';
      default: return 'Passo 4 de 4 — Confirmação';
    }
  }
}
