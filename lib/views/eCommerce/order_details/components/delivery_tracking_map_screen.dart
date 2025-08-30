
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class DeliveryTrackingMapScreen extends StatefulWidget {
  final int driverId;
  final double initialDeliveryLat;
  final double initialDeliveryLng;
  final double customerLat;
  final double customerLng;
  final String? driverName;
  final String? driverPhotoUrl;
  final String? driverVehicle;
  final String? eta;

  const DeliveryTrackingMapScreen({
    super.key,
    required this.driverId,
    required this.initialDeliveryLat,
    required this.initialDeliveryLng,
    required this.customerLat,
    required this.customerLng,
    this.driverName,
    this.driverPhotoUrl,
    this.driverVehicle,
    this.eta,
  });

  @override
  State<DeliveryTrackingMapScreen> createState() => _DeliveryTrackingMapScreenState();
}

class _DeliveryTrackingMapScreenState extends State<DeliveryTrackingMapScreen> {
  late double deliveryLat;
  late double deliveryLng;
  late GoogleMapController _mapController;
  StreamSubscription? _pusherSubscription;

  @override
  void initState() {
    super.initState();
    deliveryLat = widget.initialDeliveryLat;
    deliveryLng = widget.initialDeliveryLng;
    _subscribeToDriverLocation();
  }

  @override
  void dispose() {
    _pusherSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToDriverLocation() async {
    final pusher = PusherChannelsFlutter.getInstance();
    await pusher.init(
      apiKey: 'a3cbadc04a202a7746fc',
      cluster: 'mt1',
      onEvent: (PusherEvent event) {
        if (event.eventName == 'driver-location-update') {
          final data = event.data;
          if (data != null) {
            final decoded = data is String ? data : data.toString();
            final latMatch = RegExp(r'"lat":([0-9.\-]+)').firstMatch(decoded);
            final lngMatch = RegExp(r'"lng":([0-9.\-]+)').firstMatch(decoded);
            if (latMatch != null && lngMatch != null) {
              setState(() {
                deliveryLat = double.parse(latMatch.group(1)!);
                deliveryLng = double.parse(lngMatch.group(1)!);
              });
              _mapController.animateCamera(
                CameraUpdate.newLatLng(LatLng(deliveryLat, deliveryLng)),
              );
            }
          }
        }
      },
    );
    await pusher.connect();
    final channelName = 'driver-location-${widget.driverId}';
    pusher.subscribe(channelName: channelName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Delivery')),
      body: Column(
        children: [
          if (widget.driverName != null || widget.driverPhotoUrl != null || widget.driverVehicle != null || widget.eta != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (widget.driverPhotoUrl != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.driverPhotoUrl!),
                      radius: 24,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.driverName != null)
                          Text(widget.driverName!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (widget.driverVehicle != null)
                          Text('Vehicle: ${widget.driverVehicle!}'),
                        if (widget.eta != null)
                          Text('ETA: ${widget.eta!}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(deliveryLat, deliveryLng),
                zoom: 14,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                Marker(
                  markerId: const MarkerId('delivery'),
                  position: LatLng(deliveryLat, deliveryLng),
                  infoWindow: const InfoWindow(title: 'Delivery Person'),
                ),
                Marker(
                  markerId: const MarkerId('customer'),
                  position: LatLng(widget.customerLat, widget.customerLng),
                  infoWindow: const InfoWindow(title: 'Your Address'),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [
                    LatLng(deliveryLat, deliveryLng),
                    LatLng(widget.customerLat, widget.customerLng),
                  ],
                  color: Colors.blue,
                  width: 4,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
