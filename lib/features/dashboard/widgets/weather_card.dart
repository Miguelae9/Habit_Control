import 'package:flutter/material.dart';

import 'package:habit_control/features/dashboard/models/weather_info.dart';
import 'package:habit_control/shared/app_card.dart';
import 'package:habit_control/shared/app_section_title.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
    required this.loading,
    required this.error,
  });

  final WeatherInfo? weather;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    final title = weather?.city.toUpperCase() ?? 'WEATHER';
    final temperature = weather == null
        ? '--ºC'
        : '${weather!.temperature.round()}ºC';
    final humidity = weather == null ? '--%' : '${weather!.humidity}%';
    final wind = weather == null
        ? '-- km/h'
        : '${weather!.windSpeed.round()} km/h';

    final message = loading
        ? 'Loading weather...'
        : error ?? weather?.habitContext ?? 'Weather data unavailable.';

    return AppCard(
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSectionTitle(
            title: title,
            subtitle: 'Weather context for your habits',
            icon: Icons.wb_cloudy_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  temperature,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('HUM.: $humidity', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text('WIND: $wind', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
