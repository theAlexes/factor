IN: http.server.auth.providers.assoc.tests
USING: http.server.auth.providers 
http.server.auth.providers.assoc tools.test
namespaces accessors kernel ;

<users-in-memory> "provider" set

[ t ] [
    "slava" <user>
        "foobar" >>password
        "slava@factorcode.org" >>email
        H{ } clone >>profile
    "provider" get new-user
    username>> "slava" =
] unit-test

[ f ] [
    "slava" <user>
        H{ } clone >>profile
    "provider" get new-user
] unit-test

[ f ] [ "fdasf" "slava" "provider" get check-login >boolean ] unit-test

[ ] [ "foobar" "slava" "provider" get check-login "user" set ] unit-test

[ t ] [ "user" get >boolean ] unit-test

[ ] [ "user" get "fdasf" >>password drop ] unit-test

[ t ] [ "fdasf" "slava" "provider" get check-login >boolean ] unit-test

[ f ] [ "foobar" "slava" "provider" get check-login >boolean ] unit-test
