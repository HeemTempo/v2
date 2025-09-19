const String getAllOpenSpacesQuery = """
  query MyQuery {
    allOpenSpacesUser {
      id
      district
      name
      status
      longitude
      latitude
      isActive
    }
  }
""";
