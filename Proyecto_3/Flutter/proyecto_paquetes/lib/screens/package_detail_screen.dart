import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/package_model.dart';
import 'deliver_screen.dart';

class PackageDetailScreen extends StatelessWidget {
  final PackageModel package;

  const PackageDetailScreen({Key? key, required this.package}) : super(key: key);

  // ============================
  // MAPA MODERNO FEDEX
  // ============================
  Widget buildPackageMap(double lat, double lng) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.paquexpress.app",
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // UI ESTILO FEDEX
  // ============================
  @override
  Widget build(BuildContext context) {
    const Color fedexPurple = Color(0xFF4D148C);
    const Color fedexOrange = Color(0xFFFF6600);

    return Scaffold(
      backgroundColor: Colors.white,

      // APPBAR FEDEX
      appBar: AppBar(
        backgroundColor: fedexPurple,
        title: Text(
          'Detalle - ${package.clientName}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================
            // CARD DEL CLIENTE / DIRECCIÓN
            // ============================
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
                  ),
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
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: fedexPurple,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.clientName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.address,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ============================
            // MAPA
            // ============================
            if (package.latitude != null && package.longitude != null)
              buildPackageMap(package.latitude!, package.longitude!)
            else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Coordenadas no disponibles para este paquete.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            const SizedBox(height: 30),

            // ============================
            // BOTÓN ENTREGAR PAQUETE
            // ============================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: fedexOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Entregar paquete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DeliverScreen(package: package),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


