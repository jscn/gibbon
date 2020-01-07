module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, list, map6, string)
import Json.Encode as Encode


type alias Model =
    { messages : List Message
    , status : Status
    }


initialModel : Model
initialModel =
    { messages = []
    , status = Loading
    }


type alias Message =
    { id : String
    , createdAt : String
    , sendAt : String
    , fromEmail : String
    , to : String
    , subject : String
    }


messageDecoder : Decoder Message
messageDecoder =
    map6 Message
        (field "_id" string)
        (field "created_at" string)
        (field "send_at" string)
        (field "from_email" string)
        (field "to" string)
        (field "subject" string)


type Status
    = Loading
    | Loaded (List Message)
    | Errored String


type Msg
    = GotMessages (Result Http.Error (List Message))
    | ClickedReload


initialCmd : Cmd Msg
initialCmd =
    Http.post
        { url = "https://mandrillapp.com/api/1.0/messages/list-scheduled.json"
        , body = Http.jsonBody (Encode.object [ ( "key", Encode.string "REDACTED" ) ])
        , expect = Http.expectJson GotMessages (list messageDecoder)
        }


reloadCmd : Cmd Msg
reloadCmd =
    Http.post
        { url = "https://mandrillapp.com/api/1.0/messages/list-scheduled.json"
        , body = Http.jsonBody (Encode.object [ ( "key", Encode.string "REDACTED" ) ])
        , expect = Http.expectJson GotMessages (list messageDecoder)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMessages (Ok messages) ->
            case messages of
                first :: rest ->
                    ( { model | status = Loaded messages }
                    , Cmd.none
                    )

                [] ->
                    ( { model | status = Errored "0 messages found" }, Cmd.none )

        GotMessages (Err httpError) ->
            ( { model | status = Errored "Server error" }, Cmd.none )

        ClickedReload ->
            ( { model | status = Loading }, reloadCmd )


view : Model -> Html Msg
view model =
    div [ class "content" ]
        (case model.status of
            Loaded messages ->
                viewMessages messages

            Loading ->
                [ text "Loading" ]

            Errored errorMessage ->
                [ text ("Error: " ++ errorMessage) ]
        )


viewMessages : List Message -> List (Html Msg)
viewMessages messages =
    [ div [ class "center ph3 ph5-ns ph0l" ]
        [ h1 [ class "f5 f4-ns f3-l normal pt5 pt6-ns black-50" ] [ text "Messages" ]
        , a
            [ class "link underline u pl4 pointer"
            , onClick ClickedReload
            ]
            [ text "Reload" ]
        , div [ class "w-100 pv4 b--black-50" ]
            [ table [ class "collapse" ] (List.append [ tableHead ] (List.map viewMessage messages))
            ]
        ]
    ]


tableHead =
    tr [ class "striped--light-gray" ]
        [ th [ class "pv2 ph3 tl" ] [ text "To" ]
        , th [ class "pv2 ph3 tl" ] [ text "Send At" ]
        , th [ class "pv2 ph3 tl" ] [ text "Subject" ]
        , th [ class "pv2 ph3 tl" ] [ text "From" ]
        , th [ class "pv2 ph3 tl" ] [ text "Created" ]
        ]


viewMessage : Message -> Html Msg
viewMessage message =
    tr [ class "striped--light-gray" ]
        [ td [ class "pv2 ph3 " ] [ text message.to ]
        , td [ class "pv2 ph3 " ] [ text message.sendAt ]
        , td [ class "pv2 ph3 " ] [ text message.subject ]
        , td [ class "pv2 ph3 " ] [ text message.fromEmail ]
        , td [ class "pv2 ph3 " ] [ text message.createdAt ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
