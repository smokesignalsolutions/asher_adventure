import 'map_data.dart';

/// Get the map screen background for the current map definition.
String mapBackground(int mapDefinitionId) {
  return getMapDefinition(mapDefinitionId).imagePath;
}

/// Get the combat background. Uses map image for now.
/// Custom combat backgrounds per map are a future enhancement.
String combatBackground(int mapDefinitionId) {
  return getMapDefinition(mapDefinitionId).imagePath;
}
