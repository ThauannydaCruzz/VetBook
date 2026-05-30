/* Dialog de cadastro de novo pet.
 * Coleta nome, espécie, raça, idade, peso e sexo do animal.
 * O donoId é preenchido automaticamente com o ID do dono logado
 * (obtido via AuthService.getDonoId()). */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/pet_model.dart';
import '../../../services/pet_service.dart';
import '../../../services/auth_service.dart';

/// Abre o diálogo de cadastro de pet.
/// O donoId é obtido automaticamente do usuário logado.
/// Retorna [true] se o pet foi cadastrado com sucesso.
Future<bool> mostrarCadastrarPetDialog(BuildContext context) async {
  // Obtém o ID do dono logado automaticamente
  final donoId = await AuthService.getDonoId();

  if (!context.mounted) return false;

  if (donoId == null || donoId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível identificar o dono. Faça login novamente.'),
        backgroundColor: AppColors.error,
      ),
    );
    return false;
  }

  final nomeCtrl    = TextEditingController();
  final especieCtrl = TextEditingController();
  final racaCtrl    = TextEditingController();
  final idadeCtrl   = TextEditingController();
  final pesoCtrl    = TextEditingController();
  final obsCtrl     = TextEditingController();
  int sexo = 0; // 0 = Macho, 1 = Fêmea

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cadastrar Pet',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _campo('Nome do Animal *', nomeCtrl),
            _campo('Espécie (Cachorro, Gato...) *', especieCtrl),
            _campo('Raça *', racaCtrl),
            _campo('Idade (anos) *', idadeCtrl, numeric: true),
            _campo('Peso (kg) *', pesoCtrl, numeric: true),
            _campo('Observações', obsCtrl),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Sexo:', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Macho'),
                selected: sexo == 0,
                selectedColor: AppColors.primaryLight,
                onSelected: (_) => setS(() => sexo = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Fêmea'),
                selected: sexo == 1,
                selectedColor: AppColors.primaryLight,
                onSelected: (_) => setS(() => sexo = 1),
              ),
            ]),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nomeCtrl.text.trim().isEmpty ||
                  especieCtrl.text.trim().isEmpty ||
                  racaCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text('Preencha os campos obrigatórios.'),
                      backgroundColor: AppColors.error),
                );
                return;
              }
              try {
                await PetService.criar(CreatePetRequest(
                  nome:    nomeCtrl.text.trim(),
                  especie: especieCtrl.text.trim(),
                  raca:    racaCtrl.text.trim(),
                  idade:   int.tryParse(idadeCtrl.text) ?? 1,
                  peso:    double.tryParse(pesoCtrl.text.replaceAll(',', '.')) ?? 1.0,
                  sexo:    sexo,
                  donoId:  donoId, // ← preenchido automaticamente
                  observacoes: obsCtrl.text.trim().isEmpty ? null : obsCtrl.text.trim(),
                ));
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                        content: Text('Erro: $e'),
                        backgroundColor: AppColors.error),
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

  return result == true;
}

Widget _campo(String label, TextEditingController ctrl, {bool numeric = false}) {
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
