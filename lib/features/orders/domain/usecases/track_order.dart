import '../entities/shipment.dart';
import '../repositories/orders_repository.dart';

class TrackOrderParams {
  final String? orderId;
  final String? trackingNumber;

  const TrackOrderParams({
    this.orderId,
    this.trackingNumber,
  });

  bool get isValid => orderId != null || trackingNumber != null;
}

class TrackOrder {
  final OrdersRepository repository;

  TrackOrder(this.repository);

  Future<List<Shipment>> call(TrackOrderParams params) async {
    if (!params.isValid) {
      throw ArgumentError('Either orderId or trackingNumber must be provided');
    }

    if (params.orderId != null) {
      return await repository.getOrderShipments(params.orderId!);
    }

    if (params.trackingNumber != null) {
      final shipment = await repository.getShipmentByTrackingNumber(params.trackingNumber!);
      return shipment != null ? [shipment] : [];
    }

    return [];
  }
}

class TrackMultipleShipments {
  final OrdersRepository repository;

  TrackMultipleShipments(this.repository);

  Future<List<Shipment>> call(List<String> trackingNumbers) async {
    if (trackingNumbers.isEmpty) {
      throw ArgumentError('At least one tracking number must be provided');
    }

    return await repository.trackShipments(trackingNumbers);
  }
}

class GetShipmentDetails {
  final OrdersRepository repository;

  GetShipmentDetails(this.repository);

  Future<Shipment?> call(String shipmentId) async {
    return await repository.getShipmentById(shipmentId);
  }
}
