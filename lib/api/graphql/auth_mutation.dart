const String registerMutation = r'''
mutation RegisterUser($input: RegistrationInputObject!) {
  registerUser(input: $input) {
    output {
      message
      success
      user {
        id
        username

      }
    }
    user {
      id
      username
  
    }
  }
}
''';

const String loginMutation = r'''
mutation loginUser($input : UserLoginInputObject!){
  loginUser(input :$input) {
     output {
       message
       success
           user {
          id
          isStaff
          isWardExecutive
          refreshToken
          username
          accessToken
      }
    }
    
  }  
}
''';


