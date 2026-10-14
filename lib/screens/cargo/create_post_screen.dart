import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cargoo_shared/cargoo_shared.dart';
import 'post_candidates_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _pickupController =
      TextEditingController(text: 'Minha localização atual');
  final _dropoffController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _cargoApi = CargoApi();
  VehicleType? _selectedType;
  List<VehicleType> _vehicleTypes = [];
  bool _needsHelper = false;
  bool _isFragile = false;
  bool _loading = true;
  bool _publishing = false;
  String? _loadError;

  String _assetForVehicleType(String id) {
    switch (id.toLowerCase()) {
      case 'moto':
        return 'assets/images/client/vehicle_moto.svg';
      case 'van':
        return 'assets/images/client/vehicle_van.svg';
      case 'truck':
        return 'assets/images/client/vehicle_truck.svg';
      default:
        return 'assets/images/client/vehicle_utility.svg';
    }
  }

  @override
  void initState() {
    super.initState();
    _dropoffController.addListener(_onFormChanged);
    _loadVehicleTypes();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadVehicleTypes() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final vehicleTypes = await _cargoApi.loadVehicleTypes();
      if (vehicleTypes.isEmpty) {
        throw StateError('Não há tipos de veículo configurados no servidor.');
      }
      if (!mounted) return;
      setState(() {
        _vehicleTypes = vehicleTypes;
        _selectedType = vehicleTypes.first;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Não foi possível carregar os tipos de veículo: $error';
        _loading = false;
      });
    }
  }

  Future<void> _publish() async {
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final cargoWeightKg =
        weightText.isEmpty ? null : double.tryParse(weightText);
    if (weightText.isNotEmpty &&
        (cargoWeightKg == null || cargoWeightKg <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um peso válido maior que zero.')),
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      final post = await _cargoApi.createPost(
        CreateCargoPostRequest(
          title: _titleController.text,
          description: _descriptionController.text,
          cargoWeightKg: cargoWeightKg,
          isFragile: _isFragile,
          needsHelper: _needsHelper,
          vehicleTypeId: _selectedType!.id,
          pickupAddress: _pickupController.text,
          dropoffAddress: _dropoffController.text,
        ),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => PostCandidatesScreen(post: post)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _publishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível publicar: $e')));
      }
    }
  }

  @override
  void dispose() {
    _dropoffController.removeListener(_onFormChanged);
    _pickupController.dispose();
    _dropoffController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Enviar carga')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _loadVehicleTypes,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar carga')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
                'Publique o pedido e receba propostas de preço de motoristas interessados.',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const SizedBox(height: 20),
            Row(children: [
              const Icon(Icons.my_location, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(
                  child: TextField(
                      controller: _pickupController,
                      decoration: const InputDecoration(labelText: 'Coleta'))),
            ]),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: SizedBox(
                    height: 20,
                    child: VerticalDivider(
                        color: AppColors.divider, thickness: 2))),
            Row(children: [
              const Icon(Icons.location_on, color: AppColors.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                  child: TextField(
                      controller: _dropoffController,
                      decoration: const InputDecoration(
                          labelText: 'Entrega',
                          hintText: 'Endereço de destino'))),
            ]),
            const SizedBox(height: 20),
            CustomTextField(
                label: 'Título do pedido',
                hint: 'Ex: 3 caixas de eletrônicos',
                controller: _titleController,
                prefixIcon: Icons.title),
            const SizedBox(height: 16),
            CustomTextField(
                label: 'Descrição',
                hint: 'Detalhes sobre a carga',
                controller: _descriptionController,
                prefixIcon: Icons.inventory_2_outlined,
                maxLines: 3),
            const SizedBox(height: 16),
            CustomTextField(
                label: 'Peso estimado (kg)',
                hint: 'Ex: 40',
                controller: _weightController,
                prefixIcon: Icons.scale_outlined,
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const Text('Tipo de veículo desejado',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _vehicleTypes.map((v) {
                  final selected = v.id == _selectedType?.id;
                  return ChoiceChip(
                    label: Text(v.name),
                    avatar: SvgPicture.asset(_assetForVehicleType(v.id),
                        width: 34, height: 24),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedType = v),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600),
                    side: BorderSide(
                        color:
                            selected ? AppColors.primary : AppColors.divider),
                  );
                }).toList()),
            const SizedBox(height: 12),
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Preciso de ajudante',
                    style: TextStyle(fontSize: 14)),
                value: _needsHelper,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _needsHelper = v)),
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title:
                    const Text('Carga frágil', style: TextStyle(fontSize: 14)),
                value: _isFragile,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _isFragile = v)),
            const SizedBox(height: 24),
            CustomButton(
                label: 'Publicar pedido',
                loading: _publishing,
                onPressed:
                    _dropoffController.text.trim().isEmpty ? null : _publish),
          ]),
        ),
      ),
    );
  }
}
