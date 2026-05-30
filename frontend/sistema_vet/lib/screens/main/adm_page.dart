/* Aba "Admin" da tela principal.
 * Funciona em dois estados:
 * 1. Não autenticado: exibe o formulário de login do administrador (_AdminLoginPanel)
 * 2. Autenticado:     exibe o dashboard de gerenciamento (_AdminDashboard)
 *
 * Por que login separado?
 * O admin usa credenciais diferentes do dono. O token do admin é salvo em
 * chave separada no SharedPreferences (AdminAuthService), permitindo que
 * dono e admin estejam logados simultaneamente.
 *
 * O Dashboard tem 3 abas:
 * - Clínicas:     criar e remover clínicas veterinárias
 * - Veterinários: criar, ativar, inativar e ver agenda de veterinários
 * - Tutores:      listar donos cadastrados (somente leitura) */
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/clinica_model.dart';
import '../../models/veterinario_model.dart';
import '../../models/dono_model.dart';
import '../../services/admin_auth_service.dart';
import '../../services/clinica_service.dart';
import '../../services/veterinario_service.dart';
import '../../services/dono_service.dart';
import '../veterinarios/vet_agenda_screen.dart';

class AdmPage extends StatefulWidget {
  const AdmPage({super.key});
  @override
  State<AdmPage> createState() => _AdmPageState();
}

class _AdmPageState extends State<AdmPage> {
  bool _adminLoggedIn = false;
  bool _checkingAuth  = true;

  @override
  void initState() { super.initState(); _checkAdminAuth(); }

  Future<void> _checkAdminAuth() async {
    final loggedIn = await AdminAuthService.isAdminLoggedIn();
    if (mounted) setState(() { _adminLoggedIn = loggedIn; _checkingAuth = false; });
  }

  void _onAdminLoggedIn() => setState(() => _adminLoggedIn = true);

  Future<void> _onLogout() async {
    await AdminAuthService.logoutAdmin();
    if (mounted) setState(() => _adminLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (!_adminLoggedIn) return _AdminLoginPanel(onLoggedIn: _onAdminLoggedIn);
    return _AdminDashboard(onLogout: _onLogout);
  }
}

// ─── LOGIN DO ADMIN ───────────────────────────────────────────────────────────
class _AdminLoginPanel extends StatefulWidget {
  final VoidCallback onLoggedIn;
  const _AdminLoginPanel({required this.onLoggedIn});
  @override
  State<_AdminLoginPanel> createState() => _AdminLoginPanelState();
}

class _AdminLoginPanelState extends State<_AdminLoginPanel> {
  final _usuarioCtrl = TextEditingController();
  final _senhaCtrl   = TextEditingController();
  bool    _loading = false;
  bool    _obscure = true;
  String? _error;

  @override
  void dispose() { _usuarioCtrl.dispose(); _senhaCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    final usuario = _usuarioCtrl.text.trim();
    final senha   = _senhaCtrl.text;
    if (usuario.isEmpty || senha.isEmpty) {
      setState(() => _error = 'Preencha usuario e senha.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AdminAuthService.loginAdmin(usuario, senha);
      if (mounted) widget.onLoggedIn();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 56),
            ),
            const SizedBox(height: 24),
            const Text('Painel Administrativo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Acesso restrito a administradores',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 32),
            Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
              ),
              padding: const EdgeInsets.all(28),
              child: Column(children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildLoginField('Usuario', Icons.person_outline, _usuarioCtrl),
                const SizedBox(height: 14),
                _buildLoginField('Senha', Icons.lock_outline, _senhaCtrl,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMuted, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Entrar como Admin',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildLoginField(String label, IconData icon, TextEditingController ctrl,
      {bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(child: TextField(
          controller: ctrl,
          obscureText: obscure,
          onSubmitted: (_) => _login(),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            border: InputBorder.none,
          ),
        )),
        if (suffix != null) suffix,
      ]),
    );
  }
}

// ─── DASHBOARD ADMIN ─────────────────────────────────────────────────────────
class _AdminDashboard extends StatefulWidget {
  final Future<void> Function() onLogout;
  const _AdminDashboard({required this.onLogout});
  @override
  State<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<_AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<ClinicaModel>     _clinicas = [];
  List<VeterinarioModel> _vets     = [];
  List<DonoModel>        _donos    = [];
  bool    _loadCli = true, _loadVet = true, _loadDon = true;
  String? _erroCli, _erroVet, _erroDon;
  String? _adminUser;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadAll();
    AdminAuthService.getAdminUsuario().then((u) {
      if (mounted) setState(() => _adminUser = u);
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _loadAll() { _loadClinicas(); _loadVets(); _loadDonos(); }

  Future<void> _loadClinicas() async {
    if (mounted) setState(() { _loadCli = true; _erroCli = null; });
    try {
      final result = await ClinicaService.listarTodas();
      if (mounted) setState(() { _clinicas = result; _loadCli = false; });
    } catch (e) {
      if (mounted) setState(() { _loadCli = false; _erroCli = e.toString(); });
    }
  }

  Future<void> _loadVets() async {
    if (mounted) setState(() { _loadVet = true; _erroVet = null; });
    try {
      final adminToken = await AdminAuthService.getAdminToken();
      final result = await VeterinarioService.listar(pageSize: 100, customToken: adminToken);
      if (mounted) setState(() { _vets = result.items; _loadVet = false; });
    } catch (e) {
      if (mounted) setState(() { _loadVet = false; _erroVet = e.toString(); });
    }
  }

  Future<void> _loadDonos() async {
    if (mounted) setState(() { _loadDon = true; _erroDon = null; });
    try {
      final adminToken = await AdminAuthService.getAdminToken();
      final result = await DonoService.listar(pageSize: 100, customToken: adminToken);
      if (mounted) setState(() { _donos = result.items; _loadDon = false; });
    } catch (e) {
      if (mounted) setState(() { _loadDon = false; _erroDon = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(child: TabBarView(
          controller: _tab,
          children: [_buildClinicas(), _buildVets(), _buildDonos()],
        )),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Painel Admin',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          if (_adminUser != null)
            Text('Logado como: $_adminUser',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
        ])),
        TextButton.icon(
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sair do Admin'),
                content: const Text('Deseja encerrar a sessao de administrador?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sair', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
            if (ok == true) await widget.onLogout();
          },
          icon: const Icon(Icons.logout, color: Colors.white, size: 18),
          label: const Text('Sair', style: TextStyle(color: Colors.white)),
        ),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(icon: Icon(Icons.local_hospital_outlined, size: 20), text: 'Clinicas'),
          Tab(icon: Icon(Icons.medical_services_outlined, size: 20), text: 'Veterinarios'),
          Tab(icon: Icon(Icons.people_outline, size: 20), text: 'Tutores'),
        ],
      ),
    );
  }

  // ── TAB CLINICAS ──────────────────────────────────────────────────────────
  Widget _buildClinicas() {
    return Stack(children: [
      _bgLogo(),
      if (_loadCli)
        const Center(child: CircularProgressIndicator(color: AppColors.primary))
      else if (_erroCli != null)
        _erroWidget(_erroCli!, _loadClinicas)
      else
        RefreshIndicator(
          onRefresh: _loadClinicas,
          color: AppColors.primary,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            _sectionHeader('CLINICAS', _clinicas.length, _novaClinica),
            const SizedBox(height: 12),
            if (_clinicas.isEmpty)
              _emptyState('Nenhuma clinica cadastrada.')
            else
              ..._clinicas.map((c) => _clinicaCard(c)),
          ]),
        ),
    ]);
  }

  Widget _clinicaCard(ClinicaModel c) {
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
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: c.ativo ? AppColors.primaryLight : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.local_hospital,
              color: c.ativo ? AppColors.primary : AppColors.textMuted, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(c.endereco, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(c.telefone, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ])),
        if (!c.ativo)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Inativa',
                style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () => _confirmarRemoverClinica(c),
        ),
      ]),
    );
  }

  void _novaClinica() {
    final nomeCtrl     = TextEditingController();
    final enderecoCtrl = TextEditingController();
    final telCtrl      = TextEditingController();
    final emailCtrl    = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nova Clinica', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field('Nome da Clinica *', nomeCtrl),
          _field('Endereco *', enderecoCtrl),
          _field('Telefone *', telCtrl, hint: '(00) 00000-0000'),
          _field('E-mail', emailCtrl, hint: 'Opcional'),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              try {
                await ClinicaService.criar(CreateClinicaRequest(
                  nome:     nomeCtrl.text.trim(),
                  endereco: enderecoCtrl.text.trim(),
                  telefone: telCtrl.text.trim(),
                  email:    emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                _loadClinicas();
              } catch (e) {
                if (ctx.mounted)
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error));
              }
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarRemoverClinica(ClinicaModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Clinica'),
        content: Text('Remover "${c.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              try {
                await ClinicaService.remover(c.id);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadClinicas();
                _loadVets();
              } catch (e) {
                if (ctx.mounted)
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error));
              }
            },
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── TAB VETERINARIOS ─────────────────────────────────────────────────────
  Widget _buildVets() {
    return Stack(children: [
      _bgLogo(),
      if (_loadVet)
        const Center(child: CircularProgressIndicator(color: AppColors.primary))
      else if (_erroVet != null)
        _erroWidget(_erroVet!, _loadVets)
      else
        RefreshIndicator(
          onRefresh: _loadVets,
          color: AppColors.primary,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            _sectionHeader('VETERINARIOS', _vets.length, _novoVet),
            const SizedBox(height: 12),
            if (_vets.isEmpty)
              _emptyState('Nenhum veterinario cadastrado.')
            else
              ..._vets.map((v) => _vetCard(v)),
          ]),
        ),
    ]);
  }

  Widget _vetCard(VeterinarioModel v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: v.ativo ? AppColors.primaryLight : const Color(0xFFF0F0F0),
              child: Text(v.iniciais,
                  style: TextStyle(
                      color: v.ativo ? AppColors.primary : AppColors.textMuted,
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.nome, style: const TextStyle(fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, fontSize: 14)),
              Text('${v.crmv} · ${v.especialidade}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              if (v.clinicaNome != null)
                Row(children: [
                  const Icon(Icons.local_hospital, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(v.clinicaNome!,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ])
              else
                const Text('Sem clinica vinculada',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ])),
            Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: v.ativo ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(v.ativo ? 'Ativo' : 'Inativo',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                        color: v.ativo ? AppColors.success : AppColors.error)),
              ),
              const SizedBox(height: 4),
              Switch(
                value: v.ativo,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) async {
                  try {
                    if (val) await VeterinarioService.ativar(v.id);
                    else     await VeterinarioService.inativar(v.id);
                    _loadVets();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error));
                  }
                },
              ),
            ]),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
          ),
          child: TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VetAgendaScreen(vet: v)),
            ),
            icon: const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
            label: const Text('Ver Agenda', style: TextStyle(color: AppColors.primary,
                fontWeight: FontWeight.w600, fontSize: 13)),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void _novoVet() {
    final nomeCtrl  = TextEditingController();
    final crmvCtrl  = TextEditingController();
    final specCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final telCtrl   = TextEditingController();
    ClinicaModel? clinicaSel;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Novo Veterinario', textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field('Nome *', nomeCtrl),
            _field('CRMV (ex: SP-12345) *', crmvCtrl),
            _field('Especialidade *', specCtrl),
            _field('E-mail *', emailCtrl),
            _field('Telefone *', telCtrl, hint: '(00) 00000-0000'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<ClinicaModel?>(
                value: clinicaSel,
                isExpanded: true,
                hint: const Text('Selecionar Clinica (opcional)',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<ClinicaModel?>(
                    value: null,
                    child: Text('-- Sem clinica --',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                  ..._clinicas.where((c) => c.ativo).map((c) =>
                    DropdownMenuItem<ClinicaModel?>(
                      value: c,
                      child: Row(children: [
                        const Icon(Icons.local_hospital, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(c.nome, style: const TextStyle(fontSize: 14)),
                      ]),
                    )),
                ],
                onChanged: (val) => setD(() => clinicaSel = val),
              ),
            ),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                try {
                  await VeterinarioService.criar(CreateVeterinarioRequest(
                    nome:          nomeCtrl.text.trim(),
                    crmv:          crmvCtrl.text.trim(),
                    especialidade: specCtrl.text.trim(),
                    email:         emailCtrl.text.trim(),
                    telefone:      telCtrl.text.trim(),
                    clinicaId:     clinicaSel?.id,
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadVets();
                } catch (e) {
                  if (ctx.mounted)
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.error));
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB DONOS ────────────────────────────────────────────────────────────
  Widget _buildDonos() {
    return Stack(children: [
      _bgLogo(),
      if (_loadDon)
        const Center(child: CircularProgressIndicator(color: AppColors.primary))
      else if (_erroDon != null)
        _erroWidget(_erroDon!, _loadDonos)
      else
        RefreshIndicator(
          onRefresh: _loadDonos,
          color: AppColors.primary,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            _sectionHeader('TUTORES / DONOS', _donos.length, null),
            const SizedBox(height: 12),
            if (_donos.isEmpty)
              _emptyState('Nenhum tutor cadastrado.')
            else
              ..._donos.map((d) => _donoCard(d)),
          ]),
        ),
    ]);
  }

  Widget _donoCard(DonoModel d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        const CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person_outline, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(d.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text('CPF: ${d.cpf}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────
  Widget _bgLogo() => Center(child: Opacity(opacity: 0.04,
      child: Image.asset('assets/logo.png', width: 400, fit: BoxFit.contain)));

  Widget _emptyState(String msg) => Padding(
      padding: const EdgeInsets.all(32),
      child: Center(child: Text(msg, style: const TextStyle(color: AppColors.textMuted))));

  Widget _erroWidget(String erro, VoidCallback onRetry) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text('Erro ao carregar dados', style: const TextStyle(
            fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15)),
        const SizedBox(height: 6),
        Text(erro, style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
        ),
      ]),
    ),
  );

  Widget _sectionHeader(String label, int count, VoidCallback? onAdd) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Text(label, style: const TextStyle(
            fontWeight: FontWeight.bold, color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ]),
      if (onAdd != null)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onAdd,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text('Novo', style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold, fontSize: 13)),
        ),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint ?? label,
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }
}
