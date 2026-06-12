import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MillasTrackerHome(),
    );
  }
}

class MillasTrackerHome extends StatefulWidget {
  const MillasTrackerHome({super.key});

  @override
  State<MillasTrackerHome> createState() => _MillasTrackerHomeState();
}

class _MillasTrackerHomeState extends State<MillasTrackerHome> {
  double _totalMillas = 0.0;
  Position? _ultimaPosicion;
  bool _rastreando = false;

  double _metrosAMillas(double metros) {
    return metros * 0.000621371;
  }

  void _iniciarRastreo() async {
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }
    
    if (permiso == LocationPermission.deniedForever) return;

    setState(() {
      _rastreando = true;
    });

    const configuracion = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: configuracion).listen((Position posicion) {
      if (_ultimaPosicion != null) {
        double distanciaEnMetros = Geolocator.distanceBetween(
          _ultimaPosicion!.latitude,
          _ultimaPosicion!.longitude,
          posicion.latitude,
          posicion.longitude,
        );

        setState(() {
          _totalMillas += _metrosAMillas(distanciaEnMetros);
        });
      }
      _ultimaPosicion = posicion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrador de Millas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Millas Recorridas:', style: TextStyle(fontSize: 24)),
            Text(
              _totalMillas.toStringAsFixed(2), 
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _rastreando ? null : _iniciarRastreo,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
              child: Text(_rastreando ? 'Rastreando en segundo plano...' : 'Iniciar Registro'),
            ),
          ],
        ),
      ),
    );
  }
}