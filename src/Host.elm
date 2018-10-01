module Host exposing (MemoryTest(..), Model)

import Browser
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Element.Keyed
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as Decode
import Random exposing (Generator, Seed)
import Random.Char
import Random.String


main : Program () Model Msg
main =
    Browser.document
        { init = \() -> init
        , view =
            \model ->
                { title = "Web Component Memory Test"
                , body = [ view model ]
                }
        , update = update
        , subscriptions = subscriptions
        }



---- MODEL ----


init : ( Model, Cmd Msg )
init =
    ( { name = "Josh"
      , memoryTest = Inactive
      }
    , Cmd.none
    )


type alias Model =
    { name : String
    , memoryTest : MemoryTest
    }


type MemoryTest
    = Inactive
    | Starting
    | Running
        { iteration : Int
        , seed : Seed
        , nameList : List String
        }



---- VIEW ----


view : Model -> Html Msg
view model =
    layout [] <|
        column
            [ width (maximum 500 fill)
            , centerX
            ]
            [ column
                [ padding 20
                , spacing 20
                , width fill
                ]
                [ el [ centerX ] <|
                    html <|
                        webComponent
                            { name = model.name
                            , onInput = NameChanged
                            }
                , row [ spacing 10, centerX ]
                    [ text model.name
                    , button []
                        { onPress = Just (NameChanged "Josh")
                        , label = "Set to \"Josh\""
                        }
                    ]
                ]
            , case model.memoryTest of
                Inactive ->
                    button []
                        { onPress = Just StartMemoryTest
                        , label = "Start Memory Test"
                        }

                Starting ->
                    row []
                        [ text "Starting Memory Test..."
                        , button []
                            { onPress = Just CancelMemoryTest
                            , label = "Cancel"
                            }
                        ]

                Running testModel ->
                    column []
                        [ text ("Iteration" ++ String.fromInt testModel.iteration)
                        , button []
                            { onPress = Just CancelMemoryTest
                            , label = "Cancel"
                            }
                        , Element.Keyed.column [] <|
                            List.map
                                (\name ->
                                    ( name
                                    , el [] <|
                                        html <|
                                            webComponent
                                                { name = name
                                                , onInput = \_ -> NoOp
                                                }
                                    )
                                )
                                testModel.nameList
                        ]
            ]


button :
    List (Attribute msg)
    ->
        { onPress : Maybe msg
        , label : String
        }
    -> Element msg
button attributes { onPress, label } =
    Input.button
        ([ Background.color (rgb 0.8 0.8 0.8)
         , Border.width 1
         , Border.color (rgb 0.5 0.5 0.5)
         , Border.rounded 5
         , padding 5
         , mouseOver
            [ Background.color (rgb 0.9 0.9 0.9)
            ]
         , mouseDown
            [ Background.color (rgb 0.7 0.7 0.7)
            ]
         ]
            ++ attributes
        )
        { onPress = onPress
        , label = text label
        }


webComponent :
    { name : String
    , onInput : String -> msg
    }
    -> Html msg
webComponent { name, onInput } =
    Html.node "my-webcomponent"
        [ HA.attribute "name" name
        , HE.on "change"
            (Decode.field "detail" Decode.string
                |> Decode.map onInput
            )
        ]
        []



---- UPDATE ----


type Msg
    = NameChanged String
    | StartMemoryTest
    | CancelMemoryTest
    | GotInitialSeed Seed
    | UpdateMemoryTest
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameChanged name ->
            ( { model
                | name = name
              }
            , Cmd.none
            )

        StartMemoryTest ->
            case model.memoryTest of
                Inactive ->
                    ( { model
                        | memoryTest = Starting
                      }
                    , Random.generate GotInitialSeed Random.independentSeed
                    )

                Starting ->
                    ( model, Cmd.none )

                Running _ ->
                    ( model, Cmd.none )

        CancelMemoryTest ->
            case model.memoryTest of
                Inactive ->
                    ( model, Cmd.none )

                Starting ->
                    ( { model
                        | memoryTest = Inactive
                      }
                    , Cmd.none
                    )

                Running _ ->
                    ( { model
                        | memoryTest = Inactive
                      }
                    , Cmd.none
                    )

        GotInitialSeed seed ->
            case model.memoryTest of
                Inactive ->
                    ( model, Cmd.none )

                Starting ->
                    let
                        ( randomNames, updatedSeed ) =
                            Random.step (Random.list 5 nameGenerator) seed
                    in
                    ( { model
                        | memoryTest =
                            Running
                                { iteration = 1
                                , seed = updatedSeed
                                , nameList = randomNames
                                }
                      }
                    , Cmd.none
                    )

                Running _ ->
                    ( model, Cmd.none )

        UpdateMemoryTest ->
            case model.memoryTest of
                Inactive ->
                    ( model, Cmd.none )

                Starting ->
                    ( model, Cmd.none )

                Running testModel ->
                    if testModel.iteration < 1000 then
                        let
                            ( randomNames, updatedSeed ) =
                                Random.step (Random.list 5 nameGenerator) testModel.seed
                        in
                        ( { model
                            | memoryTest =
                                Running
                                    { iteration = testModel.iteration + 1
                                    , seed = updatedSeed
                                    , nameList = randomNames
                                    }
                          }
                        , Cmd.none
                        )

                    else
                        ( { model
                            | memoryTest = Inactive
                          }
                        , Cmd.none
                        )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.memoryTest of
        Inactive ->
            Sub.none

        Starting ->
            Sub.none

        Running _ ->
            Browser.Events.onAnimationFrame (\_ -> UpdateMemoryTest)



---- GENERATORS ----


nameGenerator : Generator String
nameGenerator =
    Random.String.string 5 Random.Char.english
