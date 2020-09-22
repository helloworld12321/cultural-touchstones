module Utils.MoreHttp exposing (put)

{-| This file contains functions for making HTTP requests.

It functions as an expansion on the Http module.
-}

import Http

{-| This function makes a PUT request to a specified URL. -}
put : { url : String, body : Http.Body, expect : Http.Expect msg } -> Cmd msg
put theRequest =
  Http.request
    { method = "PUT"
    , headers = []
    , url = theRequest.url
    , body = theRequest.body
    , expect = theRequest.expect
    , timeout = Nothing
    , tracker = Nothing
    }
