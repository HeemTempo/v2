const String REGISTER_USER = r'''
mutation RegisterUser(
  $email: String,
  $password: String!,
  $passwordConfirm: String!,
  $username: String!,
  $sessionId: String
) {
  registerUser(input: {
    email: $email,
    password: $password,
    passwordConfirm: $passwordConfirm,
    username: $username,
    sessionId: $sessionId
  }) {
    output {
      message
      success
      user {
        id
        username
        
      }
    }
  }
}
''';



const String LOGIN_USER_AGAIN = r'''
mutation LoginUser($username: String!, $password: String!) {
  loginUser(username: $username, password: $password) {
    message
    success
    user {
      id
      username
      token
    }
  }
}
''';
