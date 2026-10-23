import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/features/map/services/map_cluster_service.dart';
import 'package:yemen_real_estate_portal/models/property.dart';

void main() {
  group('MapClusterService Spatial Clustering Tests', () {
    final propSanaa1 = Property(
      id: 'p1',
      ownerId: 'u1',
      title: 'شقة حدة 1',
      description: 'وصف',
      dealType: 'rent',
      propertyTypeId: 'apartment',
      city: 'صنعاء',
      district: 'حدة',
      latitude: 15.3214,
      longitude: 44.1843,
      price: 150000,
      areaSqm: 120,
      contactPhone: '777000111',
      createdAt: DateTime.now(),
    );

    final propSanaa2 = Property(
      id: 'p2',
      ownerId: 'u1',
      title: 'شقة حدة 2 - مبنى مجاور',
      description: 'وصف',
      dealType: 'rent',
      propertyTypeId: 'apartment',
      city: 'صنعاء',
      district: 'حدة',
      latitude: 15.3220,
      longitude: 44.1850,
      price: 180000,
      areaSqm: 140,
      contactPhone: '777000222',
      createdAt: DateTime.now(),
    );

    final propAden = Property(
      id: 'p3',
      ownerId: 'u1',
      title: 'فيلا خور مكسر',
      description: 'وصف',
      dealType: 'sale',
      propertyTypeId: 'villa',
      city: 'عدن',
      district: 'خور مكسر',
      latitude: 12.8250,
      longitude: 45.0100,
      price: 90000000,
      areaSqm: 350,
      contactPhone: '777000333',
      createdAt: DateTime.now(),
    );

    test('1. hasExactCoordinates identifies presence or absence of GPS', () {
      expect(MapClusterService.hasExactCoordinates(propSanaa1), isTrue);

      final propNoGps = Property(
        id: 'p4',
        ownerId: 'u1',
        title: 'عقار بدون GPS',
        description: 'وصف',
        dealType: 'sale',
        propertyTypeId: 'land',
        city: 'تعز',
        district: 'المظفر',
        latitude: null,
        longitude: null,
        price: 20000000,
        areaSqm: 400,
        contactPhone: '777000444',
        createdAt: DateTime.now(),
      );

      expect(MapClusterService.hasExactCoordinates(propNoGps), isFalse);
      final coords = MapClusterService.getPropertyCoordinates(propNoGps);
      expect(coords.$1, inInclusiveRange(12.0, 19.0));
      expect(coords.$2, inInclusiveRange(41.0, 55.0));
    });

    test('2. Zoom scaling: low zoom clusters nearby points into single group', () {
      final properties = [propSanaa1, propSanaa2, propAden];

      // At zoom 9.0 (regional view of Yemen), Sanaa properties cluster together into 1 cluster
      // while Aden remains separate.
      final clustersZoom9 = MapClusterService.clusterProperties(
        properties: properties,
        zoom: 9.0,
      );

      expect(clustersZoom9.length, 2);
      final sanaaCluster = clustersZoom9.firstWhere((c) => c.count == 2);
      expect(sanaaCluster.properties.map((p) => p.id), containsAll(['p1', 'p2']));
      expect(sanaaCluster.isSingle, isFalse);

      final adenCluster = clustersZoom9.firstWhere((c) => c.count == 1);
      expect(adenCluster.singleProperty.id, 'p3');
      expect(adenCluster.isSingle, isTrue);
    });

    test('3. Zoom scaling: high zoom disaggregates nearby points into individual pins', () {
      final properties = [propSanaa1, propSanaa2, propAden];

      // At zoom 16.0 (street view), Sanaa properties separate into distinct individual pins!
      final clustersZoom16 = MapClusterService.clusterProperties(
        properties: properties,
        zoom: 16.0,
      );

      expect(clustersZoom16.length, 3);
      for (final cluster in clustersZoom16) {
        expect(cluster.isSingle, isTrue);
        expect(cluster.count, 1);
      }
    });

    test('4. Cluster radius decreases monotonically as zoom increases', () {
      double lastRadius = double.infinity;
      for (double z = 5.0; z <= 18.0; z += 1.0) {
        final r = MapClusterService.getClusterRadiusDegrees(z);
        expect(r, lessThanOrEqualTo(lastRadius));
        lastRadius = r;
      }
    });
  });
}
