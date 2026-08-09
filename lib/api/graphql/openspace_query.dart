const String getAllOpenSpacesQuery = """
  query MyQuery {
    allOpenSpacesUser {
      id
      isActive
      name
      longitude
      latitude
      district
      status
      street
      shapeType
      boundary
      area
    }
  }
""";

const String getOpenSpaceCountQuery = """
  query MyQuery {
    totalOpenspaces
  }
""";
