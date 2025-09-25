const String getAllReportsQuery = """
      query MyQuery {
        allReports {
          id
          description
          createdAt
          latitude
          longitude
          reportId
          spaceName
          file
        }
      }
    """;