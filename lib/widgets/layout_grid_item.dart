import 'package:flutter/material.dart';
import 'package:novella_app/models/book.dart';


class LayoutGridItem extends StatelessWidget {
  const LayoutGridItem({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Text(
            book.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
      ),
    );
  }
}
