/* Aba "Meus Pets" da tela principal.
 * Exibe a lista de pets cadastrados:
 * - Se o usuário for um Dono: mostra apenas seus próprios pets (via listarPorDono)
 * - Se for Admin: mostra todos os pets com paginação
 *
 * Funcionalidades:
 * - Listar pets com atualização por pull-to-refresh
 * - Cadastrar novo pet via dialog inline (donoId preenchido automaticamente)
 * - Remover pet (com confirmação) — bloqueado se houver consultas futuras */
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/pet_model.dart';
import '../../services/pet_service.dart';
import '../../services/auth_service.dart';

class MeusPetsPage extends StatefulWidget {
  const MeusPetsPage({super.key});

  @override
  State<MeusPetsPage> createState() => _MeusPetsPageState();
}

class _MeusPetsPageState extends State<MeusPetsPage> {
  List<PetModel> _pets = [];
  bool _loading = true;
  String? _error;
  String? _donoId;
  bool _isDono = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _donoId = await AuthService.getDonoId();
    _isDono = await AuthService.isDono();
    await _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      List<PetModel> pets;
      if (_isDono && _donoId != null) {
        pets = await PetService.listarPorDono(_donoId!);
      } else {
        final result = await PetService.listar(pageSize: 50);
        pets = result.items;
      }
      if (mounted) setState(() { _pets = pets; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _mostrarCadastroPet() async {
    // donoId obtido automaticamente — sem campo manual
    if (_isDono && (_donoId == null || _donoId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar o dono. Faça login novamente.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final nomeCtrl    = TextEditingController();
    final especieCtrl = TextEditingController();
    final racaCtrl    = TextEditingController();
    final idadeCtrl   = TextEditingController();
    final pesoCtrl    = TextEditingController();
    int sexo = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Novo Pet', textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _inputDialog('Nome do Animal', nomeCtrl),
              _inputDialog('Espécie (Cachorro, Gato...)', especieCtrl),
              _inputDialog('Raça', racaCtrl),
              _inputDialog('Idade (anos)', idadeCtrl, numeric: true),
              _inputDialog('Peso (kg)', pesoCtrl, numeric: true),
              const SizedBox(height: 8),
              Row(children: [
                const Text('Sexo:', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(width: 16),
                ChoiceChip(label: const Text('Macho'), selected: sexo == 0,
                    onSelected: (_) => setS(() => sexo = 0)),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Fêmea'), selected: sexo == 1,
                    onSelected: (_) => setS(() => sexo = 1)),
              ]),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                try {
                  await PetService.criar(CreatePetRequest(
                    nome:    nomeCtrl.text.trim(),
                    especie: especieCtrl.text.trim(),
                    raca:    racaCtrl.text.trim(),
                    idade:   int.tryParse(idadeCtrl.text) ?? 1,
                    peso:    double.tryParse(pesoCtrl.text.replaceAll(',', '.')) ?? 1.0,
                    sexo:    sexo,
                    donoId:  _donoId ?? '', // ← preenchido automaticamente
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Center(child: Opacity(opacity: 0.07,
              child: Image.asset('assets/logo.png', width: 550, height: 550, fit: BoxFit.contain))),
          RefreshIndicator(
            onRefresh: _load,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('MEUS PETS',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: _mostrarCadastroPet,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Cadastrar', style: TextStyle(color: Colors.white)),
                  ),
                ]),
                const SizedBox(height: 16),
                if (_loading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ))
                else if (_error != null)
                  _errorCard()
                else if (_pets.isEmpty)
                  _emptyState()
                else
                  ..._pets.map((p) => _petCard(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _petCard(PetModel pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(pet.emojiEspecie, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pet.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          Text('${pet.raca} · ${pet.idade} anos · ${pet.peso}kg',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          if (pet.observacoes != null && pet.observacoes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(pet.observacoes!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () => _confirmarRemocao(pet),
        ),
      ]),
    );
  }

  Future<void> _confirmarRemocao(PetModel pet) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Pet'),
        content: Text('Deseja remover ${pet.nome}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await PetService.remover(pet.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error),
      );
    }
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
          TextButton(onPressed: _load, child: const Text('Tentar novamente')),
        ]),
      );

  Widget _emptyState() => const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: Column(children: [
          Icon(Icons.pets, size: 64, color: AppColors.border),
          SizedBox(height: 12),
          Text('Nenhum pet cadastrado ainda.', style: TextStyle(color: AppColors.textMuted)),
          SizedBox(height: 4),
          Text('Toque em "Cadastrar" para adicionar.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ])),
      );

  Widget _inputDialog(String label, TextEditingController ctrl, {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
