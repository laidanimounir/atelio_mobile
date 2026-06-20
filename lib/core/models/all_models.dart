class Customer {
  final int id;
  final String? codeClient;
  final String nomComplet;
  final String? activite;
  final String? adresse;
  final String? wilaya;
  final int companyId;
  final double? caHt;
  final double? caTtc;
  final bool estRadie;

  Customer({required this.id, this.codeClient, required this.nomComplet, this.activite, this.adresse, this.wilaya, required this.companyId, this.caHt, this.caTtc, this.estRadie = false});

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] ?? 0,
        codeClient: j['codeclient'],
        nomComplet: j['nomcomplet'] ?? '',
        activite: j['activite'],
        adresse: j['adresse'],
        wilaya: j['wilaya'],
        companyId: j['companyid'] ?? 0,
        caHt: double.tryParse(j['ca_ht']?.toString() ?? ''),
        caTtc: double.tryParse(j['ca_ttc']?.toString() ?? ''),
        estRadie: (j['estradie']?.toString() ?? '0') != '0',
      );
}

class Supplier {
  final int id;
  final String? codeFournisseur;
  final String designation;
  final String? activite;
  final int companyId;
  final double? dette;
  final bool estActif;

  Supplier({required this.id, this.codeFournisseur, required this.designation, this.activite, required this.companyId, this.dette, this.estActif = true});

  factory Supplier.fromJson(Map<String, dynamic> j) => Supplier(
        id: j['id'] ?? 0,
        codeFournisseur: j['codefournisseur'],
        designation: j['designation'] ?? '',
        activite: j['activite'],
        companyId: j['companyid'] ?? 0,
        dette: double.tryParse(j['dette']?.toString() ?? ''),
        estActif: (j['estactif']?.toString() ?? '1') != '0',
      );
}

class Product {
  final int id;
  final String? codeProduit;
  final String nom;
  final String? prixVente;
  final String? stockActuel;
  final String? stockMin;
  final int? unitId;
  final int companyId;

  Product({required this.id, this.codeProduit, required this.nom, this.prixVente, this.stockActuel, this.stockMin, this.unitId, required this.companyId});

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] ?? 0, codeProduit: j['codeproduit'], nom: j['nom'] ?? '',
        prixVente: j['prixvente']?.toString(), stockActuel: j['stockactuel']?.toString(),
        stockMin: j['stockmin']?.toString(), unitId: j['unitid'], companyId: j['companyid'] ?? 0,
      );
}

class CommercialProduct {
  final int id;
  final String? code;
  final String? barcode;
  final String name;
  final double? sellingPriceRetail;
  final double? stockQuantity;
  final int? minStockLevel;
  final int companyId;

  CommercialProduct({required this.id, this.code, this.barcode, required this.name, this.sellingPriceRetail, this.stockQuantity, this.minStockLevel, required this.companyId});

  factory CommercialProduct.fromJson(Map<String, dynamic> j) => CommercialProduct(
        id: j['id'] ?? 0, code: j['code'], barcode: j['barcode'], name: j['name'] ?? '',
        sellingPriceRetail: double.tryParse(j['sellingpriceretail']?.toString() ?? ''),
        stockQuantity: double.tryParse(j['stockquantity']?.toString() ?? ''),
        minStockLevel: j['minstocklevel'], companyId: j['companyid'] ?? 0,
      );
}

class RawMaterial {
  final int id;
  final String? codeMatiere;
  final String designation;
  final String? reference;
  final int? unitId;
  final double? stockActuel;
  final double? stockMin;
  final double? pmapa;
  final int companyId;

  RawMaterial({required this.id, this.codeMatiere, required this.designation, this.reference, this.unitId, this.stockActuel, this.stockMin, this.pmapa, required this.companyId});

  factory RawMaterial.fromJson(Map<String, dynamic> j) => RawMaterial(
        id: j['id'] ?? 0, codeMatiere: j['codematiere'], designation: j['designation'] ?? '',
        reference: j['reference'], unitId: j['unitid'],
        stockActuel: double.tryParse(j['stockactuel']?.toString() ?? ''),
        stockMin: double.tryParse(j['stockmin']?.toString() ?? ''),
        pmapa: double.tryParse(j['pmapa']?.toString() ?? ''), companyId: j['companyid'] ?? 0,
      );
}

class SalesInvoice {
  final int id;
  final String? numeroFacture;
  final int? customerId;
  final String? dateFacture;
  final double? montantTtc;
  final bool estPayee;
  final int companyId;

  SalesInvoice({required this.id, this.numeroFacture, this.customerId, this.dateFacture, this.montantTtc, this.estPayee = false, required this.companyId});

  factory SalesInvoice.fromJson(Map<String, dynamic> j) => SalesInvoice(
        id: j['id'] ?? 0, numeroFacture: j['numerofacture'], customerId: j['customerid'],
        dateFacture: j['datefacture'], montantTtc: double.tryParse(j['montantttc']?.toString() ?? ''),
        estPayee: (j['estpayee']?.toString() ?? '0') != '0', companyId: j['companyid'] ?? 0,
      );
}

class SalesInvoiceLine {
  final int id;
  final int salesInvoiceId;
  final int productId;
  final double? quantite;
  final double? prixUnitaire;
  final double? montantLigne;
  SalesInvoiceLine({required this.id, required this.salesInvoiceId, required this.productId, this.quantite, this.prixUnitaire, this.montantLigne});
  factory SalesInvoiceLine.fromJson(Map<String, dynamic> j) => SalesInvoiceLine(
        id: j['id'] ?? 0, salesInvoiceId: j['salesinvoiceid'] ?? 0, productId: j['productid'] ?? 0,
        quantite: double.tryParse(j['quantite']?.toString() ?? ''),
        prixUnitaire: double.tryParse(j['prixunitaire']?.toString() ?? ''),
        montantLigne: double.tryParse(j['montantligne']?.toString() ?? ''),
      );
}

class PurchaseInvoice {
  final int id;
  final String? numeroFacture;
  final int? supplierId;
  final String? dateFacture;
  final double? montantTtc;
  final bool estPayee;
  final int companyId;

  PurchaseInvoice({required this.id, this.numeroFacture, this.supplierId, this.dateFacture, this.montantTtc, this.estPayee = false, required this.companyId});

  factory PurchaseInvoice.fromJson(Map<String, dynamic> j) => PurchaseInvoice(
        id: j['id'] ?? 0, numeroFacture: j['numerofacture'], supplierId: j['supplierid'],
        dateFacture: j['datefacture'], montantTtc: double.tryParse(j['montantttc']?.toString() ?? ''),
        estPayee: (j['estpayee']?.toString() ?? '0') != '0', companyId: j['companyid'] ?? 0,
      );
}

class PurchaseInvoiceLine {
  final int id;
  final int purchaseInvoiceId;
  final int rawMaterialId;
  final double? quantite;
  final double? prixUnitaire;
  final double? montantLigne;
  PurchaseInvoiceLine({required this.id, required this.purchaseInvoiceId, required this.rawMaterialId, this.quantite, this.prixUnitaire, this.montantLigne});
  factory PurchaseInvoiceLine.fromJson(Map<String, dynamic> j) => PurchaseInvoiceLine(
        id: j['id'] ?? 0, purchaseInvoiceId: j['purchaseinvoiceid'] ?? 0, rawMaterialId: j['rawmaterialid'] ?? 0,
        quantite: double.tryParse(j['quantite']?.toString() ?? ''),
        prixUnitaire: double.tryParse(j['prixunitaire']?.toString() ?? ''),
        montantLigne: double.tryParse(j['montantligne']?.toString() ?? ''),
      );
}

class CommercialSalesInvoice {
  final int id;
  final String? invoiceNumber;
  final int? customerId;
  final String? customerName;
  final String? invoiceDate;
  final double? montantTtc;
  final String? status;
  final int companyId;

  CommercialSalesInvoice({required this.id, this.invoiceNumber, this.customerId, this.customerName, this.invoiceDate, this.montantTtc, this.status, required this.companyId});

  factory CommercialSalesInvoice.fromJson(Map<String, dynamic> j) => CommercialSalesInvoice(
        id: j['id'] ?? 0, invoiceNumber: j['invoicenumber'], customerId: j['customerid'],
        customerName: j['customername'], invoiceDate: j['invoicedate'],
        montantTtc: double.tryParse(j['montantttc']?.toString() ?? ''),
        status: j['status'], companyId: j['companyid'] ?? 0,
      );
}

class StockBatch {
  final int id;
  final int commercialProductId;
  final String? batchNumber;
  final String? purchaseDate;
  final double? quantityRemaining;
  final int companyId;

  StockBatch({required this.id, required this.commercialProductId, this.batchNumber, this.purchaseDate, this.quantityRemaining, required this.companyId});

  factory StockBatch.fromJson(Map<String, dynamic> j) => StockBatch(
        id: j['id'] ?? 0, commercialProductId: j['commercialproductid'] ?? 0,
        batchNumber: j['batchnumber'], purchaseDate: j['purchasedate'],
        quantityRemaining: double.tryParse(j['quantityremaining']?.toString() ?? ''),
        companyId: j['companyid'] ?? 0,
      );
}

class SyncLog {
  final String id;
  final String createdAt;
  final String type;
  final String? deviceId;
  final bool success;

  SyncLog({required this.id, required this.createdAt, required this.type, this.deviceId, required this.success});

  factory SyncLog.fromJson(Map<String, dynamic> j) => SyncLog(
        id: j['id']?.toString() ?? '', createdAt: j['created_at']?.toString() ?? '',
        type: j['type']?.toString() ?? '', deviceId: j['device_id']?.toString(),
        success: j['success'] == true || j['success']?.toString() == 'true',
      );
}

class Device {
  final String id;
  final String name;
  final String? lastSeen;
  final String? lastSync;
  final bool syncPaused;

  Device({required this.id, required this.name, this.lastSeen, this.lastSync, this.syncPaused = false});

  factory Device.fromJson(Map<String, dynamic> j) => Device(
        id: j['id']?.toString() ?? '', name: j['name']?.toString() ?? '',
        lastSeen: j['last_seen']?.toString(), lastSync: j['last_sync']?.toString(),
        syncPaused: j['sync_paused'] == true || j['sync_paused']?.toString() == 'true',
      );
}
