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
            "AppClientId": "37hciku977k840e0vf4uifn02c",
            "Region": "ap-northeast-1"
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "https://ap-northeast-1cncafo2ba.auth.ap-northeast-1.amazoncognito.com",
              "AppClientId": "37hciku977k840e0vf4uifn02c",
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