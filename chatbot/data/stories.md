## happy path
* greet
    - utter_greet
* mood_great
    - utter_happy
* affirm
    - utter_goodbye

## search restaurant happy path


* search_resturant

  - action_search_resturant

  - utter_did_that_help



## search restaurant sad path

* greet
  - utter_greet

* search_resturant

  - action_search_resturant

  - utter_did_that_help

* deny

  - utter_default

* search_resturant

  - action_search_resturant

  - utter_did_that_help

* affirm

  - utter_goodbye