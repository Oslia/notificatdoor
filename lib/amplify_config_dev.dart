const amplifyConfigDev = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/2.0",
        "Version": "1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "ap-northeast-1_cnCAFo2Ba",
            "AppClientId": "66h8regff78tg4gfmq5pmmbo46",
            "Region": "ap-northeast-1"
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "https://ap-northeast-1cncafo2ba.auth.ap-northeast-1.amazoncognito.com",
              "AppClientId": "66h8regff78tg4gfmq5pmmbo46",
              "SignInRedirectURI": "http://localhost:3000/",
              "SignOutRedirectURI": "http://localhost:3000/",
              "Scopes": [
                "email",
                "openid",
                "phone",
                "aws.cognito.signin.user.admin"
              ],
              "ResponseType": "code"
            }
          }
        }
      }
    }
  }
}
''';