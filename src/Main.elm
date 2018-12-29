module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Home as Home
import Page.Sub as Sub
import Url
import Url.Parser as Parser



---- MODEL ----


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = NotFound
    | Home Home.Model
    | Sub Sub.Model


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    stepUrl url
        { key = key
        , page = NotFound
        }



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | SubMsg Sub.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        UrlChanged url ->
            stepUrl url model

        HomeMsg msg ->
            case model.page of
                Home home ->
                    stepHome model (Home.update msg home)

                _ ->
                    ( model, Cmd.none )

        SubMsg msg ->
            case model.page of
                Sub sub ->
                    stepSub model (Sub.update msg sub)

                _ ->
                    ( model, Cmd.none )


stepHome : Model -> ( Home.Model, Cmd Home.Msg ) -> ( Model, Cmd Msg )
stepHome model ( homeModel, homeMsg ) =
    ( { model | page = Home homeModel }
    , Cmd.map HomeMsg homeMsg
    )


stepSub : Model -> ( Sub.Model, Cmd Sub.Msg ) -> ( Model, Cmd Msg )
stepSub model ( subModel, subMsg ) =
    ( { model | page = Sub subModel }
    , Cmd.map SubMsg subMsg
    )



---- NAVIGATION ----
-- parser : Parser.Parser (Page -> a) a
-- parser =
--     Parser.oneOf
--         [ Parser.map Home Parser.top
--         , Parser.map Sub (Parser.s "sub")
--         ]
-- 新しいurlと現在のmodelを受け取って新しいmodelを返す


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        parser =
            Parser.oneOf
                [ Parser.map
                    (stepHome model Home.init)
                    Parser.top
                , Parser.map
                    (stepSub model Sub.init)
                    (Parser.s "sub")
                ]
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( { model | page = NotFound }
            , Cmd.none
            )



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    case model.page of
        NotFound ->
            { title = "NotFound"
            , body = [ text "notfound" ]
            }

        Home home ->
            { title = "home"
            , body =
                [ Html.map HomeMsg <| Home.view home
                ]
            }

        Sub sub ->
            { title = "sub"
            , body =
                [ Html.map SubMsg <| Sub.view sub
                ]
            }



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
