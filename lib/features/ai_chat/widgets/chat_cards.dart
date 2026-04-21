import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class ServiceCardWidget extends StatefulWidget {
  final ServiceCard service;
  final Function(int)? onTabChange;

  const ServiceCardWidget({super.key, required this.service, this.onTabChange});

  @override
  State<ServiceCardWidget> createState() => _ServiceCardWidgetState();
}

class _ServiceCardWidgetState extends State<ServiceCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              // Navigate to services tab (index 2 - PackagesWithTabsScreen)
              if (widget.onTabChange != null) {
                widget.onTabChange!(2);
              }
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: _isPressed ? 8 : 2,
              shadowColor: const Color(0xFF045668).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isPressed 
                      ? const Color(0xFF045668).withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    if (widget.service.thumbnail != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.service.thumbnail!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.fitness_center, color: Colors.grey),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (widget.service.category != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF045668),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.service.category!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                          if (widget.service.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.service.description!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (widget.service.priceFormatted != null)
                                Text(
                                  widget.service.priceFormatted!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              if (widget.service.duration != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.service.duration} mins',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF045668), Color(0xFF0999B8)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Book Now →',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MembershipCardWidget extends StatefulWidget {
  final MembershipCard membership;
  final Function(int)? onTabChange;

  const MembershipCardWidget({super.key, required this.membership, this.onTabChange});

  @override
  State<MembershipCardWidget> createState() => _MembershipCardWidgetState();
}

class _MembershipCardWidgetState extends State<MembershipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              // Navigate to membership packages tab (index 2 - PackagesWithTabsScreen)
              if (widget.onTabChange != null) {
                widget.onTabChange!(2);
              }
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: _isPressed ? 8 : 2,
              shadowColor: widget.membership.color != null
                  ? Color(int.parse('FF${widget.membership.color!.replaceAll('#', '')}', radix: 16)).withOpacity(0.3)
                  : const Color(0xFF045668).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isPressed 
                      ? (widget.membership.color != null
                          ? Color(int.parse('FF${widget.membership.color!.replaceAll('#', '')}', radix: 16)).withOpacity(0.5)
                          : const Color(0xFF045668).withOpacity(0.3))
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: widget.membership.color != null
                      ? Border(
                          top: BorderSide(
                            color: Color(int.parse('FF${widget.membership.color!.replaceAll('#', '')}', radix: 16)),
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.membership.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (widget.membership.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Popular',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (widget.membership.discount != null && widget.membership.discount! > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.membership.discount!.toInt()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                      if (widget.membership.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.membership.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.membership.priceFormatted != null)
                            Text(
                              widget.membership.priceFormatted!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          if (widget.membership.originalPriceFormatted != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              widget.membership.originalPriceFormatted!,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          if (widget.membership.duration != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${widget.membership.duration} days',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.membership.features.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...widget.membership.features.take(3).map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check, color: Colors.green, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        )),
                        if (widget.membership.features.length > 3)
                          Text(
                            '+${widget.membership.features.length - 3} more benefits',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.membership.color != null
                                ? [
                                    Color(int.parse('FF${widget.membership.color!.replaceAll('#', '')}', radix: 16)),
                                    Color(int.parse('FF${widget.membership.color!.replaceAll('#', '')}', radix: 16)).withOpacity(0.8),
                                  ]
                                : [const Color(0xFF045668), const Color(0xFF0999B8)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Subscribe →',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TrainerCardWidget extends StatefulWidget {
  final TrainerCard trainer;
  final Function(int)? onTabChange;

  const TrainerCardWidget({super.key, required this.trainer, this.onTabChange});

  @override
  State<TrainerCardWidget> createState() => _TrainerCardWidgetState();
}

class _TrainerCardWidgetState extends State<TrainerCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              // Navigate to bookings tab (index 1 - BookingsTab)
              if (widget.onTabChange != null) {
                widget.onTabChange!(1);
              }
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: _isPressed ? 8 : 2,
              shadowColor: const Color(0xFF045668).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isPressed 
                      ? const Color(0xFF045668).withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: widget.trainer.avatar != null
                              ? NetworkImage(widget.trainer.avatar!)
                              : null,
                          backgroundColor: const Color(0xFF045668),
                          child: widget.trainer.avatar == null
                              ? Text(
                                  widget.trainer.fullName.isNotEmpty
                                      ? widget.trainer.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trainer.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (widget.trainer.totalExperienceYears != null)
                                Text(
                                  '${widget.trainer.totalExperienceYears} years experience',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.trainer.specialties.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: widget.trainer.specialties.map((specialty) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF045668),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            specialty.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                    if (widget.trainer.bio != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.trainer.bio!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF045668), Color(0xFF0999B8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Book Session →',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}