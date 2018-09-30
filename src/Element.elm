port module Element exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events



---- MODEL ----


type alias Model =
    { name : String
    }


init : String -> ( Model, Cmd Msg )
init name =
    ( { name = name
      }
    , Cmd.none
    )



---- UPDATE ----


port updateValue : String -> Cmd msg


port values : (String -> msg) -> Sub msg


type Msg
    = ValueUpdated String
    | TextInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ValueUpdated str ->
            ( { model
                | name = str
              }
            , Cmd.none
            )

        TextInput str ->
            ( { model
                | name = str
              }
            , updateValue str
            )


subscriptions : Model -> Sub Msg
subscriptions =
    always <|
        values ValueUpdated



---- VIEW ----


view : Model -> Html Msg
view { name } =
    div []
        [ input [ Events.onInput TextInput, Attr.value name ] []
        ]



---- PROGRAM ----


main : Program String Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
