import 'dart:async';

import 'package:flutter/material.dart';
import '../../domain/entities/offer.dart';
import '../../../wishlist/presentation/state/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:shaman/core/widgets/stylish_card.dart';
import 'package:shaman/core/widgets/badge.dart';
import 'package:shaman/core/widgets/rating_stars.dart';
import 'package:shaman/core/theme/design_tokens.dart';

class OfferCard extends StatefulWidget {
  final Offer offer;
  final VoidCallback? onTap;

  const OfferCard({super.key, required this.offer, this.onTap});

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    if (widget.offer.endDateTime != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _updateRemaining() {
    final end = widget.offer.endDateTime;
    if (end == null) {
      _remaining = null;
      return;
    }
    final now = DateTime.now();
    _remaining = end.difference(now);
    if (_remaining != null && _remaining!.isNegative) {
      _remaining = Duration.zero;
    }
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _updateRemaining();
      if (_remaining != null && _remaining == Duration.zero) {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  @override
  void didUpdateWidget(covariant OfferCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer.endDateTime != widget.offer.endDateTime) {
      _timer?.cancel();
      _updateRemaining();
      if (widget.offer.endDateTime != null) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return 'انتهى';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (days > 0) {
      return '$days يوم ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final raw = offer.productImage;
    final imageUrl = (raw != null && raw.startsWith('/')) ? 'https://localhost:7095$raw' : raw;
    final expired = _remaining != null && _remaining == Duration.zero;

    double? progress;
    if (offer.startDateTime != null && offer.endDateTime != null) {
      final total = offer.endDateTime!.difference(offer.startDateTime!);
      if (total.inSeconds > 0) {
        final elapsed = DateTime.now().difference(offer.startDateTime!);
        progress = (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
      }
    }

    Color chipColor = DesignColors.primary;
    if (_remaining == null) {
      chipColor = Colors.blueGrey;
    } else if (_remaining == Duration.zero) {
      chipColor = Colors.grey;
    } else if (_remaining! <= const Duration(hours: 1)) {
      chipColor = Colors.redAccent;
    } else if (_remaining! <= const Duration(days: 1)) {
      chipColor = Colors.orangeAccent;
    }

    return GestureDetector(
      onTap: expired ? null : widget.onTap,
      child: SizedBox(
        // give the offer card a slightly larger min size
          child: SizedBox(
          width: 300,
          height: 400,
          child: StylishCard(
            child: InkWell(
              onTap: expired ? null : widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 400,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Fixed-height image area with gradient overlay
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                      height: 180,
                      child: Stack(fit: StackFit.expand, children: [
                        imageUrl != null
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey[200], alignment: Alignment.center, child: const Icon(Icons.image, size: 40)),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withAlpha((0.45 * 255).round())]),
                            ),
                          ),
                        ),
                        Positioned(left: 8, top: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(20)), child: Text(_remaining == null ? 'مستمر' : _formatDuration(_remaining!), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
                        if (offer.discount > 0) Positioned(right: 8, top: 8, child: AppBadge(text: '-${(offer.discount * 100).toStringAsFixed(0)}%')),
                        Positioned(right: 10, top: 48, child: Consumer<WishlistProvider>(builder: (ctx, wp, ch) {
                          final inWishlist = wp.isInWishlist(offer.productId);
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  final added = await wp.toggle(offer.productId);
                                  messenger.showSnackBar(SnackBar(content: Text(added ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة')));
                                } catch (e) {
                                  messenger.showSnackBar(SnackBar(content: Text('فشل العملية: ${e.toString()}')));
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: CircleAvatar(radius: 18, backgroundColor: DesignColors.surface.withAlpha((0.9 * 255).round()), child: Icon(inWishlist ? Icons.favorite : Icons.favorite_border, color: inWishlist ? Colors.red : Colors.white)),
                            ),
                          );
                        })),
                        // title + rating overlay
                        Positioned(left: 12, right: 12, bottom: 12, child: Row(children: [
                          Expanded(child: Text(offer.productName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 3, overflow: TextOverflow.ellipsis)),
                          if (offer.averageRating != null && offer.averageRating! > 0) Padding(padding: const EdgeInsets.only(left: 8.0), child: RatingStars(rating: offer.averageRating!, size: 14))
                        ]))
                      ]),
                    ),
                  ),

                  // Details area (fixed height to show all details)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Price and time/progress
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${(offer.discount > 0 ? (offer.price * (1 - offer.discount)) : offer.price).toStringAsFixed(2)} ر.س', style: TextStyle(color: DesignColors.primary, fontWeight: FontWeight.bold, fontSize: 16, height: 1.1)),
                            if (offer.discount > 0) Padding(padding: const EdgeInsets.only(top: 2.0), child: Text('${offer.price.toStringAsFixed(2)} ر.س', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11, height: 1.0))),
                          ]),

                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            if (_remaining != null) Text(_formatDuration(_remaining!), style: TextStyle(color: expired ? Colors.red.shade200 : DesignColors.primary, fontWeight: FontWeight.w600, height: 1.05)),
                            const SizedBox(height: 6),
                            if (progress != null) SizedBox(width: 90, child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Colors.black12, valueColor: AlwaysStoppedAnimation(DesignColors.secondary))),
                          ])
                        ]),

                        const SizedBox(height: 6),
                        // Full title and meta (no truncation beyond 3 lines for title)
                        Text(offer.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.15), maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          if (offer.reviewsCount != null) Text('${offer.reviewsCount} تقييم', style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.0)),
                          // placeholder for actions or tags
                          const SizedBox.shrink()
                        ])
                      ]),
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
