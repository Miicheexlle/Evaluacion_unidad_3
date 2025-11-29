import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/package_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class DeliverScreen extends StatefulWidget {
  final PackageModel package;

  const DeliverScreen({Key? key, required this.package}) : super(key: key);

  @override
  State<DeliverScreen> createState() => _DeliverScreenState();
}

class _DeliverScreenState extends State<DeliverScreen> {
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _filename;

  bool _sending = false;
  String? _status;

  double? _lat;
  double? _lng;

  // -------------------- SUBIR FOTO --------------------
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null && result.files.isNotEmpty) {
      final f = result.files.first;
      _filename = f.name;

      setState(() {
        if (kIsWeb) {
          _imageBytes = f.bytes;
          _imageFile = null;
        } else {
          _imageFile = File(f.path!);
          _imageBytes = null;
        }
      });
    }
  }

  // -------------------- TOMAR UBICACIÓN --------------------
  Future<void> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      setState(() => _status = "Activa el GPS.");
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        setState(() => _status = "Permiso denegado.");
        return;
      }
    }

    if (perm == LocationPermission.deniedForever) {
      setState(() => _status = "Permiso denegado permanentemente.");
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _status = null;
    });
  }

  // -------------------- PREVIEW FOTO --------------------
  Widget _previewWidget() {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _imageBytes != null
          ? Image.memory(_imageBytes!, fit: BoxFit.cover)
          : _imageFile != null
              ? Image.file(_imageFile!, fit: BoxFit.cover)
              : const Center(
                  child: Text(
                    "Sin foto",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
    );
  }

  // -------------------- MAPA DE ENTREGA --------------------
  Widget _deliveryMap() {
    if (_lat == null || _lng == null) {
      return const Text("Ubicación no tomada",
          style: TextStyle(color: Colors.grey));
    }

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(_lat!, _lng!),
          initialZoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.paquexpress.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_lat!, _lng!),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------- ENVIAR ENTREGA --------------------
  Future<void> _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (kIsWeb) {
      if (_imageBytes == null || _filename == null) {
        setState(() => _status = "Sube una foto.");
        return;
      }
    } else {
      if (_imageFile == null) {
        setState(() => _status = "Sube una foto.");
        return;
      }
    }

    if (_lat == null || _lng == null) {
      setState(() => _status = "Toma la ubicación.");
      return;
    }

    setState(() {
      _sending = true;
      _status = null;
    });

    try {
      final resp = await ApiService.deliverPackage(
        packageId: widget.package.packageId,
        userId: auth.userId!,
        latitude: _lat!,
        longitude: _lng!,
        filename: kIsWeb ? _filename : null,
        photoBytes: kIsWeb ? _imageBytes : null,
        photoFile: kIsWeb ? null : _imageFile,
      );

      setState(() {
        _status = "Entrega registrada correctamente.\n${resp['delivery_address']}";
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _sending = false);
    }
  }

  // -------------------- UI PRINCIPAL --------------------
  @override
  Widget build(BuildContext context) {
    const Color fedexPurple = Color(0xFF4D148C);
    const Color fedexOrange = Color(0xFFFF6600);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: fedexPurple,
        title: Text(
          'Entregar - ${widget.package.clientName}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // -------------------- CARD PAQUETE --------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fedexPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2,
                        color: fedexPurple, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.package.clientName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.package.address,
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),
            _previewWidget(),
            const SizedBox(height: 20),

            // -------------------- BOTONES FOTO / UBICACIÓN --------------------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.photo_camera_back),
                    label: const Text("Subir foto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fedexPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _getLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text("GPS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fedexOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _deliveryMap(),
            const SizedBox(height: 25),

            // -------------------- BOTÓN SUBMIT --------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: fedexOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Registrar entrega',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 15),
            if (_status != null)
              Text(
                _status!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      _status!.startsWith("Error") ? Colors.red : fedexPurple,
                  fontSize: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
