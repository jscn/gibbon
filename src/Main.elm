module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
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


initialCmd : Cmd Msg
initialCmd =
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
    [ h1 [] [ text "mandrills" ]
    , ul [] (List.map viewMessage messages)
    ]


viewMessage : Message -> Html Msg
viewMessage message =
    li []
        [ ul []
            [ li [] [ text ("_id: " ++ message.id) ]
            , li [] [ text ("created_at: " ++ message.createdAt) ]
            , li [] [ text ("send_at: " ++ message.sendAt) ]
            , li [] [ text ("from_email: " ++ message.fromEmail) ]
            , li [] [ text ("to: " ++ message.to) ]
            , li [] [ text ("subject: " ++ message.subject) ]
            ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
