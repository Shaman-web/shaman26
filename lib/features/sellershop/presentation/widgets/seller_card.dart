import 'package:flutter/material.dart';
import '../../domain/entities/seller.dart';
import 'package:shaman/core/widgets/stylish_card.dart';
// removed unused imports

class SellerCard extends StatelessWidget {
  final Seller seller;
  final VoidCallback? onTap;

  const SellerCard({super.key, required this.seller, this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = seller.imagePath;
    return SizedBox(
      width: 160,
      child: GestureDetector(
        onTap: onTap,
        child: StylishCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: img != null
                      ? Image.network(img, fit: BoxFit.cover, width: double.infinity)
                      : Container(color: Colors.grey[200], child: const Icon(Icons.store, size: 48)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(seller.shopName ?? seller.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (seller.location != null) Text(seller.location!, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
