module Page.Home exposing (Model, Msg(..), init, update, view)

import Browser
import Html exposing (..)


init : ( Model, Cmd Msg )
init =
    ( Model "hoge", Cmd.none )


type alias Model =
    { test : String }


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- view : Model -> Browser.Document Msg
-- view model =
--     { title = "Home"
--     , body = [ text model.test ]
--     }


view : Model -> Html Msg
view model =
    text model.test
