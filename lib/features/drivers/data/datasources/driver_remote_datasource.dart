import '../models/driver_model.dart';

abstract class DriverRemoteDataSource {
  Future<List<DriverModel>> fetchDrivers();
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  @override
  Future<List<DriverModel>> fetchDrivers() async {
    // Simulate network API call latency
    await Future.delayed(const Duration(milliseconds: 600));

    // Realistic driver dataset with locations & prices
    return const [
      // Local drivers (distance <= 100 KM)
      DriverModel(
        driverId: 'drv_101',
        name: 'Rajesh Kumar',
        mobileNumber: '+91 98765 43210',
        address: 'Kukatpally, Hyderabad',
        latitude: 17.4920,
        longitude: 78.3950,
        profileImage: null,
        carName: 'Toyota Etios',
        carType: 'Sedan',
        rating: 4.8,
        distance: 5.2,
        price: 200.0,
      ),
      DriverModel(
        driverId: 'drv_102',
        name: 'Suresh Verma',
        mobileNumber: '+91 98123 45678',
        address: 'Hitec City, Hyderabad',
        latitude: 17.4435,
        longitude: 78.3772,
        profileImage: null,
        carName: 'Swift Dzire',
        carType: 'Sedan',
        rating: 4.9,
        distance: 12.5,
        price: 250.0,
      ),
      DriverModel(
        driverId: 'drv_103',
        name: 'Venkatesh Rao',
        mobileNumber: '+91 97012 34567',
        address: 'Secunderabad, Telangana',
        latitude: 17.4399,
        longitude: 78.4983,
        profileImage: null,
        carName: 'Honda City',
        carType: 'Sedan Premium',
        rating: 4.7,
        distance: 24.0,
        price: 350.0,
      ),
      DriverModel(
        driverId: 'drv_104',
        name: 'Mahesh Babu',
        mobileNumber: '+91 96543 21098',
        address: 'Sangareddy, Telangana',
        latitude: 17.6294,
        longitude: 78.0917,
        profileImage: null,
        carName: 'Innova Crysta',
        carType: 'SUV',
        rating: 4.9,
        distance: 60.0,
        price: 450.0,
      ),
      DriverModel(
        driverId: 'drv_105',
        name: 'Ramesh Naidu',
        mobileNumber: '+91 95432 10987',
        address: 'Mahbubnagar, Telangana',
        latitude: 16.7488,
        longitude: 78.0035,
        profileImage: null,
        carName: 'Ertiga',
        carType: 'MUV',
        rating: 4.6,
        distance: 95.0,
        price: 300.0,
      ),

      // Outstation drivers (distance > 100 KM)
      DriverModel(
        driverId: 'drv_201',
        name: 'Kiran Reddy',
        mobileNumber: '+91 94321 09876',
        address: 'Nizamabad, Telangana',
        latitude: 18.6725,
        longitude: 78.0941,
        profileImage: null,
        carName: 'Innova Crysta',
        carType: 'SUV Premium',
        rating: 4.9,
        distance: 125.0,
        price: 600.0,
      ),
      DriverModel(
        driverId: 'drv_202',
        name: 'Anil Chawla',
        mobileNumber: '+91 93210 98765',
        address: 'Warangal, Telangana',
        latitude: 17.9689,
        longitude: 79.5941,
        profileImage: null,
        carName: 'Hyundai Creta',
        carType: 'SUV',
        rating: 4.8,
        distance: 148.0,
        price: 550.0,
      ),
      DriverModel(
        driverId: 'drv_203',
        name: 'Pradeep Singh',
        mobileNumber: '+91 92109 87654',
        address: 'Vijayawada, Andhra Pradesh',
        latitude: 16.5062,
        longitude: 80.6480,
        profileImage: null,
        carName: 'Toyota Fortuner',
        carType: 'Luxury SUV',
        rating: 5.0,
        distance: 276.0,
        price: 900.0,
      ),
      DriverModel(
        driverId: 'drv_204',
        name: 'Ganesh Shinde',
        mobileNumber: '+91 91098 76543',
        address: 'Visakhapatnam, AP',
        latitude: 17.6868,
        longitude: 83.2185,
        profileImage: null,
        carName: 'Mahindra XUV700',
        carType: 'SUV',
        rating: 4.7,
        distance: 350.0,
        price: 800.0,
      ),
    ];
  }
}
