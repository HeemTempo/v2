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
    }
  }
""";
