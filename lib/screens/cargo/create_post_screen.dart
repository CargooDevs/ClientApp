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
  VehicleType? _selectedType;
  List<VehicleType> _vehicleTypes = VehicleType.fallback;
  bool _needsHelper = false;
  bool _isFragile = false;
  bool _loading = true;
  bool _publishing = false;

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
    _loadVehicleTypes();
  }

  Future<void> _loadVehicleTypes() async {
    try {
      final rows = await SupabaseService.client.from('vehicle_types').select();
      if (rows.isNotEmpty) {
        _vehicleTypes = rows.map((r) => VehicleType.fromMap(r)).toList();
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _selectedType = _vehicleTypes.first;
        _loading = false;
      });
    }
  }

  Future<void> _publish() async {
    setState(() => _publishing = true);
    try {
      final row = await SupabaseService.client
          .from('posts')
          .insert({
            'user_id': SupabaseService.uid,
            'title': _titleController.text.trim().isEmpty
                ? 'Envio de carga'
                : _titleController.text.trim(),
            'status': 'open',
            'vehicle_type_id': _selectedType!.id,
            'category': 'cargo',
            'description': _descriptionController.text.trim(),
            'cargo_weight_kg':
                double.tryParse(_weightController.text.replaceAll(',', '.')),
            'is_fragile': _isFragile,
            'needs_helper': _needsHelper,
            'pickup_address': _pickupController.text,
            'dropoff_address': _dropoffController.text,
          })
          .select()
          .single();

      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) =>
                PostCandidatesScreen(post: CargoPost.fromMap(row))));
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
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
