import 'dart:ffi';

class Trip {
  final String IMEI;
  final int driverid;
  final int fuelCapacity;
  final int personCapacity;
  final int routeId;
  final String status;
  final String vehicleNo;

  Trip(this.IMEI, this.driverid, this.fuelCapacity, this.personCapacity,
      this.routeId, this.status, this.vehicleNo);
}
